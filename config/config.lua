config = {}

--[[
    MODE
    ────────────────────────────────────────────────────────────────────────────
    'single'  One global preset for every player on the server.
              Best for RP servers. Set config.defaultPreset once and forget it.
              Change live server-wide with: /setglobalpreset <name>

    'multi'   Players can be assigned individual presets (e.g. per zone or
              per game mode instance). Best for PvP servers.
              Assign from any resource via the export:
                  exports['better_combat']:setPlayerPreset(source, 'pvp_competitive')
              Revert when the player leaves a zone:
                  exports['better_combat']:setPlayerPreset(source, config.defaultPreset)
]]
config.mode          = 'single'
config.defaultPreset = 'default'

--[[
    TUNER
    ────────────────────────────────────────────────────────────────────────────
    Live in-game tuner. Opens an ox_lib menu that lets authorised players
    adjust every recoil and damage value on the fly without restarting.
    Changes apply instantly. Export prints a paste-ready Lua snippet to F8.

    command    — chat command to open the tuner  (default: /tuner)
    permission — ace permission required to use it
]]
config.tuner = {
    command    = 'tuner',
    permission = 'group.admin',
}

--[[
    DEBUG
    ────────────────────────────────────────────────────────────────────────────
    true  → prints shot info (weapon, view mode, kick values, accumulation)
            to the client F8 console on every shot, and draws a small
            recoil-accumulation bar on screen.
    false → silent.
]]
config.debug = false

-- Internal: gives every file a consistent reference to this resource's name.
resName = GetCurrentResourceName()
