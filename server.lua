ESX = exports["es_extended"]:getSharedObject()
local activeZones = {}
local _U = i18n

-- Benachrichtigung an alle Clients. // notification to all clients.
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
        TriggerClientEvent('esx:showNotification', -1, "~b~" .. title .. "~s~:\n" .. message)
    
    elseif Config.NotifyType == "ox" then
        TriggerClientEvent('ox_lib:notify', -1, {
            title = title,
            description = message,
            type = 'inform',
            icon = 'shield-halved',
            duration = 10000
        })
        
    elseif Config.NotifyType == "gta" then
        TriggerClientEvent('rcrpzone:showNativeNotify', -1, icon, title, subject, message)
        
    elseif Config.NotifyType == "custom" then       
        -- Füge dein eigenes Event hinzu! // add your own Event!
        -- Beispiel für okokNotify // Example for okokNotify:
        -- TriggerClientEvent('okokNotify:Alert', -1, title, message, 10000, 'info')
        
        TriggerClientEvent('rcrpzone:debugNotify', -1, title, message)
        print("RCRP-zone | server.lua: Custom Notification called, but not configured!")
    end
end

-- Events
RegisterNetEvent('rcrpzone:startZone', function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not Config.AuthorizedJobs[xPlayer.job.name] then return end

    local zoneId = math.random(1000, 9999)
    local coords = GetEntityCoords(GetPlayerPed(source))
    activeZones[zoneId] = {id = zoneId, coords = coords}

    local reason = data.grund or "Unbekannt"
    local msgContent = data.nachricht .. _U('dispatch_reason_prefix', reason)

    sendGlobalNotification(
        _U('dispatch_title'), 
        _U('dispatch_subject'), 
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
        _U('dispatch_title'), 
   	    _U('dispatch_update'), 
        _U('dispatch_cleared'), 
        "CHAR_CALL911"
    )
end)
