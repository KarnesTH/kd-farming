local config = require 'config.processor'

-- Helper function to format ingredients text
local function getIngredientsText(ingredients)
    local text = {}
    for item, amount in pairs(ingredients) do
        table.insert(text, amount .. 'x ' .. item)
    end
    return table.concat(text, ', ')
end

-- Check if player has required ingredients
lib.callback.register('kd-farming:checkIngredients', function(source, ingredients)
    local player = source
    local hasAllItems = true
    
    for item, amount in pairs(ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(player, item)
        if itemCount < amount then
            hasAllItems = false
            break
        end
    end
    
    return hasAllItems
end)

-- Check if player has a single ingredient
lib.callback.register('kd-farming:checkSingleIngredient', function(source, item, amount)
    local player = source
    local itemCount = exports.ox_inventory:GetItemCount(player, item)
    return itemCount >= amount
end)

-- Get item count for a single item
lib.callback.register('kd-farming:getItemCount', function(source, item)
    local player = source
    return exports.ox_inventory:GetItemCount(player, item)
end)

-- Process item (remove ingredients and give output) with batch support
lib.callback.register('kd-farming:processItem', function(source, recipeIndex, batchCount)
    local player = source
    local pedConfig = config.processingPed
    local recipe = pedConfig.recipes[recipeIndex]
    
    if not recipe then
        return false
    end
    
    batchCount = batchCount or 1
    
    -- Check if player has enough ingredients for all batches
    for item, amount in pairs(recipe.ingredients) do
        local requiredAmount = amount * batchCount
        local itemCount = exports.ox_inventory:GetItemCount(player, item)
        if itemCount < requiredAmount then
            return false
        end
    end
    
    -- Remove ingredients for all batches
    for item, amount in pairs(recipe.ingredients) do
        local totalAmount = amount * batchCount
        local removed = exports.ox_inventory:RemoveItem(player, item, totalAmount)
        if not removed then
            return false
        end
    end
    
    -- Add output items for all batches
    local totalOutput = recipe.count * batchCount
    local added = exports.ox_inventory:AddItem(player, recipe.name, totalOutput, recipe.metadata)
    if not added then
        -- Rollback: return ingredients if output couldn't be added
        for item, amount in pairs(recipe.ingredients) do
            local totalAmount = amount * batchCount
            exports.ox_inventory:AddItem(player, item, totalAmount)
        end
        return false
    end
    
    return true
end) 