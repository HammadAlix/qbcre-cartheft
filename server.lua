local QBCore = exports['qb-core']:GetCoreObject()

local activeMissions = {}
local usedLocations = {}
local cooldowns = {}

local function GetFreeCarLocation()
    local available = {}
    for _, loc in ipairs(Config.carlocations) do
        if not usedLocations[loc.name] then
            table.insert(available, loc)
        end
    end

    if #available == 0 then return nil end

    local chosen = available[math.random(#available)]
    usedLocations[chosen.name] = true
    return chosen
end

RegisterNetEvent('startmission:server')
AddEventHandler('startmission:server', function()
    local src = source
    local now = os.time()

    if cooldowns[src] and (now - cooldowns[src]) < Config.cooldown then
        local remaining = Config.cooldown - (now - cooldowns[src])
        TriggerClientEvent('chat:addMessage', src, {
        args = { 'You need to wait ' .. remaining .. ' seconds before starting another job.' }
    })
        return
    end

    if activeMissions[src] then
        TriggerClientEvent('activemessage', src, 'You already started a mission')
        return
    end

    local carloc = GetFreeCarLocation()
    if not carloc then
        TriggerClientEvent('chat:addMessage', src, {
        args = { 'No mission available right now. Try again later.' }
    })
        return
    end

    activeMissions[src] = { missionStarted = true, location = carloc.name }
    TriggerClientEvent('startmission:client', src, carloc)
end)

RegisterNetEvent('networkvehicle')
AddEventHandler('networkvehicle', function(netId)
    local src = source

    TriggerClientEvent('networkedvehicle', -1, netId)
end)

RegisterNetEvent('police:server:policeAlert')
AddEventHandler('police:server:policeAlert', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayers()
    local alertData = {
        coords = data.coords,
        info = data.info,
        alertCode = data.alertCode
    }

    local Players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(Players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == "police" then
            TriggerClientEvent('qb-police:client:PoliceAlert', playerId, alertData)
        end
    end
end)

RegisterNetEvent('finishmission')
AddEventHandler('finishmission', function()
    local src = source
    if activeMissions[src] then
        local locName = activeMissions[src].location
        if locName then
            usedLocations[locName] = nil
        end
        activeMissions[src] = nil
        cooldowns[src] = os.time()
    end
end)

RegisterNetEvent('givepayment')
AddEventHandler('givepayment', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddMoney(Config.moneytype, Config.payment, 'Succesful mission')
    end
end)


