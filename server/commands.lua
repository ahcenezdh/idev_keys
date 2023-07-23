local function addMessage(target, type, text)
    local red <const> = {255, 0, 0}
    local green <const> = {0, 255, 0}
    TriggerClientEvent('chat:addMessage', target, {
        color = type == 'error' and red or green,
        multiline = true,
        args = {'Keys System', text}
    })
end

ESX.RegisterCommand({'addkeytovehicle'}, 'admin', function(xPlayer, args, showError)
    local player <const> = GetPlayerPed(xPlayer.source)
    local vehicle <const> = GetVehiclePedIsIn(player, false)
    if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
        addMessage(xPlayer.source, 'error', 'You are not in a vehicle')
        return
    end
    local success <const> = AddKeyToPlayerFromVehicle(vehicle, xPlayer.source, 1, false)
    if (success) then
        addMessage(xPlayer.source, 'success', 'The key for this vehicle has been added to your inventory')
    else
        addMessage(xPlayer.source, 'error', 'The key for this vehicle could not be added to your inventory. Please enable Debug in the config and looks in the server console for more information')
    end
end)

ESX.RegisterCommand({'removekeyfromvehicle'}, 'admin', function(xPlayer, args, showError)
    local player <const> = GetPlayerPed(xPlayer.source)
    local vehicle <const> = GetVehiclePedIsIn(player, false)
    if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
        addMessage(xPlayer.source, 'error', 'You are not in a vehicle')
        return
    end
    local success <const> = RemoveKeyFromPlayerFromVehicle(xPlayer.source, vehicle)
    if (success) then
        addMessage(xPlayer.source, 'success', 'The key for this vehicle has been removed from your inventory')
    else
        addMessage(xPlayer.source, 'error', 'The key for this vehicle could not be found/removed from your inventory. Please enable Debug in the config and looks in the server console for more information')
    end 
end)