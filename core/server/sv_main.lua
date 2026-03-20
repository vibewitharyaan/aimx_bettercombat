--[[
    sv_main.lua — preset management, admin commands, and exports.

    ── SINGLE MODE (config.mode = 'single') ─────────────────────────────────────
    Every player receives config.defaultPreset on join.
    Change server-wide live:
        /setglobalpreset <presetName>
        exports['better_combat']:setGlobalPreset('pvp_competitive')

    ── MULTI MODE (config.mode = 'multi') ───────────────────────────────────────
    Players receive config.defaultPreset on join.
    Your gamemode / zone script assigns per-player presets:
        exports['better_combat']:setPlayerPreset(source, 'pvp_competitive')
    Revert when the player leaves a zone:
        exports['better_combat']:setPlayerPreset(source, config.defaultPreset)

    ── ADMIN COMMANDS ────────────────────────────────────────────────────────────
    /tuner                           — open live tuner on caller's screen
    /setpreset <id> <preset>         — assign preset to one player
    /setglobalpreset <preset>        — assign preset to all players
    /listpresets                     — print all preset names to caller's F8

    ── SERVER EXPORTS ────────────────────────────────────────────────────────────
    setPlayerPreset(source, name)    → boolean
    setGlobalPreset(name)            → boolean
    getPlayerPreset(source)          → string
]]

local playerPresets = {} -- [source] = preset name string

-- ox_lib does not expose lib.notify server-side.
-- The correct documented approach is TriggerClientEvent('ox_lib:notify', ...).
local function notify(source, data)
    TriggerClientEvent('ox_lib:notify', source, data)
end

-- ── Core preset assign ────────────────────────────────────────────────────────

local function assignPreset(source, name)
    if not config.presets[name] then
        print(('[Combat] assignPreset: unknown preset "%s" for player %d'):format(
            tostring(name), source))
        return false
    end
    playerPresets[source] = name
    TriggerClientEvent(resName .. ':applyPreset', source, name)
    return true
end

-- ── Player join / drop ────────────────────────────────────────────────────────

RegisterNetEvent(resName .. ':requestPreset', function()
    local src = source
    assignPreset(src, playerPresets[src] or config.defaultPreset)
end)

AddEventHandler('playerDropped', function()
    playerPresets[source] = nil
end)

-- ── Admin commands ────────────────────────────────────────────────────────────

lib.addCommand(config.tuner.command, {
    help       = 'Open the live weapon tuner',
    restricted = config.tuner.permission,
}, function(src)
    TriggerClientEvent(resName .. ':openTuner', src)
    print(('[Tuner] Opened by %s (id %d)'):format(GetPlayerName(src), src))
end)

lib.addCommand('setpreset', {
    help       = 'Assign a recoil preset to a player',
    restricted = config.tuner.permission,
    params     = {
        { name = 'target', type = 'playerId', help = 'Target player server ID' },
        { name = 'preset', type = 'string',   help = 'Preset name' },
    },
}, function(src, args)
    local ok = assignPreset(args.target, args.preset)
    notify(src, {
        type        = ok and 'success' or 'error',
        title       = 'Combat',
        description = ok
            and ('Assigned "%s" to player %d'):format(args.preset, args.target)
            or ('Unknown preset "%s" — run /listpresets'):format(args.preset),
        duration    = 4000,
    })
end)

lib.addCommand('setglobalpreset', {
    help       = 'Switch all players to a preset',
    restricted = config.tuner.permission,
    params     = {
        { name = 'preset', type = 'string', help = 'Preset name' },
    },
}, function(src, args)
    if not config.presets[args.preset] then
        notify(src, {
            type = 'error',
            title = 'Combat',
            description = ('Unknown preset "%s" — run /listpresets'):format(args.preset),
            duration = 5000
        })
        return
    end
    config.defaultPreset = args.preset
    local count = 0
    for _, id in ipairs(GetPlayers()) do
        assignPreset(tonumber(id), args.preset)
        count = count + 1
    end
    notify(-1, {
        type = 'inform',
        title = 'Combat',
        description = ('Server preset → %s'):format(config.presets[args.preset].label),
        duration = 4000
    })
    print(('[Combat] Global preset → "%s" (%d players, by %d)'):format(
        args.preset, count, src))
end)

lib.addCommand('listpresets', {
    help       = 'List all preset names',
    restricted = config.tuner.permission,
}, function(src)
    local lines = { 'Available presets:' }
    for name, p in pairs(config.presets) do
        lines[#lines + 1] = ('  %-22s %s'):format(name, p.label)
    end
    TriggerClientEvent(resName .. ':printConsole', src, table.concat(lines, '\n'))
    notify(src, {
        type = 'inform',
        title = 'Presets',
        description = ('Total: %d — list printed to F8'):format(#lines - 1),
        duration = 4000
    })
end)

-- ── Client helper ─────────────────────────────────────────────────────────────

RegisterNetEvent(resName .. ':printConsole', function(text)
    print(text)
end)

-- ── Exports ───────────────────────────────────────────────────────────────────

exports('setPlayerPreset', assignPreset)

exports('setGlobalPreset', function(name)
    if not config.presets[name] then return false end
    config.defaultPreset = name
    for _, id in ipairs(GetPlayers()) do assignPreset(tonumber(id), name) end
    return true
end)

exports('getPlayerPreset', function(src)
    return playerPresets[src] or config.defaultPreset
end)

-- ── Startup validation ────────────────────────────────────────────────────────

CreateThread(function()
    local ok = true
    if not config.presets[config.defaultPreset] then
        print(('[Combat] ERROR: defaultPreset "%s" not found in config/presets.lua'):format(
            config.defaultPreset))
        ok = false
    end
    if config.mode ~= 'single' and config.mode ~= 'multi' then
        print(('[Combat] ERROR: config.mode must be "single" or "multi", got "%s"'):format(
            tostring(config.mode)))
        ok = false
    end
    if ok then
        print(('[Combat] Ready  |  mode: %s  |  default: %s (%s)'):format(
            config.mode,
            config.defaultPreset,
            config.presets[config.defaultPreset].label))
    end
end)
