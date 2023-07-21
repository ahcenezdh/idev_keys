--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game        'gta5'

--[[ Resource Information ]]--
name         'Keys System'
author       'iDev & Co'
version      '0.0.1'
repository   'none'
description  'A key system in item for vehicles made with ox_inventory.'

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
    'server/keys.lua'
}