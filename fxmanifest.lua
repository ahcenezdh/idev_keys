--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game        'gta5'

--[[ Resource Information ]]--
name         'Keys System'
author       'iDev & Co'
version      '1.0.0'
repository   'https://github.com/idev-co/idev_keys'
description  'A key system in item for vehicles made for ox_inventory.'

--[[ Manifest ]]--
dependencies {
    '/server:5848',
    '/onesync',
}


shared_scripts {
    '@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
    'client/keys.lua'
}

server_scripts {
    'server/keys.lua',
    'server/exports.lua',
    'server/commands.lua'
}

files {
    'locales/*.json' -- to avoid to load other locales than the one you need just replace the * by the locale you need (for example en)
}
