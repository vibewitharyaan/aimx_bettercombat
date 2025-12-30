fx_version "cerulean"
game "gta5"
lua54 "yes"

name "script_name"
description "project_description"
version "1.0.0"
author "3RROR#0278"
store "https://errorhub.tebex.io/"
discord "https://discord.gg/Eux7CJEQN2"
website "https://elapsedstudios.com/"

server_scripts "config/discord.lua"
shared_scripts {
    "@ox_lib/init.lua",
    "config/config.lua",
    "core/shared/**/*.lua"
}

client_scripts {
    "core/client/**/*.lua"
}

server_scripts {
    -- "@oxmysql/lib/MySQL.lua", -- Optional if use mysql i.e. db
    "config/discord.lua",
    "core/version.lua",
    "core/server/**/*.lua"
}

files {
    "locales/en.json",
    "nui/**/*",
    "nui/index.html"
}

-- ui_page "http://localhost:5173" -- local version
ui_page "nui/index.html" -- build version

dependencies { "ox_lib" }

escrow_ignore {
    "config/**/*.lua",
    "core/shared/**/*.lua",
    "core/client/**/*.lua",
    "core/server/**/*.lua"
}
