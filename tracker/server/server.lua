local data = {}

RegisterNetEvent('vh-tracker:remove', function(trackId)
    data[source] = nil
    TriggerClientEvent('vh-tracker:update', -1, data)
end)

RegisterNetEvent('vh-tracker:add', function(trackId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle
    if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 then vehicle = nil else vehicle = GetVehiclePedIsIn(GetPlayerPed(source)) end
    data[source] = {
        trackId = trackId,
        coords = xPlayer.getCoords(true),
        heading = GetEntityHeading(GetPlayerPed(source)),
        name = xPlayer.getName(),
        vehicle = vehicle
    }
    TriggerClientEvent('vh-tracker:update', -1, { [source] = data[source] })
    player = source
end)

Citizen.CreateThread(function()
    while true do
        local trackIdData = {} 
        
        for k, v in pairs(data) do
            if v == nil then 
                table.remove(data, k)
            else
                local xPlayer = ESX.GetPlayerFromId(k)
                
                if GetVehiclePedIsIn(GetPlayerPed(k)) == 0 then 
                    data[xPlayer.source].vehicle = nil 
                else 
                    data[xPlayer.source].vehicle = GetVehiclePedIsIn(GetPlayerPed(k)) 
                end

                data[xPlayer.source].coords = xPlayer.getCoords(true)
                data[xPlayer.source].heading = GetEntityHeading(GetPlayerPed(xPlayer.source))
                if v.trackId == data[k].trackId then
                    trackIdData[k] = v
                end
            end
        end

        TriggerClientEvent('vh-tracker:update', -1, trackIdData)
        
        Wait(70)
    end
end)
