fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'KarnesTH'
description 'Farming system for QBox'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua',
    'config/processor.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/farming.lua',
    'client/processor.lua',
    'client/main.lua',
}

server_scripts {
    'server/processor.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
} 