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
        return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
    end
    local success <const> = AddKeyToPlayerFromVehicle(vehicle, xPlayer.source, 1, false)
    if (success) then
        addMessage(xPlayer.source, 'success', locale('command_key_has_been_added'))
    else
        addMessage(xPlayer.source, 'error', locale('command_key_not_found'))
    end
end)

ESX.RegisterCommand({'removekeyfromvehicle'}, 'admin', function(xPlayer, args, showError)
    local player <const> = GetPlayerPed(xPlayer.source)
    local vehicle <const> = GetVehiclePedIsIn(player, false)
    if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
        return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
    end
    local success <const> = RemoveKeyFromPlayerFromVehicle(xPlayer.source, vehicle)
    if (success) then
        addMessage(xPlayer.source, 'success', locale('command_key_has_been_removed'))
    else
        addMessage(xPlayer.source, 'error', locale('command_key_cant_be_removed'))
    end 
end)