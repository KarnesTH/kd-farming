local config = require 'config.shared'

local blips = {}
local zones = {}
local progressBar = lib.progressCircle
local pickedTrees = {}
local spawnedItems = {}
local spawnedProps = {}

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

local function isTreePicked(treeId, respawnTime)
    if pickedTrees[treeId] then
        local currentTime = GetGameTimer()
        if currentTime - pickedTrees[treeId] < (respawnTime * 1000) then
            return true
        else
            pickedTrees[treeId] = nil
        end
    end
    return false
end

local function markTreeAsPicked(treeId)
    pickedTrees[treeId] = GetGameTimer()
end

local function isItemCollected(itemId, respawnTime)
    if spawnedItems[itemId] then
        local currentTime = GetGameTimer()
        if currentTime - spawnedItems[itemId] < (respawnTime * 1000) then
            return true
        else
            spawnedItems[itemId] = nil
        end
    end
    return false
end

local function markItemAsCollected(itemId)
    spawnedItems[itemId] = GetGameTimer()
end

local function generateRandomPositionInZone(zoneCoords, zoneSize, zoneRotation)
    local halfSizeX = zoneSize.x / 2
    local halfSizeY = zoneSize.y / 2
    
    local randomX = math.random(-halfSizeX, halfSizeX)
    local randomY = math.random(-halfSizeY, halfSizeY)
    
    local rotatedX = randomX * math.cos(math.rad(zoneRotation)) - randomY * math.sin(math.rad(zoneRotation))
    local rotatedY = randomX * math.sin(math.rad(zoneRotation)) + randomY * math.cos(math.rad(zoneRotation))
    
    return vec3(
        zoneCoords.x + rotatedX,
        zoneCoords.y + rotatedY,
        zoneCoords.z
    )
end

local function createTargetsForTrees(location, pickableType, pickableConfig)
    if location.pickableLocations then
        for i, treeCoords in pairs(location.pickableLocations) do
            local treeId = location.name .. '_' .. pickableType .. '_' .. i
            
            if config.useTarget then
                exports.ox_target:addBoxZone({
                    coords = treeCoords,
                    size = vec3(1.5, 1.5, 4.0),
                    rotation = 0,
                    debug = config.debugPoly,
                    options = {
                        {
                            name = 'kd_farming_' .. treeId,
                            icon = "fas fa-hand-paper",
                            label = locale('ui.pick_label'):gsub('{item}', pickableConfig.label),
                            onSelect = function()
                                if not isTreePicked(treeId, pickableConfig.respawnTime) then
                                    TriggerEvent("kd-farming:pickFruit", {type = pickableType, config = pickableConfig, treeId = treeId})
                                else
                                    lib.notify({
                                        title = locale('titles.tree'),
                                        description = locale('notifications.tree_recently_picked'),
                                        type = 'error'
                                    })
                                end
                            end,
                            canInteract = function()
                                return not isTreePicked(treeId, pickableConfig.respawnTime)
                            end
                        }
                    }
                })
            else
                local point = lib.points.new({
                    coords = treeCoords,
                    distance = 2.0,
                                         onEnter = function()
                         if not isTreePicked(treeId, pickableConfig.respawnTime) then
                             lib.showTextUI(locale('ui.pick_tree'):gsub('{item}', pickableConfig.label), {
                                 position = "right-center"
                             })
                         else
                             lib.showTextUI(locale('ui.tree_recently_picked_ui'), {
                                 position = "right-center"
                             })
                         end
                     end,
                    onExit = function()
                        lib.hideTextUI()
                    end,
                    nearby = function()
                        if IsControlJustReleased(0, 38) then
                            if not isTreePicked(treeId, pickableConfig.respawnTime) then
                                TriggerEvent("kd-farming:pickFruit", {type = pickableType, config = pickableConfig, treeId = treeId})
                            else
                                lib.notify({
                                    title = locale('titles.tree'),
                                    description = locale('notifications.tree_recently_picked'),
                                    type = 'error'
                                })
                            end
                        end
                    end
                })
            end
        end
    end
end

