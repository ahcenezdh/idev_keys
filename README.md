# Vehicle Key System

![License](https://img.shields.io/badge/license-CC%20BY--NC-lightgrey.svg)

The Vehicle Key System is a project that provides a key-based vehicle access system using the vehicle's license plate as the identifier. It is designed to work with the `ox_lib` and `ox_inventory` dependencies, which are essential for its functionality.

## Features

- Lock and unlock vehicles using a unique key derived from the license plate.
- Integrates seamlessly with `ESX`, `ox_lib` and `ox_inventory` to ensure smooth performance.

## Documentation

For detailed information on how to use the Vehicle Key System, refer to our [documentation](https://your-documentation-link).

## Discord
<a href="https://discord.gg/nsyaGNt6jM">iDev & Co</a>

## Installation

1. Ensure you have the required dependencies, `ESX`, `ox_lib` and `ox_inventory`, installed in your project.

2. Download release `v1.0.0` from the [releases]()

3. Add the Vehicle Key System to your server resource folder.

4. start the script into the server.cfg (after ox_inventory, ox_lib and ESX).

5. Start your server, and the system will be ready to use!

## Adding the Item to ox_inventory

To enable the item "Vehicle Key" in `ox_inventory`, follow these steps:

1. Open the `ox_inventory/data/items.lua` file in your server.

2. Add the following code to the `items` table:

```lua
['keys'] = {
    label = "Vehicle Key",
    weight = 15,
},
```
