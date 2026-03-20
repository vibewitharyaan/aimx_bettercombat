fx_version "cerulean"
game "gta5"
lua54 "yes"

name "better_combat"
description "Weapon recoil and damage system"
version "1.0.0"
author "3RROR#0278"
store "https://errorhub.tebex.io/"
discord "https://discord.gg/Eux7CJEQN2"
website "https://elapsedstudios.com/"

shared_scripts {
    "@ox_lib/init.lua",
    "config/config.lua",
    "config/weapons.lua",
    "config/presets.lua",
}

client_scripts {
    "core/client/cl_main.lua",
    "core/client/cl_recoil.lua",
    "core/client/cl_tuner.lua",
}

server_scripts {
    "core/server/sv_main.lua",
}

dependencies { "ox_lib" }

escrow_ignore {
    "config/*.lua",
    "core/client/*.lua",
    "core/server/*.lua"
}