local function spawnCollectableItems(location, collectableType, collectableConfig)
    if location.collectable and collectableConfig.maxSpawns then
        for i = 1, collectableConfig.maxSpawns do
            local itemCoords = generateRandomPositionInZone(
                location.zone.coords,
                location.zone.size,
                location.zone.rotation
            )
            
            local itemId = location.name .. '_' .. collectableType .. '_' .. i
            
            local propHash = GetHashKey(collectableConfig.prop)
            RequestModel(propHash)
            
            while not HasModelLoaded(propHash) do
                Wait(1)
            end
            
            local prop = CreateObject(propHash, itemCoords.x, itemCoords.y, itemCoords.z, false, false, false)
             PlaceObjectOnGroundProperly(prop)
             SetEntityAsMissionEntity(prop, true, true)
             FreezeEntityPosition(prop, true)
             SetModelAsNoLongerNeeded(propHash)
             
             local finalCoords = GetEntityCoords(prop)
             spawnedProps[itemId] = {
                 prop = prop,
                 coords = finalCoords,
                 point = nil
             }
             
             if config.useTarget then
                 exports.ox_target:addBoxZone({
                     coords = finalCoords,
                     size = vec3(1.0, 1.0, 2.0),
                     rotation = 0,
                     debug = config.debugPoly,
                     options = {
                         {
                             name = 'kd_farming_' .. itemId,
                             icon = "fas fa-hand-paper",
                             label = locale('ui.collect_label'):gsub('{item}', collectableConfig.label),
                             onSelect = function()
                                 if not isItemCollected(itemId, collectableConfig.respawnTime) then
                                     TriggerEvent("kd-farming:collectItem", {type = collectableType, config = collectableConfig, itemId = itemId})
                                 else
                                     lib.notify({
                                         title = locale('titles.item'),
                                         description = locale('notifications.item_recently_collected'),
                                         type = 'error'
                                     })
                                 end
                             end,
                             canInteract = function()
                                 return not isItemCollected(itemId, collectableConfig.respawnTime)
                             end
                         }
                     }
                 })
             else
                 local point = lib.points.new({
                     coords = finalCoords,
                     distance = 2.0,
                                           onEnter = function()
                          if not isItemCollected(itemId, collectableConfig.respawnTime) then
                              lib.showTextUI(locale('ui.collect_item'):gsub('{item}', collectableConfig.label), {
                                  position = "right-center"
                              })
                          else
                              lib.showTextUI(locale('ui.item_recently_collected_ui'), {
                                  position = "right-center"
                              })
                          end
                      end,
                     onExit = function()
                         lib.hideTextUI()
                     end,
                     nearby = function()
                         if IsControlJustReleased(0, 38) then
                             if not isItemCollected(itemId, collectableConfig.respawnTime) then
                                 TriggerEvent("kd-farming:collectItem", {type = collectableType, config = collectableConfig, itemId = itemId})
                             else
                                 lib.notify({
                                     title = locale('titles.item'),
                                     description = locale('notifications.item_recently_collected'),
                                     type = 'error'
                                 })
                             end
                         end
                     end
                 })
                 spawnedProps[itemId].point = point
             end
        end
    end
end

local function createLocationZone(location)
    if location.zone then
        local zone = lib.zones.box({
            coords = location.zone.coords,
            size = location.zone.size,
            rotation = location.zone.rotation,
            debug = config.debugPoly,
            onEnter = function()
                
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })
        zones[#zones + 1] = zone
        
        if location.pickable then
            for pickableType, pickableConfig in pairs(location.pickable) do
                createTargetsForTrees(location, pickableType, pickableConfig)
            end
        end
        
        if location.collectable then
            for collectableType, collectableConfig in pairs(location.collectable) do
                spawnCollectableItems(location, collectableType, collectableConfig)
            end
        end
    end
end

RegisterNetEvent('kd-farming:pickFruit', function(data)
    local pickableType = data.type
    local pickableConfig = data.config
    local treeId = data.treeId
    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, false)
    
    if progressBar({
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
        
        markTreeAsPicked(treeId)
        
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
end)

RegisterNetEvent('kd-farming:collectItem', function(data)
    local collectableType = data.type
    local collectableConfig = data.config
    local itemId = data.itemId
    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, false)
    
    if progressBar({
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
        
        markItemAsCollected(itemId)
        
         if spawnedProps[itemId] and spawnedProps[itemId].prop then
             SetEntityVisible(spawnedProps[itemId].prop, false, false)
         end
         
         SetTimeout(collectableConfig.respawnTime * 1000, function()
             if spawnedProps[itemId] and spawnedProps[itemId].prop then
                 SetEntityVisible(spawnedProps[itemId].prop, true, false)
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
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
         for _, propData in pairs(spawnedProps) do
             if propData.prop and DoesEntityExist(propData.prop) then
                 DeleteEntity(propData.prop)
             end
             if propData.point then
                 propData.point:remove()
             end
         end
        
        for _, blip in pairs(blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)

CreateThread(function()
    for _, location in pairs(config.locations) do
        createBlip(location)
        createLocationZone(location)
    end
end)