-- Validates the license plate and trims any unnecessary characters.
-- If the license plate is not a string or is longer than 8 characters, an error message is printed.
local function validateAndTrimLicensePlate(licensePlate)
    if (type(licensePlate) ~= 'string') then
        PrintErrorMessage('The plate is not a string', 'addKeyToPlayerWithoutVehicle')
        return
    end
    if (#licensePlate > 8) then
        PrintErrorMessage('The plate is too long', 'addKeyToPlayerWithoutVehicle')
        return
    end
    return TrimString(licensePlate)
end

-- Checks if two tables are equal by comparing their keys and values.
-- Returns true if they are equal, false otherwise.
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

-- Internal function to add a key to a player's inventory.
local function addKeyToPlayerInternal(identifier, targetPlayer, keyCount, blockKey)
    local metadata <const> = { plate = validateAndTrimLicensePlate(identifier) }
    local canAddKey <const> = Inventory:CanCarryItem(targetPlayer, 'keys', keyCount, metadata, true)
    if not (canAddKey) then
        PrintErrorMessage('The player does not have enough space in their inventory', 'addKeyToPlayerInternal')
        return false
    end

    local blockActions <const> = {
        ['give'] = true,
        ['move'] = true,
    }

    if blockKey then
        local hookId <const> = Inventory:registerHook('swapItems', function(payload)
            if ((payload.fromSlot.name == 'keys') and (blockActions[payload.action]) and (payload.fromType == 'player') and( areTablesEqual(payload.fromSlot.metadata, metadata))) then
                return false
            end
        end)
    end

    local success <const>, response <const> = Inventory:AddItem(targetPlayer, 'keys', keyCount, metadata)

    if not (success) then
        print(response)
        PrintErrorMessage('Error adding the key to the player', 'addKeyToPlayerInternal')
        return false
    end
    
    return true
end

-- Adds a key to a player's inventory from a vehicle.
function AddKeyToPlayerFromVehicle(vehicle, targetPlayer, keyCount, blockKey)
    if not (DoesEntityExist(vehicle)) then
        PrintErrorMessage('The vehicle does not exist', 'AddKeyToPlayerFromVehicle')
        return false
    end
    
    if (type(targetPlayer) ~= 'number') then
        PrintErrorMessage('The target is not a number', 'AddKeyToPlayerFromVehicle')
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return addKeyToPlayerInternal(plate, targetPlayer, keyCount, blockKey)
end

-- Adds a key to a player's inventory using the license plate directly.
function AddKeyToPlayerWithoutVehicle(plate, targetPlayer, keyCount, blockKey)
    return addKeyToPlayerInternal(plate, targetPlayer, keyCount, blockKey)
end

-- Internal function to remove a key from a player's inventory based on the identifier (license plate) of the key.
local function removeKeyFromPlayerInternal(targetPlayer, identifier)
    local metadata <const> = { plate = validateAndTrimLicensePlate(identifier) }
    local keyCount <const> = Inventory:GetItemCount(targetPlayer, 'keys', metadata, true)
    if (keyCount <= 0) then
        PrintErrorMessage('The target doesn\'t have any keys with those metadata', 'removeKeyFromPlayerInternal')
        return false
    end
    local removeSuccess <const>, response <const> = Inventory:RemoveItem(targetPlayer, 'keys', keyCount, metadata)
    if not (removeSuccess) then
        print(response)
        PrintErrorMessage('Error removing the key from the player [ID: ' .. targetPlayer .. ']', 'removeKeyFromPlayerInternal')
        return false
    end
    return true
end

-- Removes a key from a player's inventory based on the vehicle from which the key is associated.
function RemoveKeyFromPlayerFromVehicle(targetPlayer, vehicle)
    if not (DoesEntityExist(vehicle)) then
        PrintErrorMessage('The vehicle does not exist', 'RemoveKeyFromPlayerFromVehicle')
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return removeKeyFromPlayerInternal(targetPlayer, plate)
end

-- Removes a key from a player's inventory using the license plate directly.
function RemoveKeyFromPlayerWithoutVehicle(targetPlayer, plate)
    if (type(targetPlayer) ~= 'number') then
        return PrintErrorMessage('The target is not a number', 'RemoveKeyFromPlayerWithoutVehicle')
    end
    return removeKeyFromPlayerInternal(targetPlayer, plate)
end

-- Internal function to get the count of keys associated with a given identifier.
local function getKeysCountInternal(identifier)
    local metadata <const> = {plate = validateAndTrimLicensePlate(identifier)}
    local keyCount = 0
    for _, player in ipairs(GetPlayers()) do
        keyCount = keyCount + Inventory:GetItemCount(tonumber(player), 'keys', metadata, true)
    end
    return keyCount
end

-- Returns the key count associated with a specific vehicle.
function GetKeyCountFromVehicle(vehicle)
    if not ((DoesEntityExist(vehicle)) or (vehicle == 0)) then
        PrintErrorMessage('The vehicle does not exist', 'GetKeyCountFromVehicle')
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    return getKeysCountInternal(plate)
end

-- Returns the key count associated with a specific license plate.
function GetKeyCountFromPlate(plate)
    return getKeysCountInternal(plate)
end

-- Internal function to remove keys associated with a given identifier from all players.
local function removeKeyFromPlayersInternal(identifier)
    local success = true
    local metadata <const> = {plate = validateAndTrimLicensePlate(identifier)}
    local count = 0
    for _, player in ipairs(GetPlayers()) do
        local keyCount = Inventory:GetItemCount(tonumber(player), 'keys', metadata, true)
        if (keyCount > 0) then
            local removeSuccess, response = Inventory:RemoveItem(tonumber(player), 'keys', keyCount, metadata)
            count = count + keyCount
            if not (removeSuccess) then
                print(response)
                PrintErrorMessage('Error removing the key from the player [ID: ' .. player .. ']', 'removeKeyFromPlayersInternal')
                success = false
            end
        end
    end
    return success, count
end

-- Removes keys associated with a specific vehicle from all players.
function RemoveKeysFromPlayersFromVehicle(vehicle)
    if not ((DoesEntityExist(vehicle)) or (vehicle == 0)) then
        PrintErrorMessage('The vehicle does not exist', 'RemoveKeysFromPlayersFromVehicle')
        return false
    end
    
    local plate <const> = GetVehicleNumberPlateText(vehicle)
    local success <const>, keyCount <const> = removeKeyFromPlayersInternal(plate)
    return success, keyCount
end

-- Removes keys associated with a specific license plate from all players.
function RemoveKeysFromPlayersFromPlate(plate)
    local success <const>, keyCount <const> = removeKeyFromPlayersInternal(plate)
    return success, keyCount
end

exports('AddKeyToPlayerFromVehicle', AddKeyToPlayerFromVehicle)
exports('AddKeyToPlayerWithoutVehicle', AddKeyToPlayerWithoutVehicle)
exports('RemoveKeyFromPlayerFromVehicle', RemoveKeyFromPlayerFromVehicle)
exports('RemoveKeyFromPlayerWithoutVehicle', RemoveKeyFromPlayerWithoutVehicle)
exports('GetKeyCountFromVehicle', GetKeyCountFromVehicle)
exports('GetKeyCountFromPlate', GetKeyCountFromPlate)
exports('RemoveKeysFromPlayersFromVehicle', RemoveKeysFromPlayersFromVehicle)
exports('RemoveKeysFromPlayersFromPlate', RemoveKeysFromPlayersFromPlate)