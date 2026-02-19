local currentZones = {}

-- 1. Hilfsfunktion zum Löschen
local function removeZone(zoneId)
    if currentZones[zoneId] then
        if DoesBlipExist(currentZones[zoneId].radiusBlip) then 
            RemoveBlip(currentZones[zoneId].radiusBlip) 
        end
        RemoveRoadNodeSpeedZone(currentZones[zoneId].speedZone)
        currentZones[zoneId] = nil
    end
end

-- 2. Hintergrund-Loop für NPCs
CreateThread(function()
    while true do
        local sleep = 1500
        if next(currentZones) then
            sleep = 500
            local playerCoords = GetEntityCoords(cache.ped)
            
            for id, zone in pairs(currentZones) do
                if #(playerCoords - zone.coords) < (zone.radius + 50.0) then
                    local peds = GetGamePool('CPed')
                    
                    for i = 1, #peds do
                        local ped = peds[i]
                        if not IsPedAPlayer(ped) and not IsEntityDead(ped) and IsPedInAnyVehicle(ped, false) then
                            local pedCoords = GetEntityCoords(ped)
                            
                            if #(pedCoords - zone.coords) < zone.radius then
                                local vehicle = GetVehiclePedIsIn(ped, false)
                                SetBlockingOfNonTemporaryEvents(ped, true)
                                
                                if zone.speed == 0 then
                                    TaskVehicleTempAction(ped, vehicle, 27, 1500)
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

-- 3. Dialog-Funktion
function createNewZoneDialog()
    local coords = GetEntityCoords(cache.ped)
    
    local input = lib.inputDialog('Sperrzone errichten', {
        {type = 'input', label = 'Nachricht', description = 'Was wird im Dispatch angezeigt?', required = true},
        {type = 'select', label = 'Radius (Meter)', options = Config.RadiusOptions, required = true, default = "50"},
        {type = 'input', label = 'Grund', description = 'z.B. Schwerer Verkehrsunfall', required = true},
        {type = 'slider', label = 'NPC Geschwindigkeit', description = '0 = Stop, 30 = Normal', min = 0, max = 30, step = 5, default = 0},
        {type = 'select', label = 'Dauer (Minuten)', options = Config.TimeOptions, required = true},
    })

    if not input then return end

    TriggerServerEvent('rcrpzone:startZone', {
        coords = coords,
        nachricht = input[1],
        radius = tonumber(input[2]),
        grund = input[3],
        speed = tonumber(input[4]),
        duration = tonumber(input[5])
    })
end

-- 4. Menü-Funktion
function openZoneMenu()
    lib.registerContext({
        id = 'sperrzone_main_menu',
        title = 'Sperrzonen Management',
        options = {
            {
                title = 'Neue Sperrzone erstellen',
                description = 'Zone an aktueller Position erstellen',
                icon = 'location-dot',
                onSelect = createNewZoneDialog
            },
            {
                title = 'Alle Sperrzonen löschen',
                description = 'Alle aktiven Zonen für alle Spieler entfernen',
                icon = 'trash-can',
                onSelect = function()
                    TriggerServerEvent('rcrpzone:stopZone')
                end
            }
        }
    })
    lib.showContext('sperrzone_main_menu')
end

-- 5. Keybind
lib.addKeybind({
    name = 'open_sperrzone_menu',
    description = 'Sperrzonen Menü öffnen',
    defaultKey = 'F6',
    onPressed = function()
        local job = ESX.GetPlayerData().job.name
        if Config.AuthorizedJobs[job] then
            openZoneMenu()
        else
            if Config.NotifyType == "ox" then
                lib.notify({title = 'Zugriff verweigert', type = 'error'})
            else
                lib.notify({title = 'Zugriff verweigert', type = 'error'})
            end
        end
    end
})

-- 6. Events
RegisterNetEvent('rcrpzone:createClientZone', function(zoneId, coords, data)
    local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, data.radius + 0.0)
    SetBlipHighDetail(radiusBlip, true)
    SetBlipColour(radiusBlip, 1)
    SetBlipAlpha(radiusBlip, 128)

    local speedZone = AddRoadNodeSpeedZone(coords.x, coords.y, coords.z, data.radius + 0.0, (data.speed or 0) / 3.6, false)

    currentZones[zoneId] = { 
        radiusBlip = radiusBlip, 
        speedZone = speedZone,
        coords = coords,
        radius = data.radius + 0.0,
        speed = data.speed
    }

    SetTimeout(data.duration * 60000, function()
        removeZone(zoneId)
    end)
end)

RegisterNetEvent('rcrpzone:clearAllZones', function()
    for id, _ in pairs(currentZones) do
        removeZone(id)
    end
    currentZones = {}
end)

-- Event für Native GTA Notify
RegisterNetEvent('rcrpzone:showNativeNotify', function(icon, title, subtitle, text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostMessagetext(icon, icon, true, 1, title, subtitle)
    EndTextCommandThefeedPostTicker(false, false)
end)

-- Debug-Print für die F8 Konsole
RegisterNetEvent('rcrpzone:debugNotify', function(title, message)
    print("^1CUSTOM NOTIFY GETRIGGERT^0")
    print("^4Titel:^0 " .. title)
    print("^4Nachricht:^0 " .. message)
    print("^4Info:^0 RCRP-restrictedzone | server.lua: Custom Notification aufgerufen, aber nicht konfiguriert!")
end)
