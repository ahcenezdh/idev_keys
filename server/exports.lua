local function checkPlate(plate)
    if (type(plate) ~= 'string') then
        PrintErrorMessage('The plate is not a string', 'AddKeyToPlayerWithoutVehicle')
        return
    end
    if (#plate > 8) then
        PrintErrorMessage('The plate is too long', 'AddKeyToPlayerWithoutVehicle')
        return
    end
    return TrimString(plate)
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
    local metadata <const> = { plate = checkPlate(identifier) }
    local canAddKey <const> = Inventory:CanCarryItem(target, 'keys', count, metadata, true)
    if not (canAddKey) then
        PrintErrorMessage("The player does not have enough space in their inventory", "addKeyToPlayerInternal")
        return false
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
        print(response)
        PrintErrorMessage("Error adding the key to the player", "addKeyToPlayerInternal")
        return false
    end
    
    return true
end

--[[ 
    Adds a key to a player's inventory from a vehicle.
    Parameters:
    vehicle: The vehicle entity from which the key will be associated.
    target: The player ID to whom the key will be added.
    count: The number of keys to add.
    blockKey: If true, blocks the key from being moved from the inventory of the player.
    Returns true if the key was successfully added, false otherwise.
]]
function AddKeyToPlayerFromVehicle(vehicle, target, count, blockKey)
    if not (DoesEntityExist(vehicle) )then
        PrintErrorMessage("The vehicle does not exist", "AddKeyToPlayerFromVehicle")
        return false
    end
    
    if (type(target) ~= "number") then
        PrintErrorMessage("The target is not a number", "AddKeyToPlayerFromVehicle")
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return addKeyToPlayerInternal(plate, target, count, blockKey)
end

--[[ 
    Adds a key to a player's inventory using the license plate directly.
    Parameters:
    plate: The license plate (identifier) of the key.
    target: The player ID to whom the key will be added.
    count: The number of keys to add.
    blockKey: If true, blocks the key from being moved from the inventory of the player.
    Returns true if the key was successfully added, false otherwise.
]]
function AddKeyToPlayerWithoutVehicle(plate, target, count, blockKey)
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
    local metadata <const> = { plate = checkPlate(identifier) }
    local keyCount <const> = Inventory:GetItemCount(target, 'keys', metadata, true)
    if (keyCount <= 0) then
        PrintErrorMessage('The target doesn\'t have any keys with those metadata', 'removeKeyFromPlayerInternal')
        return false
    end
    local removeSuccess <const>, response <const> = Inventory:RemoveItem(target, 'keys', keyCount, metadata)
    if not (removeSuccess) then
        print(response)
        PrintErrorMessage('Error removing the key from the player [ID: ' .. target .. ']', 'removeKeyFromPlayerInternal')
        return false
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
        PrintErrorMessage("The vehicle does not exist", "RemoveKeyFromPlayerFromVehicle")
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
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
    if (type(target) ~= 'number') then
        return PrintErrorMessage('The target is not a number', 'RemoveKeyFromPlayerWithoutVehicle')
    end
    return removeKeyFromPlayerInternal(target, plate)
end

local function getKeysCountInternal(identifier)
    local metadata <const> = {plate = checkPlate(identifier)}
    local keyCount = 0
    for _, players in ipairs(GetPlayers()) do
        keyCount += Inventory:GetItemCount(tonumber(players), 'keys', metadata, true)
    end
    return keyCount
end

function GetKeyCountFromVehicle(vehicle)
    if not (DoesEntityExist(vehicle) or vehicle == 0) then
        PrintErrorMessage("The vehicle does not exist", "GetKeyCountFromVehicle")
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return getKeysCountInternal(plate)
end

function GetKeyCountFromPlate(plate)
    return getKeysCountInternal(plate)
end

local function removeKeyFromPlayersInternal(identifier)
    local success = true
    local metadata <const> = {plate = checkPlate(identifier)}
    for _, players in ipairs(GetPlayers()) do
        local keyCount <const> = Inventory:GetItemCount(tonumber(players), 'keys', metadata, true)
        if (keyCount > 0) then
            local removeSuccess <const>, response <const> = Inventory:RemoveItem(tonumber(players), 'keys', keyCount, metadata)
            if not (removeSuccess) then
                print(response)
                PrintErrorMessage('Error removing the key from the player [ID: ' .. players .. ']', 'removeKeyFromPlayersInternal')
                success = false
            end
        end
    end
    return success
end

function RemoveKeysFromPlayersFromVehicle(vehicle)
    if not (DoesEntityExist(vehicle) or vehicle == 0) then
        PrintErrorMessage("The vehicle does not exist", "RemoveKeysFromPlayersFromVehicle")
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return removeKeyFromPlayersInternal(plate)
end

function RemoveKeysFromPlayersFromPlate(plate)
    return removeKeyFromPlayersInternal(plate)
end