local config = require 'config.shared'

local blips = {}
local zones = {}
local progressBar = lib.progressCircle
local pickedTrees = {}

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
                            lib.showTextUI(locale('ui.pick_tree'):gsub('{item}', pickableConfig.label))
                        else
                            lib.showTextUI(locale('ui.tree_recently_picked_ui'))
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
        
        for pickableType, pickableConfig in pairs(location.pickable) do
            createTargetsForTrees(location, pickableType, pickableConfig)
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

CreateThread(function()
    for _, location in pairs(config.locations) do
        createBlip(location)
        createLocationZone(location)
    end
end)