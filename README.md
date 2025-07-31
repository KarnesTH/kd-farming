# KD-Farming

A comprehensive farming system for the QBox Framework, allowing players to harvest, process, and sell a variety of fruits and vegetables.

## Features

- **Multiple Crop Types:** Apples, oranges, coffee, tomatoes, cucumbers, potatoes, and more
- **Interactive Zones:** Integration with ox_target or lib.points for harvesting and shop interactions
- **Respawn System:** Configurable cooldowns for each plant or tree
- **Randomized Yields:** Harvests provide random amounts within configurable ranges
- **Processing System:** Turn raw crops into processed goods (e.g., orange juice, coffee)
- **Batch Processing:** Process multiple items at once if you have enough ingredients
- **Required Tools:** Some crops require specific tools (e.g., shovel for potatoes)
- **Shop System:** Buy tools from a dedicated shop using the original ox_inventory shop UI
- **Easy Configuration:** Add new crops, recipes, or shop items by editing config files
- **Localization:** English and German language support

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- QBox Framework (for player data integration)

## Installation

1. Download or clone this repository into your server's `resources` folder.
2. Ensure `ox_lib`, `ox_inventory`, and QBox are installed and started before `kd-farming`.
3. Add `ensure kd-farming` to your `server.cfg` after the dependencies.
4. Configure crops, recipes, and shop items in the `config/` folder as needed.
5. Copy all images from `kd-farming/images` folder to your `ox-inventory/web/images` folder
6. Add this:
```lua
-- KD Farming
    ['apple'] = {
        label = 'Apple',
        weight = 200,
    },

    ['orange'] = {
        label = 'Orange',
        weight = 200,
    },
    ['tomato'] = {
        label = 'Tomato',
        weight = 200,
    },
    ['lettuce'] = {
        label = 'Lettuce',
        weight = 200,
    },
    ['coffee_bean'] = {
        label = 'Coffee Bean',
        weight = 200,
    },
    ['orange_juice'] = {
        label = 'Orange Juice',
        weight = 200,
    },
    ['apple_juice'] = {
        label = 'Apple Juice',
        weight = 200,
    },
    ['potato'] = {
        label = 'Potato',
        weight = 200,
    },
    ['shovel'] = {
        label = 'Shovel',
        weight = 1000,
    }
```
to your `ox-inventory/data/items.lua`
7. Optional add:
```lua
-- For drinks
---@type table<string, consumable>
drink = {
    -- other stuff --
    coffee = {
        min = 40,
        max = 50,
        anim = {
            clip = 'idle_c',
            dict = 'amb@world_human_drinking@coffee@male@idle_a',
            flag = 49
        },
        prop = {
            model = 'p_amb_coffeecup_01',
            bone = 28422,
            pos = {x = 0.0, y = 0.0, z = 0.0},
            rot = {x = 0.0, y = 0.0, z = 0.0}
        },
        stressRelief = {
            min = -10,
            max = -1
        },
    },
    orange_juice = {
        min = 60,
        max = 70,
        stressRelief = {
            min = 10,
            max = 15
        },
    },
    apple_juice = {
        min = 60,
        max = 70,
        stressRelief = {
            min = 10,
            max = 15
        },
    },
},
-- For food
---@type table<string, consumable>
food = {
    -- other stuff --
    apple = {
        min = 15,
        max = 25,
        stressRelief = {
            min = 1,
            max = 4
        },
    },
    orange = {
        min = 15,
        max = 25,
        stressRelief = {
            min = 1,
            max = 4
        },
    },
    tomato = {
        min = 15,
        max = 25,
        stressRelief = {
            min = 1,
            max = 4
        },
    },
},
```
to your `qbx-smallressources/qbx-consumables/config.lua` File.
8. Start your server and enjoy advanced farming gameplay!