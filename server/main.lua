local config = require 'config.shared'

-- Check if player has required item
local function hasItem(source, itemName)
    if not itemName then return true end
    
    local hasItem = exports.ox_inventory:GetItem(source, itemName, nil, true)
    return hasItem > 0
end

-- Give fruit to player
RegisterNetEvent('kd-farming:giveFruit', function(itemName, amount, requiredItem)
    local source = source
    
    if not hasItem(source, requiredItem) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('titles.missing_tool'),
            description = locale('notifications.missing_tool'):gsub('{tool}', requiredItem),
            type = 'error'
        })
        return
    end
    
    local success = exports.ox_inventory:AddItem(source, itemName, amount)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('titles.inventory_full'),
            description = locale('notifications.inventory_full'),
            type = 'error'
        })
    end
end) 