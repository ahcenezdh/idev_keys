Inventory = exports.ox_inventory
local ESX <const> = exports.es_extended:getSharedObject()
local SetVehicleDoorsLocked <const> = SetVehicleDoorsLocked
local GetVehicleNumberPlateText <const> = GetVehicleNumberPlateText

--[[
    Removes leading and trailing white spaces from a string.
    Uses pattern matching to match and extract the non-whitespace content of the string.
    Credit: https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
]]
function TrimString(string)
    return string:match("^%s*(.-)%s*$")
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
    local player <const> = ESX.GetPlayerFromId(source)
    if not (player) then return end

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
    if not (keyItem) then
        return print("Not your vehicle")
    end

    local doorState <const> = GetVehicleDoorLockStatus(vehicle)
    local isLocked
    if (doorState == 0) then
        SetVehicleDoorsLocked(vehicle, 2)
        isLocked = true
    else
        SetVehicleDoorsLocked(vehicle, 1)
        isLocked = false
    end

    Entity(vehicle).state.isLocked = isLocked
    TriggerClientEvent('idev_keys:anim:vehicle', source)
end)
