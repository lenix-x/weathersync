fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Lenix'
description 'Syncs the time & weather for all players on the server and allows editing by command forked from qb-weathersync'
version '2.1.1'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua' -- OX library (if using ox_lib)
}

server_script 'server/server.lua'
client_script 'client/client.lua'

files {'locales/*.json'}

ox_libs {'locale'}
