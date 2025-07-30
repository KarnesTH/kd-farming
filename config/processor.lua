return {
    -- Single Processing Ped Configuration
    processingPed = {
        name = 'farming_processor',
        coords = vec3(2932.4, 4624.12, 48.72), -- Central location for all processing
        label = 'Farming Verarbeiter',
        model = 'a_m_m_farmer_01', -- Farmer ped model
        blip = {
            label = 'Farming Verarbeiter',
            sprite = 467,
            color = 2,
            scale = 0.8,
        },
        zone = {
            coords = vec3(2932.4, 4624.12, 48.72),
            size = vec3(2.0, 2.0, 3.0),
            rotation = 0
        },
        -- All processing recipes in one place
        recipes = {
            -- Orange Juice
            {
                name = 'orange_juice',
                label = 'Orange Juice',
                ingredients = {
                    orange = 3
                },
                duration = 10000, -- 10 seconds
                count = 1,
                metadata = {
                    label = 'Orange Juice',
                    description = 'Frisch gepresster Orangensaft'
                }
            },
            -- Apple Juice
            {
                name = 'apple_juice',
                label = 'Apple Juice',
                ingredients = {
                    apple = 3
                },
                duration = 10000, -- 10 seconds
                count = 1,
                metadata = {
                    label = 'Apple Juice',
                    description = 'Frisch gepresster Apfelsaft'
                }
            },
            -- Coffee
            {
                name = 'coffee',
                label = 'Coffee',
                ingredients = {
                    coffee_bean = 3
                },
                duration = 10000, -- 10 seconds
                count = 1,
                metadata = {
                    label = 'Coffee',
                    description = 'Frisch gebrannte Kaffeebohnen'
                }
            }
        }
    },
    
    -- Global processor settings
    settings = {
        useTarget = true,
        debugPoly = false,
        processingAnimation = 'WORLD_HUMAN_CLIPBOARD', -- Animation during processing
        showProgressBar = true,
        allowMultipleProcessing = false, -- Can process multiple items at once
        pedHeading = 48.74, -- Direction ped faces
        pedScenario = 'WORLD_HUMAN_CLIPBOARD', -- Ped idle animation - holds clipboard
        interactionDistance = 2.5,
        maxProcessingDistance = 10.0 -- Max distance to process items
    }
} 