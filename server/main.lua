local config = require 'config.shared'

RegisterNetEvent('kd-farming:giveFruit', function(itemName, amount)
    local source = source
    
    local item = config.items[itemName]
    if not item then
        print(string.format('[kd-farming] Invalid item: %s', itemName))
        return
    end
    
    local success = exports.ox_inventory:AddItem(source, item.item, amount)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('titles.inventory_full'),
            description = locale('notifications.inventory_full'),
            type = 'error'
        })
    end
end) 