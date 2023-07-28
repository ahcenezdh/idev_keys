local inventory <const> = exports.ox_inventory
local ESX <const> = exports.es_extended:getSharedObject()
local player <const> = LocalPlayer?.state

lib.locale()
inventory:displayMetadata('plate', locale('plate_tooltip'))


--[[
    Performs an animation for using a key fob.
]]
local function performKeyFobAnimation()
    local animationDict <const> = 'anim@mp_player_intmenu@key_fob@'

    lib.requestAnimDict(animationDict)

    TaskPlayAnim(cache.ped, animationDict, 'fob_click', 3.0, 3.0, -1, 48, 0.0, false, false, false)

    local modelHash <const> = GetHashKey('lr_prop_carkey_fob')
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
    local title <const> = isLocked and locale('title_vehicle_locked') or locale('title_vehicle_unlocked')
    local description <const> = isLocked and locale('vehicle_locked') or locale('vehicle_unlocked')

    lib.notify({
        title = title,
        description = description,
        type = 'success'
    })
end

--[[
    Registers a key mapping and command for handling vehicle keys.
    Key mapping: "keys" - Binds the action to the "x" key by default on the keyboard.
    Command: "keys" - Triggers a server event to check the player's key ownership.
]]
RegisterKeyMapping('keys', locale('key_mapping'), 'keyboard', IDEV.Keys.ControlKey)

RegisterCommand('keys', function()
    if not (inventory:GetItemCount('keys', nil, false)) then return end
    if (player.invBusy) or (player.invOpen) then return end
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then return end
    TriggerServerEvent('idev_keys:check')
end, false)

--[[
    Event handler for vehicle animation and notification related to key actions.
    When triggered, it gets the closest vehicle based on the player's coordinates.
    If the distance to the vehicle is greater than the configured distance limit, it returns.
    It retrieves the lock state of the vehicle and performs animation and notification accordingly.
]]
RegisterNetEvent('idev_keys:anim:vehicle', function()
    if not (IDEV.Keys.EnableKeyUsageInsideVehicle) and (cache.vehicle) then
        print("Weird?")
        return
    end
    
    local closestVehicle, distance = ESX.Game.GetClosestVehicle(cache.coords)
    if (distance > IDEV.Keys.MaxDistance) then return end
    
    local vehicleState <const> = Entity(closestVehicle)?.state
    
    if (IDEV.Keys.EnableKeyAnimationOutside) then
        CreateThread(performKeyFobAnimation)
    end
    
    if (IDEV.Keys.EnableLightAnimationOutside) or (cache.vehicle and IDEV.Keys.EnableLightAnimationInsideVehicle) then
        activateVehicleLightAnimation(closestVehicle)
    end
    
    if (cache.vehicle) and (IDEV.Keys.EnableKeyAnimationInsideVehicle) then
        CreateThread(performKeyFobAnimation)
    end
    
    local doorsSound <const> = vehicleState.isLocked and PlayVehicleDoorCloseSound(closestVehicle, 0) or PlayVehicleDoorOpenSound(closestVehicle, 0)
    displayNotification(vehicleState.isLocked)
end)
