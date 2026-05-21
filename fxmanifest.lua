fx_version 'cerulean'
game 'gta5'

author 'Luc4s_CRW'
description 'REDLINE CITY RP | RCRP - Restricted Zone'
version '1.0.0 (release)'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    
    'locales.lua',
    'locales/*.lua'
}

client_script 'client.lua'
server_script 'server.lua'

-- dependency 'ox_lib'
