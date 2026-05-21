ESX = exports["es_extended"]:getSharedObject()
local activeZones = {}
local _U = i18n

-- Benachrichtigung an alle Clients // notification to all clients
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
    local jobName = xPlayer.job.name
    if not Config.AuthorizedJobs[jobName] then return end
    
    local jobConfig = Config.AuthorizedJobs[jobName]
    local zoneId = math.random(1000, 9999)
    local coords = GetEntityCoords(GetPlayerPed(source))

    activeZones[zoneId] = {id = zoneId, coords = coords, creatorJob = jobName}

    local reason = data.reason or "Unknown"
    local msgContent = data.message .. _U('dispatch_reason_prefix', reason)

    sendGlobalNotification(
        jobConfig.label, 
        _U('dispatch_subject'), 
        msgContent, 
        jobConfig.icon
    )

    TriggerClientEvent('rcrpzone:createClientZone', -1, zoneId, coords, data, jobConfig.blipColor, jobName)
end)

-- Zonen löschen // delete zones
RegisterNetEvent('rcrpzone:stopSpecificZone', function(zoneId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local jobName = xPlayer.job.name
    
    local myJobConfig = Config.AuthorizedJobs[jobName]
    if not myJobConfig then return end

    if activeZones[zoneId] then
        local zoneCreatorJob = activeZones[zoneId].creatorJob

        -- Sicherheitscheck bezüglich Job // job security check
        if not myJobConfig.deleteOther and zoneCreatorJob ~= jobName then
            TriggerClientEvent('ox_lib:notify', source, {
                title = myJobConfig.menuTitle,
                description = "Du bist nicht berechtigt, diese Zone zu löschen!",
                type = 'error'
            })
            return
        end

        local originalJobConfig = Config.AuthorizedJobs[zoneCreatorJob] or myJobConfig
        
        activeZones[zoneId] = nil
        TriggerClientEvent('rcrpzone:removeSpecificZone', -1, zoneId)
        
        sendGlobalNotification(
            originalJobConfig.label, 
            _U('dispatch_update'), 
            _U('dispatch_cleared2'),
            originalJobConfig.icon
        )
    end
end)
