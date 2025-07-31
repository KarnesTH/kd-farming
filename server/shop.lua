local config = require 'config.shop'

-- Register shop with ox_inventory
local function registerShop()
    local shopData = {
        name = config.shopPed.label,
        blip = {
            id = config.shopPed.blip.sprite,
            colour = config.shopPed.blip.color,
            scale = config.shopPed.blip.scale
        },
        inventory = {}
    }
    
    -- Convert items from config to ox_inventory format
    for itemKey, itemData in pairs(config.items) do
        table.insert(shopData.inventory, {
            name = itemData.name,
            price = itemData.price
        })
    end
    
    -- Register shop with ox_inventory
    exports.ox_inventory:RegisterShop('farming_shop', shopData)
end

-- Initialize shop on resource start
CreateThread(function()
    if config.enabled then
        registerShop()
    end
end) 