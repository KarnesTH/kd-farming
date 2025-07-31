local config = require 'config.processor'
local processingPed = nil
local processingZone = nil

-- Helper function to format ingredients text
local function getIngredientsText(ingredients)
    local text = {}
    for item, amount in pairs(ingredients) do
        table.insert(text, amount .. 'x ' .. item)
    end
    return table.concat(text, ', ')
end

-- Calculate maximum possible batches based on available ingredients
local function calculateMaxBatches(recipe)
    local maxBatches = math.huge
    
    for item, amount in pairs(recipe.ingredients) do
        local itemCount = lib.callback.await('kd-farming:getItemCount', false, item)
        local possibleBatches = math.floor(itemCount / amount)
        maxBatches = math.min(maxBatches, possibleBatches)
    end
    
    return math.max(1, maxBatches)
end

-- Process item function with multiple batches support
local function processItem(recipe, recipeIndex)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(processingPed)
    
    if #(playerCoords - pedCoords) > config.settings.maxProcessingDistance then
        lib.notify({
            title = locale('titles.processing_error'),
            description = locale('processor.too_far'),
            type = 'error'
        })
        return
    end
    
    local hasItems = lib.callback.await('kd-farming:checkIngredients', false, recipe.ingredients)
    
    if not hasItems then
        lib.notify({
            title = locale('titles.processing_error'),
            description = locale('processor.not_enough_ingredients'),
            type = 'error'
        })
        return
    end
    
    local batchCount = 1 -- Default to 1 batch
    
    -- Only show input dialog if multiple processing is allowed
    if config.settings.allowMultipleProcessing then
        -- Calculate maximum possible batches
        local maxBatches = calculateMaxBatches(recipe)
        
        -- Show input dialog for batch selection
        local input = lib.inputDialog(locale('processor.batch_selection_title'), {
            {
                type = 'number',
                label = locale('processor.batch_count_label'),
                description = locale('processor.batch_count_description'):gsub('{max}', maxBatches):gsub('{item}', recipe.label),
                default = maxBatches,
                min = 1,
                max = maxBatches,
                required = true
            }
        })
        
        if not input or not input[1] then
            return -- User cancelled
        end
        
        batchCount = input[1]
        
        if batchCount < 1 or batchCount > maxBatches then
            lib.notify({
                title = locale('titles.processing_error'),
                description = locale('processor.invalid_batch_count'),
                type = 'error'
            })
            return
        end
    end
    
    TaskStartScenarioInPlace(playerPed, config.settings.processingAnimation, 0, false)
    
    if lib.progressCircle({
        duration = recipe.duration * batchCount,
        label = locale('processor.processing_label'):gsub('{item}', recipe.label) .. ' (x' .. batchCount .. ')',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            mouse = false,
            combat = true
        }
    }) then
        local success = lib.callback.await('kd-farming:processItem', false, recipeIndex, batchCount)
        
        if success then
            lib.notify({
                title = locale('titles.processing_success'),
                description = locale('processor.processing_success'):gsub('{item}', recipe.label) .. ' (x' .. batchCount .. ')',
                type = 'success'
            })
        else
            lib.notify({
                title = locale('titles.processing_error'),
                description = locale('processor.processing_failed'),
                type = 'error'
            })
        end
    else
        lib.notify({
            title = locale('titles.processing_cancelled'),
            description = locale('processor.processing_cancelled'),
            type = 'error'
        })
    end
    
    ClearPedTasks(playerPed)
end

-- Create processing menu
local function openProcessingMenu()
    local pedConfig = config.processingPed
    local options = {}
    
    for i, recipe in ipairs(pedConfig.recipes) do
        local ingredientsText = ''
        local canCraft = true
        
        for item, amount in pairs(recipe.ingredients) do
            local itemLabel = locale('info.' .. item) or item
            
            local hasItem = lib.callback.await('kd-farming:checkSingleIngredient', false, item, amount)
            local statusIcon = hasItem and '✔️' or '✖️​'
            
            if not hasItem then
                canCraft = false
            end
            
            local itemIcon = '🍊'
            if item == 'orange' then
                itemIcon = '🍊'
            elseif item == 'apple' then
                itemIcon = '🍎'
            elseif item == 'tomato' then
                itemIcon = '🍅'
            elseif item == 'lettuce' then
                itemIcon = '🥬'
            elseif item == 'coffee_bean' then
                itemIcon = '☕'
            end
            
            ingredientsText = ingredientsText .. itemIcon .. ' ' .. amount .. 'x ' .. itemLabel .. ' ' .. statusIcon .. ' '
        end
        
        local icon = 'fas fa-cogs'
        
        table.insert(options, {
            title = recipe.label,
            description = ingredientsText,
            icon = icon,
            onSelect = function()
                if canCraft then
                    processItem(recipe, i)
                else
                    lib.notify({
                        title = locale('titles.processing_error'),
                        description = locale('processor.not_enough_ingredients'),
                        type = 'error'
                    })
                end
            end
        })
    end
    
    lib.registerContext({
        id = 'farming_processor_menu',
        title = locale('processor.menu_title'),
        options = options
    })
    
    lib.showContext('farming_processor_menu')
end

-- Create the processing ped
local function createProcessingPed()
    local pedConfig = config.processingPed
    local pedHash = GetHashKey(pedConfig.model)
    
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end
    
    processingPed = CreatePed(4, pedHash, pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z - 1.0, pedConfig.coords.w or config.settings.pedHeading, false, true)
    
    SetEntityHeading(processingPed, pedConfig.coords.w or config.settings.pedHeading)
    FreezeEntityPosition(processingPed, true)
    SetEntityInvincible(processingPed, true)
    SetBlockingOfNonTemporaryEvents(processingPed, true)
    
    if config.settings.pedScenario then
        TaskStartScenarioInPlace(processingPed, config.settings.pedScenario, 0, true)
    end
    
    SetModelAsNoLongerNeeded(pedHash)
end

-- Create processing zone
local function createProcessingZone()
    local pedConfig = config.processingPed
    
    if config.settings.useTarget then
        exports.ox_target:addLocalEntity(processingPed, {
            {
                name = 'farming_processor',
                icon = 'fas fa-cogs',
                label = locale('processor.processing'),
                distance = config.settings.interactionDistance,
                onSelect = function()
                    openProcessingMenu()
                end
            }
        })
    else
        local point = lib.points.new({
            coords = pedConfig.coords,
            distance = config.settings.interactionDistance,
            onEnter = function()
                lib.showTextUI(locale('ui.processor_label'), {
                    position = "right-center"
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function()
                if IsControlJustReleased(0, 38) then
                    openProcessingMenu()
                end
            end
        })
        
        processingZone = point
    end
end

-- Create blip for processor
local function createProcessorBlip()
    local pedConfig = config.processingPed
    local blip = AddBlipForCoord(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z)
    SetBlipSprite(blip, pedConfig.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, pedConfig.blip.scale)
    SetBlipColour(blip, pedConfig.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(pedConfig.blip.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Initialize processor
local function initializeProcessor()
    createProcessingPed()
    createProcessingZone()
    return createProcessorBlip()
end

-- Cleanup processor
local function cleanupProcessor()
    if processingPed and DoesEntityExist(processingPed) then
        DeleteEntity(processingPed)
    end
    
    if processingZone then
        processingZone:remove()
    end
end

-- Export functions
return {
    initializeProcessor = initializeProcessor,
    cleanupProcessor = cleanupProcessor
} 