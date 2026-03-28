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

-- NEXT UPDATE: delete menu mit den einzelnen sperrzonen die errichtet sind mit straßen name weil alle löschen wenn da iwas ist is kacke; jeder job einzelnes menu weil kompatibilität mit zbsp FD/Ambulance und ambesten
--              FD hat ROT, PD hat BLAU, Noose/admin zbsp dann grün/gelb oder sowas... erkennung vom job ändern die überschrift, nicht nur LSPD halt... 
