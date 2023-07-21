IDEV = {}

IDEV.Keys = {
    -- Maximum distance within which the player can interact with the vehicle keys
    MaxDistance = 4.0,

    ControlKey = 'x', -- Key to use the keys on vehicle, NOTE: if you change this, you need to clear your fivem cache (client cache) since controls are cached into FiveM

    -- Whether to enable key animation and key prop when using the key outside the vehicle
    EnableKeyAnimationOutside = true,

    -- Whether the player can use the keys inside the vehicle
    EnableKeyUsageInsideVehicle = false,

    -- Whether to enable key animation when using the keys inside the vehicle (only works if EnableKeyUsageInsideVehicle is true)
    EnableKeyAnimationInsideVehicle = false,

    -- Whether to enable light animation for the vehicle when locking/unlocking
    EnableLightAnimationOutside = true,

    -- Whether to enable light animation for the vehicle when locking/unlocking inside the vehicle (only works if EnableLightAnimationOutside is true)
    EnableLightAnimationInsideVehicle = false,
}
