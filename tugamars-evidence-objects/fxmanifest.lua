fx_version 'cerulean'
game 'gta5'

name 'Tugamars Evidence Objects'
version '1.0.0'
description 'Tugamars Evidence Objects'
author 'tugamars'



shared_scripts {
    'config.lua'
}

client_scripts {
    '@menuv/menuv.lua',
    'config.lua',
    'main/client/**/*.lua',
}

server_scripts {
    'main/server/**/*.lua',
}


dependencies {
    'menuv'
}