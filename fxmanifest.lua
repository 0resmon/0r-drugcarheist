fx_version 'cerulean'

game 'gta5'

author "0Resmon"

description "Created by 0Resmon"

lua54 "yes"

client_script 'client/client.lua'

server_scripts {
    'server/server.lua'
} 

shared_scripts {
    '@ox_lib/init.lua'
}

dependency {
    'ox_lib'
}