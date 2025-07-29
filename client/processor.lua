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

-- Process item function
local function processItem(recipe, recipeIndex)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(processingPed)
    
    -- Check distance
    if #(playerCoords - pedCoords) > config.settings.maxProcessingDistance then
        lib.notify({
            title = locale('titles.processing_error'),
            description = locale('processor.too_far'),
            type = 'error'
        })
        return
    end
    
    -- Check if player has required items
    local hasItems = lib.callback.await('kd-farming:checkIngredients', false, recipe.ingredients)
    
    if not hasItems then
        lib.notify({
            title = locale('titles.processing_error'),
            description = locale('processor.not_enough_ingredients'),
            type = 'error'
        })
        return
    end
    
    -- Start processing animation
    TaskStartScenarioInPlace(playerPed, config.settings.processingAnimation, 0, false)
    
    if lib.progressCircle({
        duration = recipe.duration,
        label = locale('processor.processing_label'):gsub('{item}', recipe.label),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
    }) then
        -- Process the item
        local success = lib.callback.await('kd-farming:processItem', false, recipeIndex)
        
        if success then
            lib.notify({
                title = locale('titles.processing_success'),
                description = locale('processor.processing_success'):gsub('{item}', recipe.label),
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
    
    -- Build menu options from recipes
    for i, recipe in ipairs(pedConfig.recipes) do
        local ingredientsText = ''
        local canCraft = true
        
        for item, amount in pairs(recipe.ingredients) do
            local itemLabel = locale('info.' .. item) or item
            
            -- Check if player has enough of this ingredient
            local hasItem = lib.callback.await('kd-farming:checkSingleIngredient', false, item, amount)
            local statusIcon = hasItem and '✔️' or '✖️​'
            
            if not hasItem then
                canCraft = false
            end
            
            -- Add icon for each ingredient
            local itemIcon = '🍊' -- Default
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
        
        -- Use default icon for menu items
        local icon = 'fas fa-cogs' -- Default processing icon
        
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
    
    -- Set ped scenario
    if config.settings.pedScenario then
        TaskStartScenarioInPlace(processingPed, config.settings.pedScenario, 0, true)
    end
    
    SetModelAsNoLongerNeeded(pedHash)
end

-- Create processing zone
local function createProcessingZone()
    local pedConfig = config.processingPed
    
    if config.settings.useTarget then
        -- Create target zone for the ped
        exports.ox_target:addLocalEntity(processingPed, {
            {
                name = 'farming_processor',
                icon = 'fas fa-cogs',
                label = 'Mit Verarbeiter sprechen',
                distance = config.settings.interactionDistance,
                onSelect = function()
                    openProcessingMenu()
                end
            }
        })
    else
        -- Create lib.points for interaction
        local point = lib.points.new({
            coords = pedConfig.coords,
            distance = config.settings.interactionDistance,
            onEnter = function()
                lib.showTextUI('[E] Mit Verarbeiter sprechen', {
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