return {
    -- Enable/disable shop system
    enabled = true,
    
    -- Shop Ped Configuration
    shopPed = {
        name = 'farming_shop',
        coords = vec3(2564.54, 4680.05, 34.08),
        label = 'Farming Shop',
        model = 'a_m_m_farmer_01',
        blip = {
            label = 'Farming Shop',
            sprite = 52,
            color = 2,
            scale = 0.8,
        },
        zone = {
            coords = vec3(2564.54, 4680.05, 34.08),
            size = vec3(2.0, 2.0, 3.0),
            rotation = 0
        },
        pedHeading = 41.16,
        pedScenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    
    -- Available items in shop
    items = {
        shovel = {
            name = 'shovel',
            price = 150
        },
        hoe = {
            name = 'hoe',
            price = 150
        }
    },
    
    -- Shop settings
    settings = {
        useTarget = true,
        interactionDistance = 2.5
    }
} 