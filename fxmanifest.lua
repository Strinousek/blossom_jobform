fx_version "cerulean"
lua54 "yes"
game "gta5"

files {
    "web/**/*",
}

ui_page "web/index.html"

shared_scripts {
    "locales/*.lua",
    "config.lua",
    "core.lua"
}

client_script "client/main.lua"

server_scripts {
    "server/config.lua",
    "server/main.lua"
}