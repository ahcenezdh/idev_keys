--[[ 
    Prints an error message with the given message and function name 
    and returns false.
]]
local function printErrorMessage(message, functionName)
    if (IDEV.Keys.Debug) then
        print("idev_keys:", message, "function:", functionName)
    end
    return false
end

--[[ 
    Checks if two tables are equal by comparing their keys and values.
    Returns true if they are equal, false otherwise.
]]
local function areTablesEqual(table1, table2)
    if #table1 ~= #table2 then
        return false
    end

    for key, value in pairs(table1) do
        if table2[key] ~= value then
            return false
        end
    end

    return true
end

--[[ 
    Adds a key to a player's inventory.
    Parameters:
    identifier: The identifier of the key (license plate).
    target: The player ID to whom the key will be added.
    count: The number of keys to add.
    blockKey: If true, blocks the key from being used immediately after adding.
    Returns true if the key was successfully added, false otherwise.
]]
local function addKeyToPlayerInternal(identifier, target, count, blockKey)
    local metadata <const> = { plate = identifier }
    local canAddKey <const> = Inventory:CanCarryItem(target, 'keys', count, metadata, true)
    if not (canAddKey) then
        return printErrorMessage("The player does not have enough space in their inventory", "addKeyToPlayerInternal")
    end

    local blockActions <const> = {
        ['give'] = true,
        ['move'] = true,
    }

    if (blockKey) then
        local hookId <const> = Inventory:registerHook('swapItems', function(payload)
            if (payload.fromSlot.name == 'keys') then
                if (blockActions[payload.action]) then
                    if (payload.fromType == 'player') then
                        if (areTablesEqual(payload.fromSlot.metadata, metadata)) then -- i'm using this if one day i want to add a description to the key or something else
                            return false
                        end
                    end
                end
            end
        end)
    end

    local success <const>, response <const> = Inventory:AddItem(target, 'keys', count, metadata)

    if not (success) then
        local returnError <const> = printErrorMessage("Error adding the key to the player", "addKeyToPlayerInternal")
        print(response)
        return returnError
    end
    
    return true
end

--[[ 
    Adds a key to a player's inventory from a vehicle.
    Parameters:
    vehicle: The vehicle entity from which the key will be associated.
    target: The player ID to whom the key will be added.
    count: The number of keys to add.
    blockKey: If true, blocks the key from being used immediately after adding.
    Returns true if the key was successfully added, false otherwise.
]]
function AddKeyToPlayerFromVehicle(vehicle, target, count, blockKey)
    if not (DoesEntityExist(vehicle) )then
        return printErrorMessage("The vehicle does not exist", "AddKeyToPlayerFromVehicle")
    end
    
    if (type(target) ~= "number") then
        return printErrorMessage("The target is not a number", "AddKeyToPlayerFromVehicle")
    end
    
    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    return addKeyToPlayerInternal(plate, target, count, blockKey)
end

--[[ 
    Adds a key to a player's inventory using the license plate directly.
    Parameters:
    plate: The license plate (identifier) of the key.
    target: The player ID to whom the key will be added.
    count: The number of keys to add.
    blockKey: If true, blocks the key from being used immediately after adding.
    Returns true if the key was successfully added, false otherwise.
]]
function AddKeyToPlayerWithoutVehicle(plate, target, count, blockKey)
    plate = TrimString(plate)
    return addKeyToPlayerInternal(plate, target, count, blockKey)
end

--[[ 
    Removes a key from a player's inventory based on the identifier (license plate) of the key.
    Parameters:
    target: The player ID from whom the key will be removed.
    identifier: The identifier (license plate) of the key to remove.
    Returns true if the key was successfully removed, false otherwise.
]]
local function removeKeyFromPlayerInternal(target, identifier)
    local metadata <const> = { plate = identifier }
    local keyCount <const> = Inventory:GetItemCount(target, 'keys', metadata, true)
    if not (keyCount) or (keyCount <= 0) then
        return printErrorMessage('The target doesn\'t have any keys with those metadata', 'removeKeyFromPlayerInternal')
    end
    local removeSuccess <const>, response <const> = Inventory:RemoveItem(target, 'keys', keyCount, metadata)
    if not (removeSuccess) then
        print(response)
        return printErrorMessage('Error removing the key from the player [ID: ' .. target .. ']', 'removeKeyFromPlayerInternal')
    end
    return true
end

--[[ 
    Removes a key from a player's inventory based on the vehicle from which the key is associated.
    Parameters:
    target: The player ID from whom the key will be removed.
    vehicle: The vehicle entity from which the key is associated.
    Returns true if the key was successfully removed, false otherwise.
]]
function RemoveKeyFromPlayerFromVehicle(target, vehicle)
    if not (DoesEntityExist(vehicle)) then
        return printErrorMessage("The vehicle does not exist", "RemoveKeyFromPlayerFromVehicle")
    end
    
    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    return removeKeyFromPlayerInternal(target, plate)
end

--[[ 
    Removes a key from a player's inventory using the license plate directly.
    Parameters:
    target: The player ID from whom the key will be removed.
    plate: The license plate (identifier) of the key to remove.
    Returns true if the key was successfully removed, false otherwise.
]]
function RemoveKeyFromPlayerWithoutVehicle(target, plate)
    plate = TrimString(plate)
    return removeKeyFromPlayerInternal(target, plate)
end

--[[ 
    Internal function to removes keys associated with a specific vehicle from all players' inventories.
    Parameters:
    identifier: The identifier (license plate) of the vehicle whose keys should be removed.
    Returns true if the keys were successfully removed from all players, false otherwise.
    Prints an error message to the console if any errors occur during the removal process.
]]
local function removeKeysFromPlayersInternal(identifier)
    local metadata <const> = { plate = identifier }
    local success = true
    
    for _, player in pairs(GetActivePlayers()) do
        local keyCount = Inventory:GetItemCount(player, 'keys', metadata, true)
        
        if not (keyCount) or (keyCount <= 0 )then return end
        
        local removeSuccess, response = Inventory:RemoveItem(player, 'keys', keyCount, metadata)
        
        if not (removeSuccess) then
            printErrorMessage('Error removing the key from the player [ID: ' .. player .. ']', 'removeKeysFromPlayers')
            print(response)
            success = false
        end
    end
    
    return success
end

--[[ 
    Removes keys associated with a specific vehicle from all players' inventories using the vehicle directly.
    Parameters:
    vehicle: The vehicle entity whose keys should be removed from all players.
    Returns true if the keys were successfully removed from all players, false otherwise.
    Prints an error message to the console if any errors occur during the removal process.
]]
function RemoveKeysFromPlayersFromVehicle(vehicle)
    if not (DoesEntityExist(vehicle)) then
        return printErrorMessage("The vehicle does not exist", "RemoveKeysFromPlayersFromVehicle")
    end
    
    local plate <const> = TrimString(GetVehicleNumberPlateText(vehicle))
    return removeKeysFromPlayersInternal(plate)
end

--[[ 
    Removes keys associated with a specific vehicle from all players' inventories using the license plate directly.
    Parameters:
    plate: The license plate (identifier) of the vehicle whose keys should be removed from all players.
    Returns true if the keys were successfully removed from all players, false otherwise.
    Prints an error message to the console if any errors occur during the removal process.
]]
function RemoveKeysFromPlayersWithoutVehicle(plate)
    plate = TrimString(plate)
    return removeKeysFromPlayersInternal(plate)
end
