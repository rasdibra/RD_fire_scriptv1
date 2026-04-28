fx_version 'cerulean'
game 'rdr3'

author 'dev raso'
description 'Basic Fire Script for RedM'
version '1.0.0'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

--shared_scripts {
   -- 'config.lua'
--}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}