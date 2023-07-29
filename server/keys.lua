Inventory = exports.ox_inventory
ESX = exports.es_extended:getSharedObject()

--[[
    Removes leading and trailing white spaces from a string.
    Uses pattern matching to match and extract the non-whitespace content of the string.
    Credit: https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
]]
function TrimString(string)
    return string:match("^%s*(.-)%s*$")
end

--[[ 
    Prints an error message with the given message and function name 
    and returns false.
]]
function PrintErrorMessage(message, functionName)
    if not (IDEV.Keys.Debug) then return end
    print(GetCurrentResourceName(), message, 'function:', functionName)
end


--[[
    Event handler for checking vehicle key ownership and handling key actions on the server.
    When triggered, it retrieves the closest vehicle to the player and checks its proximity.
    If the vehicle is too far or doesn't exist, it returns.
    It then checks if the player has the corresponding key item and metadata for the vehicle.
    If not, it prints a message and returns.
    Next, it retrieves the lock status of the vehicle and performs the necessary door locking or unlocking.
    It updates the lock state of the vehicle and triggers a client event to play the vehicle animation.
]]
RegisterServerEvent('idev_keys:check')
AddEventHandler('idev_keys:check', function()
    local player <const> = ESX?.GetPlayerFromId(source)

    local closestVehicle <const>, distance <const> = ESX.OneSync.GetClosestVehicle(player.getCoords(true))
    if not (closestVehicle) or (distance > IDEV.Keys.MaxDistance) then return end

    local vehicle <const> = NetworkGetEntityFromNetworkId(closestVehicle)
    if not (vehicle) then return end

    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    local vehicleMetadata <const> = {
        plate = plate,
        -- TODO: add a description like "Model: Adder"
    }

    local keyItem <const> = Inventory:GetItem(source, 'keys', vehicleMetadata, true)
    if (keyItem <= 0) then
        return PrintErrorMessage('Not your vehicle', 'idev_keys:check')
    end

    local doorState <const> = GetVehicleDoorLockStatus(vehicle)
    local isLocked <const> = (doorState == 1) or (doorState == 0) -- based on fivem docs GetVehicleDoorLockStatus should return only 0 when the vehicle is unlocked because of the game who going to sync both state and use 0, however i couldn't get the 0 state so i added it here just in case
    SetVehicleDoorsLocked(vehicle, isLocked and 2 or 1)
    Entity(vehicle)?.state.isLocked = isLocked
    TriggerClientEvent('idev_keys:anim:vehicle', player.source)
    --[[
        Does animations are synced like that (i don't think so?)
        Maybe trigger the animation on the scope of the original client (players in the scope of the player who is using the key)
    ]]
end)
