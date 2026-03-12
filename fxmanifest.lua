fx_version "cerulean"
game "gta5"
lua54 "yes"

name "aimx_bettercombat"
description "Advanced Weapon Combat & Anti-Cheat System"
version "1.0.0"
author "3RROR#0278"
store "https://errorhub.tebex.io/"
discord "https://discord.gg/Eux7CJEQN2"
website "https://elapsedstudios.com/"

server_scripts "config/discord.lua"
shared_scripts {
    "@ox_lib/init.lua",
    "config/config.lua",
    "core/shared/sh_utils.lua",
    "core/shared/sh_bonemap.lua",
    "core/shared/sh_presets.lua"
}

client_scripts {
    "core/client/cl_recoil.lua",
    "core/client/cl_tuner_ui.lua",
    "core/client/interface/nui.lua",
    "core/client/cl_main.lua"
}

server_scripts {
    "core/server/sv_preset_manager.lua",
    "core/server/sv_damage_validator.lua",
    "core/server/sv_tuner_commands.lua",
    "core/server/sv_main.lua"
}

files {
    "locales/en.json",
    "nui/**/*",
    "nui/index.html"
}

ui_page "nui/index.html"

dependencies { "ox_lib" }

escrow_ignore {
    "config/**/*.lua",
    "core/shared/**/*.lua",
    "core/client/**/*.lua",
    "core/server/**/*.lua"
}
