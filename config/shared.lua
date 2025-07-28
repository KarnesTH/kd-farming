return {
    useTarget = true,
    debugPoly = true,

    -- Farming locations
    locations = {
        {
            name = 'sandy_shores_orchard',
            coords = vec3(2336.42, 4990.02, 41.98),
            label = 'Sandy Shores Obstgarten',
            blip = {
                label = locale('info.blip_farm_apple'),
                sprite = 285,
                color = 1,
                scale = 0.8,
            },
            zone = {
                coords = vec3(2344.46, 4998.43, 42.61),
                size = vec3(90.0, 80.0, 10.0),
                rotation = 317.52
            },
            pickable = {
                apple = {
                    name = 'apple',
                    label = locale('info.apple'),
                    item = 'apple',
                    prop = 'prop_veg_crop_orange',
                    respawnTime = 30,
                    yield = {min = 1, max = 3}
                }
            },
            pickableLocations = {
                vec3(2316.514, 5023.643, 42.29422),
                vec3(2329.365, 5037.109, 43.45482),
                vec3(2304.847, 4997.079, 41.3071),
                vec3(2316.879, 5008.929, 41.49816),
                vec3(2330.34, 5021.844, 41.85641),
                vec3(2341.844, 5035.004, 43.32811),
                vec3(2317.108, 4994.208, 40.98644),
                vec3(2330.975, 5007.745, 41.34045),
                vec3(2343.679, 5022.614, 42.48338),
                vec3(2317.741, 4984.365, 40.73837),
                vec3(2331.62, 4996.562, 41.06039),
                vec3(2344.507, 5007.939, 41.68259),
                vec3(2357.204, 5020.553, 42.76117),
                vec3(2336.246, 4976.026, 41.55532),
                vec3(2349.473, 4989.562, 41.97867),
                vec3(2360.886, 5002.238, 42.43134),
                vec3(2369.237, 5010.948, 43.14606),
                vec3(2376.499, 5016.814, 44.36322),
                vec3(2349.16, 4975.843, 41.69807),
                vec3(2361.507, 4988.791, 42.19693),
                vec3(2377.54, 5003.986, 43.55063),
                vec3(2361.688, 4976.412, 42.23586),
                vec3(2374.113, 4989.015, 42.99766),
                vec3(2389.665, 5004.566, 44.70713),
                vec3(2389.987, 4992.423, 44.16648),
            }
        },
        {
            name = 'paleto_orchard',
            coords = vec3(353.97, 6517.51, 28.3),
            label = 'Paleto Obstgarten',
            blip = {
                label = locale('info.blip_farm_orange'),
                sprite = 285,
                color = 47,
                scale = 0.8,
            },
            zone = {
                coords = vec3(353.97, 6517.51, 28.3),
                size = vec3(80.0, 40.0, 10.0),
                rotation = 0
            },
            pickable = {
                orange = {
                    name = 'orange',
                    label = locale('info.orange'),
                    item = 'orange',
                    prop = 'prop_veg_crop_orange',
                    respawnTime = 30,
                    yield = {min = 1, max = 3}
                }
            },
            pickableLocations = {
                vec3(377.9431, 6505.925, 26.93631),
                vec3(370.1023, 6505.913, 27.39371),
                vec3(363.1317, 6505.812, 27.52228),
                vec3(355.3418, 6505.069, 27.43524),
                vec3(347.7576, 6505.419, 27.70041),
                vec3(339.6927, 6505.574, 27.62532),
                vec3(330.8577, 6505.649, 27.38824),
                vec3(321.7991, 6505.43, 28.16754),
                vec3(378.1224, 6517.551, 27.34387),
                vec3(369.95, 6517.716, 27.34073),
                vec3(362.722, 6517.836, 27.23004),
                vec3(355.3092, 6517.37, 27.15637),
                vec3(347.5349, 6517.551, 27.57507),
                vec3(338.8407, 6517.255, 27.8737),
                vec3(330.3134, 6517.614, 27.90004),
                vec3(321.7952, 6517.392, 28.01308),
                vec3(369.3409, 6531.682, 27.35593),
                vec3(361.5073, 6531.38, 27.21838),
                vec3(353.7479, 6530.771, 27.32923),
                vec3(345.9216, 6531.289, 27.6127),
                vec3(338.4008, 6531.294, 27.44704),
                vec3(329.4915, 6531.097, 27.49841),
                vec3(321.785, 6531.189, 28.13968),
            }
        }
    },

    -- Item definitions
    items = {
        apple = {
            name = 'apple',
            label = 'Apfel',
            item = 'apple'
        },
        orange = {
            name = 'orange',
            label = 'Orange',
            item = 'orange'
        }
    }
}