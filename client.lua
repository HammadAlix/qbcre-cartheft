local QBCore = exports['qb-core']:GetCoreObject()
local startped, vehicle, waypoint, dropoff
local missionStarted = false
local hascar = false
local copslost = false
local dropoffMade = false
local wantedset = false


local function startnpc()
    local startmodel = GetHashKey('ig_siemonyetarian')
    RequestModel(startmodel)
    while not HasModelLoaded(startmodel) do
        Citizen.Wait(100)
    end
    startped = CreatePed(4, startmodel, -25.5, -1086.01, 25.57, 345.2, false, true)
    SetBlockingOfNonTemporaryEvents(startped, true)
    SetEntityInvincible(startped, true)
    FreezeEntityPosition(startped, true)
    TaskStartScenarioInPlace(startped, 'WORLD_HUMAN_AA_SMOKE', 0, false)
end

startnpc()

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local dist = #(GetEntityCoords(ped) - GetEntityCoords(startped))

        if dist < 5.0 then
            AddTextEntry('car-missions', 'Press ~INPUT_CONTEXT~ to start a car theft job')
            BeginTextCommandDisplayHelp('car-missions')
            EndTextCommandDisplayHelp(0, false, false, 20000)

            if IsControlJustReleased(0, 38) and not missionStarted then
                TriggerServerEvent('startmission:server')
            end
        end
    end
end)

RegisterNetEvent('startmission:client')
AddEventHandler('startmission:client', function(carloc)
    if missionStarted then return end

    missionStarted = true
    hascar, copslost, dropoffMade, wantedset = false, false, false, false
    vehicle, dropoff, waypoint = nil, nil, nil

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName('Go to the waypoint and steal the car! And bring a lockpick with you.')
    ThefeedSetNextPostBackgroundColor(140)
    EndTextCommandThefeedPostMessagetext("CHAR_SIMEON", "CHAR_SIMEON", false, 8, 'Simeon', 'Car location', true)
    EndTextCommandThefeedPostTicker(true, true)

    RequestModel(carloc.model)
    while not HasModelLoaded(carloc.model) do Wait(0) end
    vehicle = CreateVehicle(carloc.model, carloc.coords.x, carloc.coords.y, carloc.coords.z, carloc.coords.w, true, true)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(netId, true)
    NetworkSetNetworkIdDynamic(netId, false)
    SetNetworkIdCanMigrate(netId, true)
    TriggerServerEvent('networkvehicle', netId)

    waypoint = AddBlipForEntity(vehicle)
    SetBlipSprite(waypoint, 523)
    SetBlipColour(waypoint, 5)
    SetBlipRoute(waypoint, true)
    SetBlipRouteColour(waypoint, 5)

    Citizen.CreateThread(function()
        while missionStarted do
            Wait(0)
            local ped = PlayerPedId()

            if not hascar and IsPedInVehicle(ped, vehicle, false) then
                hascar = true
                if Config.AIcops then
                    SetPlayerWantedLevel(PlayerId(), Config.wantedlevel, false)
                    SetPlayerWantedLevelNow(PlayerId())
                    SetVehicleIsWanted(vehicle, true)
                    wantedset = true
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName('Someone called the cops on you. Make sure to bring the car after you lost the cops!')
                    ThefeedSetNextPostBackgroundColor(140)
                    EndTextCommandThefeedPostMessagetext("CHAR_SIMEON", "CHAR_SIMEON", false, 8, 'Simeon', 'Cops', true)
                    EndTextCommandThefeedPostTicker(true, true)
                else
                    TriggerServerEvent('police:server:policeAlert', {
                        coords = GetEntityCoords(ped),
                        info = 'Stolen vehicle',
                        alertCode = '10-90'
                    })
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName('Someone called the cops on you. Make sure to bring the car after you lost the cops!')
                    ThefeedSetNextPostBackgroundColor(140)
                    EndTextCommandThefeedPostMessagetext("CHAR_SIMEON", "CHAR_SIMEON", false, 8, 'Simeon', 'Cops', true)
                    EndTextCommandThefeedPostTicker(true, true)
                end
            end

            if wantedset and not IsPlayerWantedLevelGreater(PlayerId(), 0) then
                copslost = true
                wantedset = false
            end

            
                if hascar and not dropoffMade then
                    dropoffMade = true
                    dropoff = AddBlipForCoord(-31.99, -1090.88, 26.42)
                    SetBlipSprite(dropoff, 1)
                    SetBlipColour(dropoff, 5)
                    SetBlipRoute(dropoff, true)
                    SetBlipRouteColour(dropoff, 5)

                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName('Nice work! Bring the car to the garage.')
                    ThefeedSetNextPostBackgroundColor(140)
                    EndTextCommandThefeedPostMessagetext("CHAR_SIMEON", "CHAR_SIMEON", false, 8, 'Simeon', 'Dropoff', true)
                    EndTextCommandThefeedPostTicker(true, true)
                end

            if dropoffMade then
                local dist = #(GetEntityCoords(ped) - vector3(-31.64, -1091.19, 26.01))
                if dist < 5.0 then
                    AddTextEntry('car-missions', 'Press ~INPUT_CONTEXT~ to deliver the vehicle')
                    BeginTextCommandDisplayHelp('car-missions')
                    EndTextCommandDisplayHelp(0, false, false, 20000)

                    if IsControlJustReleased(0, 38) then
                        DeleteVehicle(vehicle)
                        ClearPedTasks(ped)
                        RemoveBlip(dropoff)
                        RemoveBlip(waypoint)

                        missionStarted = false
                        hascar, copslost, dropoffMade, wantedset = false, false, false, false
                        vehicle, dropoff, waypoint = nil, nil, nil

                        BeginTextCommandThefeedPost("STRING")
                        AddTextComponentSubstringPlayerName('Well done! You will receive your payment shortly')
                        ThefeedSetNextPostBackgroundColor(140)
                        EndTextCommandThefeedPostMessagetext("CHAR_SIMEON", "CHAR_SIMEON", false, 8, 'Simeon', 'Completed', true)
                        EndTextCommandThefeedPostTicker(true, true)

                        TriggerServerEvent('finishmission')
                        TriggerServerEvent('givepayment')
                        break
                    end
                end
            end
        end
    end)
end)




