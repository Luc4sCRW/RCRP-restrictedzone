fx_version 'cerulean'
game 'gta5'

author 'REDLINE CITY RP | RCRP'
description 'Restricted zone Script'
version 'v1.0 (release)'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    
    'locales.lua',
    'locales/*.lua'
}

client_script 'client.lua'
server_script 'server.lua'

-- NEXT UPDATE: delete menu mit den einzelnen sperrzonen die errichtet sind mit straßen name weil alle löschen wenn da iwas ist is kacke
