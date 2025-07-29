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

-- Process item (remove ingredients and give output)
lib.callback.register('kd-farming:processItem', function(source, recipeIndex)
    local player = source
    local pedConfig = config.processingPed
    local recipe = pedConfig.recipes[recipeIndex]
    
    if not recipe then
        return false
    end
    
    for item, amount in pairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItemCount(player, item)
        if itemCount < amount then
            return false
        end
    end
    
    for item, amount in pairs(recipe.ingredients) do
        local removed = exports.ox_inventory:RemoveItem(player, item, amount)
        if not removed then
            return false
        end
    end
    
    local added = exports.ox_inventory:AddItem(player, recipe.name, recipe.count, recipe.metadata)
    if not added then
        for item, amount in pairs(recipe.ingredients) do
            exports.ox_inventory:AddItem(player, item, amount)
        end
        return false
    end
    
    return true
end) 