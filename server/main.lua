local config = require 'config.shared'

RegisterNetEvent('kd-farming:giveFruit', function(itemName, amount)
    local source = source
    
    local success = exports.ox_inventory:AddItem(source, itemName, amount)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('titles.inventory_full'),
            description = locale('notifications.inventory_full'),
            type = 'error'
        })
    end
end) 