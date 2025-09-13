ESX = nil
local isInSafeZone = false
local playerJob = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while playerJob == nil do
        ESX.PlayerData = ESX.GetPlayerData()
        playerJob = ESX.PlayerData.job.name
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local inZone = false

        for _, zone in pairs(Config.SafeZones) do
            local dist = #(coords - vector3(zone.x, zone.y, zone.z))
            if dist < zone.radius then
                inZone = true
                if not isInSafeZone then
                    isInSafeZone = true
                    TriggerEvent("safezone:entered")
                end
            end
        end

        if not inZone and isInSafeZone then
            isInSafeZone = false
            TriggerEvent("safezone:exited")
        end

        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInSafeZone and not Config.AllowedJobs[playerJob] then
            DisablePlayerFiring(PlayerPedId(), true)
        end
    end
end)

RegisterNetEvent("safezone:entered")
AddEventHandler("safezone:entered", function()
    TriggerEvent('esx:showNotification', 'You have entered the SafeZone!')
    SendNUIMessage({ action = "showHUD", inZone = true })
end)

RegisterNetEvent("safezone:exited")
AddEventHandler("safezone:exited", function()
    TriggerEvent('esx:showNotification', 'You have left the SafeZone!')
    SendNUIMessage({ action = "showHUD", inZone = false })
end)
