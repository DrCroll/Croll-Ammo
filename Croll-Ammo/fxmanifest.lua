fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Croll-Ammo'
author 'DrCroll'
version '1.1.1'

shared_scripts {
    'locale/*.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'opensource/server/version.lua',
    'opensource/server/opensource.lua',
    'server/amounts.lua',
    'server/main.lua',
}
