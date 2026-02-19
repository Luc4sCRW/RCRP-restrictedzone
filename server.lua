ESX = exports["es_extended"]:getSharedObject()
local activeZones = {}

-- Hilfsfunktion zum Entfernen von GTA-Farbcodes
local function cleanText(text)
    if not text then return "" end
    return text:gsub("~%a~", "")
end

local function sendGlobalNotification(title, subject, message, icon)
    if Config.NotifyType == "bulletin" then
        TriggerClientEvent('bulletin:sendAdvanced', -1, {
            title    = "~b~" .. title .. "~s~",
            subject  = subject,
            message  = message,
            icon     = icon,
            timeout  = 10000,
            position = "bottomleft"
        })
        
    elseif Config.NotifyType == "esx" then
        TriggerClientEvent('esx:showNotification', -1, cleanText(title) .. ":\n" .. cleanText(message)) -- if u want to, make it with color for esx
    
    elseif Config.NotifyType == "ox" then
        TriggerClientEvent('ox_lib:notify', -1, {
            title = cleanText(title),
            description = cleanText(message),
            type = 'inform',
            icon = 'shield-halved',
            duration = 10000
        })
        
    elseif Config.NotifyType == "gta" then
        TriggerClientEvent('rcrpzone:showNativeNotify', -1, icon, title, subject, message)
        
    elseif Config.NotifyType == "custom" then       
        -- add your own Export!
        -- Example for okokNotify:
        -- TriggerClientEvent('okokNotify:Alert', -1, title, message, 10000, 'info')
        
        TriggerClientEvent('rcrpzone:debugNotify', -1, title, message)
        print("RCRP-zone | server.lua: Custom Notification aufgerufen, aber nicht konfiguriert!")
    end
end

RegisterNetEvent('rcrpzone:startZone', function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not Config.AuthorizedJobs[xPlayer.job.name] then return end

    local zoneId = math.random(1000, 9999)
    local coords = GetEntityCoords(GetPlayerPed(source))
    activeZones[zoneId] = {id = zoneId, coords = coords}

    local msgContent = data.nachricht .. "\nGrund: ~y~" .. data.grund .. "~s~"

    sendGlobalNotification(
        "Los Santos Police Department", 
        "SPERRZONE ERRICHTET", 
        msgContent, 
        "CHAR_CALL911"
    )

    TriggerClientEvent('rcrpzone:createClientZone', -1, zoneId, coords, data)
end)

RegisterNetEvent('rcrpzone:stopZone', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not Config.AuthorizedJobs[xPlayer.job.name] then return end

    activeZones = {}
    TriggerClientEvent('rcrpzone:clearAllZones', -1)

    sendGlobalNotification(
        "Los Santos Police Department", 
        "UPDATE", 
        "Alle aktiven Sperrzonen wurden soeben aufgehoben.", 
        "CHAR_CALL911"
    )
end)
