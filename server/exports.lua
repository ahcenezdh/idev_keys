local function PrintErrorMessage(message, functionName)
    print("idev_keys:", message, "function:", functionName)
    return false
end

local function AddKeyToPlayerInternal(identifier, target, count)
    local metadata <const> = { plate = identifier }
    local canAddKey <const> = Inventory:CanCarryItem(target, 'keys', count, metadata, true)
    
    if not (canAddKey) then
        return PrintErrorMessage("The player does not have enough space in their inventory", "AddKeyToPlayerInternal")
    end
    
    
    local success <const>, response <const> = Inventory:AddItem(target, 'keys', count, metadata, true)
    
    if not (success) then
        local returnError <const> = PrintErrorMessage("Error adding the key to the player", "AddKeyToPlayerInternal")
        print(response)
        return returnError
    end
    
    return true
end

function AddKeyToPlayerFromVehicle(vehicle, target, count)
    if not (DoesEntityExist(vehicle)) then
        return PrintErrorMessage("The vehicle does not exist", "AddKeyToPlayerFromVehicle")
    end
    
    if (type(target) ~= "number") then
        return PrintErrorMessage("The target is not a number", "AddKeyToPlayerFromVehicle")
    end
    
    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    return AddKeyToPlayerInternal(plate, target, count)
end

function AddKeyToPlayerWithoutVehicle(plate, target, count)
    plate = TrimString(plate)
    return AddKeyToPlayerInternal(plate, target, count)
end

--[[
    Removes the keys associated with a specific vehicle from all players.
    It checks if the vehicle exists and retrieves its license plate.
    Then, it iterates through all active players and removes the corresponding keys from their inventories.
    Returns true if the keys were successfully removed, or false otherwise.
    In case of any errors, an error message is printed to the console.
]]
function RemoveKeysFromPlayersInternal(identifier)
    local metadata <const> = { plate = identifier }
    local success = true
    
    for _, player in pairs(GetActivePlayers()) do
        local keyCount = Inventory:GetItemCount(player, 'keys', metadata, true)
        
        if not (keyCount) or (keyCount) <= 0 then return end
        
        local removeSuccess, response = Inventory:RemoveItem(player, 'keys', keyCount, metadata, true)
        
        if not (removeSuccess) then
            PrintErrorMessage("Error removing the key from the player", "RemoveKeysFromPlayers")
            print(response)
            success = false
            break
        end
    end
    
    return success
end

function RemoveKeysFromPlayersFromVehicle(vehicle)
    if not (DoesEntityExist(vehicle)) then
        return PrintErrorMessage("The vehicle does not exist", "RemoveKeysFromPlayersFromVehicle")
    end
    
    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    return RemoveKeysFromPlayersInternal(plate)
end

function RemoveKeysFromPlayersWithoutVehicle(plate)
    plate = TrimString(plate)
    return RemoveKeysFromPlayersInternal(plate)
end

--[[
    TODO: Create temporary key (going to delete the key for example after 1 hour)
    TODO: Block key for a specific time (the key will not work during this time)
    TODO: Block user to give the key or drop it (useful agaisn't people who are trying to duplicate keys)
]]