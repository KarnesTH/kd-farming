local config = require 'config.shop'
local shopPed = nil
local shopZone = nil

-- Open ox_inventory shop
local function openShop()
    exports.ox_inventory:openInventory('shop', { type = 'farming_shop' })
end

-- Create shop ped
local function createShopPed()
    local pedConfig = config.shopPed
    local pedHash = GetHashKey(pedConfig.model)
    
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end
    
    shopPed = CreatePed(4, pedHash, pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z - 1.0, pedConfig.pedHeading, false, true)
    
    SetEntityHeading(shopPed, pedConfig.pedHeading)
    FreezeEntityPosition(shopPed, true)
    SetEntityInvincible(shopPed, true)
    SetBlockingOfNonTemporaryEvents(shopPed, true)
    
    if pedConfig.pedScenario then
        TaskStartScenarioInPlace(shopPed, pedConfig.pedScenario, 0, true)
    end
    
    SetModelAsNoLongerNeeded(pedHash)
end

-- Create shop zone
local function createShopZone()
    local pedConfig = config.shopPed
    
    if config.settings.useTarget then
        exports.ox_target:addLocalEntity(shopPed, {
            {
                name = 'farming_shop',
                icon = 'fas fa-shopping-cart',
                label = locale('shop.shop_label'),
                distance = config.settings.interactionDistance,
                onSelect = function()
                    openShop()
                end
            }
        })
    else
        local point = lib.points.new({
            coords = pedConfig.coords,
            distance = config.settings.interactionDistance,
            onEnter = function()
                lib.showTextUI(locale('ui.shop_label'), {
                    position = "right-center"
                })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function()
                if IsControlJustReleased(0, 38) then
                    openShop()
                end
            end
        })
        
        shopZone = point
    end
end

-- Create shop blip
local function createShopBlip()
    local pedConfig = config.shopPed
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

-- Initialize shop
local function initializeShop()
    if not config.enabled then
        return nil
    end
    
    createShopPed()
    createShopZone()
    return createShopBlip()
end

-- Cleanup shop
local function cleanupShop()
    if shopPed and DoesEntityExist(shopPed) then
        DeleteEntity(shopPed)
    end
    
    if shopZone then
        shopZone:remove()
    end
end

-- Export functions
return {
    initializeShop = initializeShop,
    cleanupShop = cleanupShop
} 