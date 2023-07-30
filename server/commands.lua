local function addMessage(target, type, text)
    local red <const> = {255, 0, 0}
    local green <const> = {0, 255, 0}
    TriggerClientEvent('chat:addMessage', target, {
        color = type == 'error' and red or green,
        multiline = true,
        args = {'Keys System', text}
    })
end

lib.locale()


ESX.RegisterCommand({'addkey'}, 'admin', function(xPlayer, args, showError)
    local player <const> = GetPlayerPed(args.playerId)
    if not (player) or not (IsPedAPlayer(player)) then
        return addMessage(xPlayer.source, 'error', locale('command_player_not_found'))
    end
    local vehicle <const> = GetVehiclePedIsIn(player, false)
    if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
        return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
    end
    if (args.blockKey < 0) or (args.blockKey > 1) then
        return addMessage(xPlayer.source, 'error', locale('command_block_key_invalid'))
    end
    local success <const> = AddKeyToPlayerFromVehicle(vehicle, args.playerId, args.count, args.blockKey == 1 and true or false)
    if not (success) then
        return addMessage(xPlayer.source, 'error', locale('command_key_not_found'))
    end
    addMessage(xPlayer.source, 'success', locale('command_key_has_been_added'))
end, false, {help = locale('command_addkeytoplayer'), arguments = {
    {name = 'playerId', help = locale('command_help_playerID'), type = 'number'},
    {name = 'count', help = locale('command_help_count'), type = 'number'},
    {name = 'blockKey', help = locale('command_help_block_key'), type = 'number'}
}})

ESX.RegisterCommand({'removekey'}, 'admin', function(xPlayer, args, showError)
    local player <const> = GetPlayerPed(args.playerId)
    if not (player) or not (IsPedAPlayer(player)) then
        return addMessage(xPlayer.source, 'error', locale('command_player_not_found'))
    end
    local vehicle <const> = GetVehiclePedIsIn(player, false)
    if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
        return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
    end
    local success <const> = RemoveKeyFromPlayerFromVehicle(args.playerId, vehicle)
    if not (success) then
        return addMessage(xPlayer.source, 'error', locale('command_key_not_found'))
    end
    addMessage(xPlayer.source, 'success', locale('command_key_has_been_removed'))
end, false, {help = locale('command_removekeytoplayer'), arguments = {
    {name = 'playerId', help = locale('command_help_playerID'), type = 'number'},
}})

-- ESX.RegisterCommand({'removeallkeys'}, 'admin', function(xPlayer, args, showError)
--     local player <const> = GetPlayerPed(args.target)
--     local vehicle <const> = GetVehiclePedIsIn(player, false)
--     if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
--         return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
--     end
--     local success <const>, keyCount <const>, plate <const> = RemoveKeysFromPlayersFromVehicle(vehicle)
--     if not (success) then
--         return addMessage(xPlayer.source, 'error', locale('command_key_not_found'))
--     end
--     addMessage(xPlayer.source, 'success', locale('command_keyremove_players'):format(keyCount, plate))
-- end, false, {help = locale('command_removekeytoplayers'), arguments = {
--     {name = 'plate', help = locale('command_help_playerID'), type = 'string'},
-- }})

ESX.RegisterCommand({'removeallkeys'}, 'admin', function(xPlayer, args, showError)
    local success, keyCount <const> = RemoveKeysFromPlayersFromPlate(args.plate)
    if not (success) then
        return addMessage(xPlayer.source, 'error', locale('command_key_not_found'))
    end
    addMessage(xPlayer.source, 'success', locale('command_keyremove_players'):format(keyCount, args.plate))
end, false, {help = locale('command_removekeytoplayers'), arguments = {
    {name = 'plate', help = locale('command_plate_help'), type = 'string'},
}})

-- ESX.RegisterCommand({'getvehiclekeys'}, 'admin', function(xPlayer, args, showError)
--     local player <const> = GetPlayerPed(args.playerId)
--     if not (player) or not (IsPedAPlayer(player)) then
--         return addMessage(xPlayer.source, 'error', locale('command_player_not_found'))
--     end
--     local vehicle <const> = GetVehiclePedIsIn(player, false)
--     if not (DoesEntityExist(vehicle)) or (vehicle == 0) then
--         return addMessage(xPlayer.source, 'error', locale('command_not_in_a_vehicle'))
--     end
--     local count <const> = GetKeyCountFromVehicle(vehicle)
--     if not (count) then
--         return addMessage(xPlayer.source, 'error', locale('command_error'))
--     end
--     addMessage(xPlayer.source, 'success', locale('command_keycount_result_target'):format(count))
-- end, false, {help = locale('command_getkeycountfromplayer'), arguments = {
--     {name = 'playerId', help = locale('command_help_playerID'), type = 'number'},
-- }})

ESX.RegisterCommand({'getvehiclekeys'}, 'admin', function(xPlayer, args, showError)
    local count <const> = GetKeyCountFromPlate(args.plate)
    if not (count) then
        return addMessage(xPlayer.source, 'error', locale('command_error'))
    end
    addMessage(xPlayer.source, 'success', locale('command_keycount_result_plate'):format(count, args.plate))
end, false, {help = locale('command_getkeycountfromplayer'), arguments = {
    {name = 'plate', help = locale('command_plate_help'), type = 'string'},
}})