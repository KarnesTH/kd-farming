local config = require 'config.shared'
local farming = require 'client.farming'
local processor = require 'client.processor'

local blips = {}
local zones = {}
local isProcessing = false

-- Create blips for farming locations
local function createBlip(location) 
    local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(blip, location.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, location.blip.scale)
    SetBlipColour(blip, location.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(location.blip.label)
    EndTextCommandSetBlipName(blip)
    blips[#blips + 1] = blip
end

-- Initialize farming locations
local function initializeFarming()
    for _, location in pairs(config.locations) do
        createBlip(location)
        local zone = farming.createLocationZone(location)
        if zone then
            zones[#zones + 1] = zone
        end
    end
end

-- Initialize processor
local function initializeProcessor()
    local processorBlip = processor.initializeProcessor()
    if processorBlip then
        blips[#blips + 1] = processorBlip
    end
end

-- Event handlers
RegisterNetEvent('kd-farming:pickFruit', function(data)
    if isProcessing then return end
    isProcessing = true
    
    local pickableType = data.type
    local pickableConfig = data.config
    local treeId = data.treeId
    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, false)
    
    if lib.progressCircle({
        duration = 5000,
        label = locale('ui.pick_label'):gsub('{item}', pickableConfig.label),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
    }) then
        local yield = math.random(pickableConfig.yield.min, pickableConfig.yield.max)
        
        TriggerServerEvent('kd-farming:giveFruit', pickableConfig.item, yield)
        
        farming.markTreeAsPicked(treeId)
        
        lib.notify({
            title = locale('titles.successfully_picked'),
            description = locale('notifications.successfully_picked'):gsub('{yield}', yield):gsub('{item}', pickableConfig.label),
            type = 'success'
        })
    else
        lib.notify({
            title = locale('titles.cancelled'),
            description = locale('notifications.cancelled'),
            type = 'error'
        })
    end
    
    ClearPedTasks(playerPed)
    isProcessing = false
end)

RegisterNetEvent('kd-farming:collectItem', function(data)
    if isProcessing then return end
    isProcessing = true
    
    local collectableType = data.type
    local collectableConfig = data.config
    local itemId = data.itemId
    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, false)
    
    if lib.progressCircle({
        duration = 4000,
        label = locale('ui.collect_label'):gsub('{item}', collectableConfig.label),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
    }) then
        local yield = math.random(collectableConfig.yield.min, collectableConfig.yield.max)
        
        TriggerServerEvent('kd-farming:giveFruit', collectableConfig.item, yield)
        
        farming.markItemAsCollected(itemId)
        
        if farming.spawnedProps[itemId] and farming.spawnedProps[itemId].prop then
            SetEntityVisible(farming.spawnedProps[itemId].prop, false, false)
            
            if farming.spawnedProps[itemId].point then
                lib.hideTextUI()
            end
        end
        
        SetTimeout(collectableConfig.respawnTime * 1000, function()
            if farming.spawnedProps[itemId] and farming.spawnedProps[itemId].prop then
                SetEntityVisible(farming.spawnedProps[itemId].prop, true, false)
            end
        end)
        
        lib.notify({
            title = locale('titles.successfully_collected'),
            description = locale('notifications.successfully_collected'):gsub('{yield}', yield):gsub('{item}', collectableConfig.label),
            type = 'success'
        })
    else
        lib.notify({
            title = locale('titles.cancelled'),
            description = locale('notifications.collection_cancelled'),
            type = 'error'
        })
    end
    
    ClearPedTasks(playerPed)
    isProcessing = false
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Cleanup blips
        for _, blip in pairs(blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        
        -- Cleanup processor
        processor.cleanupProcessor()
    end
end)

-- Initialize everything when resource starts
CreateThread(function()
    initializeFarming()
    initializeProcessor()
end)

