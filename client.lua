local currentZones = {}
local _U = i18n

-- Straße und Bezirk ermitteln // Get street and district
local function getStreetAndDistrict(coords)
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(s1)
    if s2 ~= 0 then street = street .. " / " .. GetStreetNameFromHashKey(s2) end
    
    local zoneName = GetNameOfZone(coords.x, coords.y, coords.z)
    local district = GetLabelText(zoneName) or "Unknown"
    
    return street .. " (" .. district .. ")"
end

-- Funktion zum löschen der Zonen // function for deleting zones
local function removeZone(zoneId)  
    if currentZones[zoneId] then
        if DoesBlipExist(currentZones[zoneId].radiusBlip) then 
            RemoveBlip(currentZones[zoneId].radiusBlip) 
        end
        RemoveRoadNodeSpeedZone(currentZones[zoneId].speedZone)
        currentZones[zoneId] = nil
    end
end

function openSpecificDeleteMenu()
    local options = {}
    local myJob = ESX.GetPlayerData().job.name
    local jobConfig = Config.AuthorizedJobs[myJob]

    if not jobConfig then return end

    for id, zone in pairs(currentZones) do
        if jobConfig.deleteOther or zone.creatorJob == myJob then
            local descString = "Reason: " .. (zone.reason or "Not specified")
            if jobConfig.deleteOther then
                local creatorLabel = "unknown job"
                if Config.AuthorizedJobs[zone.creatorJob] then
                    creatorLabel = Config.AuthorizedJobs[zone.creatorJob].label
                end
                descString = descString .. "\nCreated by: " .. creatorLabel
            end

            table.insert(options, {
                title = zone.location or "unknown location",
                description = descString,
                icon = 'location-dot',
                onSelect = function()
                    TriggerServerEvent('rcrpzone:stopSpecificZone', id)
                end
            })
        end
    end

    if #options == 0 then
        lib.notify({title = jobConfig.menuTitle, description = _U('no_active_zones'), type = 'error'})
        return
    end

    lib.registerContext({
        id = 'delete_select',
        title = _U('delete_spec_zones'),
        menu = 'sperrzone_main_menu',
        options = options
    })
    lib.showContext('delete_select')
end

-- NPC Kontrolle während Zonen bzw. in Zonen // NPC control during zones or in zones
CreateThread(function()
    while true do
        local sleep = 1500
        if next(currentZones) then
            local playerCoords = GetEntityCoords(cache.ped)
            for id, zone in pairs(currentZones) do
                local dist = #(playerCoords - zone.coords)
                if dist < (zone.radius + 100.0) then
                    sleep = 500
                    
                    local nearbyPeds = lib.getNearbyPeds(zone.coords, zone.radius)
                    if nearbyPeds then
                        for i = 1, #nearbyPeds do
                            local pedData = nearbyPeds[i]
                            local ped = pedData.ped
                            
                            if not IsPedAPlayer(ped) and not IsEntityDead(ped) and IsPedInAnyVehicle(ped, false) then
                                local vehicle = GetVehiclePedIsIn(ped, false)
                                SetBlockingOfNonTemporaryEvents(ped, true)
                                    
                                if zone.speed == 0 then
                                    if GetEntitySpeed(vehicle) > 0.1 then
                                        TaskVehicleTempAction(ped, vehicle, 27, 1000)
                                    end
                                else
                                    SetDriveTaskCruiseSpeed(ped, (zone.speed / 3.6))
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- ox_lib Menu // ox_lib menu
function createNewZoneDialog()
    local coords = GetEntityCoords(cache.ped)
    
    local input = lib.inputDialog(_U('dialog_title'), {
        {type = 'input', label = _U('dialog_msg'), description = _U('dialog_msg_desc'), required = true},
        {type = 'select', label = _U('dialog_radius'), options = Config.RadiusOptions, required = true, default = "50"},
        {type = 'input', label = _U('dialog_reason'), description = _U('dialog_reason_desc'), required = true},
        {type = 'slider', label = _U('dialog_speed'), description = _U('dialog_speed_desc'), min = 0, max = 30, step = 5, default = 0},
        {type = 'select', label = _U('dialog_duration'), options = Config.TimeOptions, required = true},
    })

    if not input then return end

    TriggerServerEvent('rcrpzone:startZone', {
        coords = coords,
        message = input[1],
        radius = tonumber(input[2]),
        reason = input[3],
        speed = tonumber(input[4]),
        duration = tonumber(input[5])
    })
end

function openZoneMenu(jobData)
    lib.registerContext({
        id = 'sperrzone_main_menu',
        title = jobData.menuTitle,
        options = {
            {
                title = _U('create_zone'),
                description = _U('create_zone_desc'),
                icon = 'location-dot',
                onSelect = createNewZoneDialog
            },
            {
                title = _U('delete_spec_zones'),
                description = _U('delete_spec_zones_desc'),
                icon = 'list',
                onSelect = openSpecificDeleteMenu
            }
        }
    })
    lib.showContext('sperrzone_main_menu')
end

-- Tastenbelegung // keybind (F6)
lib.addKeybind({
    name = 'open_sperrzone_menu',
    description = _U('keybind_desc'),
    defaultKey = 'F6',
    onPressed = function()
        local job = ESX.GetPlayerData().job.name
        if Config.AuthorizedJobs[job] then
            openZoneMenu(Config.AuthorizedJobs[job])
        else
            lib.notify({title = _U('access_denied'), type = 'error'})
        end
    end
})

-- Events
RegisterNetEvent('rcrpzone:createClientZone', function(zoneId, coords, data, jobColor, creatorJob)
    local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, data.radius + 0.0)
    SetBlipHighDetail(radiusBlip, true)
    SetBlipColour(radiusBlip, jobColor)
    SetBlipAlpha(radiusBlip, 128)

    local speedZone = AddRoadNodeSpeedZone(coords.x, coords.y, coords.z, data.radius + 0.0, (data.speed or 0) / 3.6, false)
    currentZones[zoneId] = { 
        radiusBlip = radiusBlip, 
        speedZone = speedZone,
        coords = coords,
        radius = data.radius + 0.0,
        speed = data.speed,
        location = getStreetAndDistrict(coords),
        reason = data.reason,
        creatorJob = creatorJob
    }

    SetTimeout(data.duration * 60000, function()
        removeZone(zoneId)
    end)
end)

RegisterNetEvent('rcrpzone:removeSpecificZone', function(zoneId)
    removeZone(zoneId)
end)

-- GTA Native Notify
RegisterNetEvent('rcrpzone:showNativeNotify', function(icon, title, subtitle, text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostMessagetext(icon, icon, true, 1, title, subtitle)
    EndTextCommandThefeedPostTicker(false, false)
end)

-- Wenn CUSTOM nicht konfiguriert wurde (server.lua), DEBUG Nachricht in Konsole // if CUSTOM has not been configured (server.lua), a DEBUG message is displayed in the console
RegisterNetEvent('rcrpzone:debugNotify', function(title, message)
    print("^1CUSTOM NOTIFY TRIGGERED^0")
    print("^4Titel:^0 " .. title)
    print("^4Nachricht:^0 " .. message)
    print("^4Info:^0 RCRP-restrictedzone | server.lua: Custom notification called but not configured!")
end)
