local inventory <const> = exports.ox_inventory
local ESX <const> = exports.es_extended:getSharedObject()

--[[
    Checks if the player owns a key item.
    Returns true if the player has at least one key item, otherwise false.
    If the player doesn't have any keys in their inventory, we don't need to continue the script.
]]
local function doesPlayerOwnAKey()
    return inventory:GetItemCount('keys', nil, false)
end

--[[
    Performs an animation for using a key fob.
]]
local function performKeyFobAnimation()
    local animationDict <const> = "anim@mp_player_intmenu@key_fob@"

    while not HasAnimDictLoaded(animationDict) do
        RequestAnimDict(animationDict)
        Wait(0)
    end

    TaskPlayAnim(cache.ped, animationDict, "fob_click", 3.0, 3.0, -1, 48, 0.0, false, false, false)

    local modelHash <const> = GetHashKey("lr_prop_carkey_fob")
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(100)
        RequestModel(modelHash)
    end

    local playerCoords <const> = GetEntityCoords(cache.ped)
    local prop = CreateObject(modelHash, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.14, 0.03, -0.01, 24.0, -152.0, 164.0, true, true, false, false, 1, true)

    Wait(1000)
    DeleteObject(prop)
    ClearPedTasks(cache.ped)
end

--[[
    Activates the vehicle's light animation.
]]
local function activateVehicleLightAnimation(vehicle)
    for _ = 1, 2 do
        SetVehicleLights(vehicle, 2)
        Wait(150)
        SetVehicleLights(vehicle, 0)
        Wait(150)
    end
end

--[[
    Displays a notification message based on the vehicle's lock status.
    If 'isLocked' is true, it shows a success notification for a locked vehicle.
    If 'isLocked' is false, it shows a success notification for an unlocked vehicle.
]]
local function displayNotification(isLocked)
    local title, description
    if isLocked then
        title = 'Vehicle Locked'
        description = 'You have locked your vehicle'
    else
        title = 'Vehicle Unlocked'
        description = 'You have unlocked your vehicle'
    end

    lib.notify({
        title = title,
        description = description,
        type = 'success'
    })
end

--[[
    Registers a key mapping and command for handling vehicle keys.
    Key mapping: "keys" - Binds the action to the "x" key on the keyboard.
    Command: "keys" - Triggers a server event to check the player's key ownership.
    Only players who own a key can execute the command.
]]
RegisterKeyMapping("keys", "Vehicle Key", "keyboard", IDEV.Keys.ControlKey)

RegisterCommand("keys", function()
    if not doesPlayerOwnAKey() then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent("idev_keys:check")
end, false)

--[[
    Event handler for vehicle animation and notification related to key actions.
    When triggered, it gets the closest vehicle based on the player's coordinates.
    If the distance to the vehicle is greater than the configured distance limit, it returns.
    It retrieves the lock state of the vehicle and performs animation and notification accordingly.
]]
RegisterNetEvent('idev_keys:anim:vehicle', function()
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then
        -- Well if this event is executed when EnableKeyUsageInsideVehicle is false and a player is in a vehicle, it's surely a modder who's trying to exploit events.
        print("Weird?") 
        return
    end
    local closestVehicle <const>, distance <const> = ESX.Game.GetClosestVehicle(cache.coords)
    if (distance > IDEV.Keys.MaxDistance) then return end

    local vehicleState <const> = Entity(closestVehicle).state
    
    if (IDEV.Keys.EnableKeyAnimationOutside) then
        CreateThread(performKeyFobAnimation)
    end
    if (IDEV.Keys.EnableLightAnimationOutside) then
        activateVehicleLightAnimation(closestVehicle)
    end

    if (cache.vehicle) and (IDEV.Keys.EnableLightAnimationInsideVehicle) then
        activateVehicleLightAnimation(cache.vehicle)
    end

    if (cache.vehicle) and (IDEV.Keys.EnableKeyAnimationInsideVehicle) then
        CreateThread(performKeyFobAnimation)
    end

    PlayVehicleDoorCloseSound(closestVehicle, vehicleState.isLocked and 0 or nil)
    displayNotification(vehicleState.isLocked)
end)
