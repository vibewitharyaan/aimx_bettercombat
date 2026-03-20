-- Preset management, admin commands, and exports.
local playerPresets = {}

-- Sends an ox_lib notification to a client (or -1 for all)
local function notify(source, data)
    TriggerClientEvent('ox_lib:notify', source, data)
end

-- Assigns a preset to a player and pushes it to their client
local function assignPreset(source, name)
    if not config.presets[name] then
        _warn('assignPreset: unknown preset "%s" for player %d', name, source)
        return false
    end
    playerPresets[source] = name
    TriggerClientEvent(resName .. ':applyPreset', source, name)
    return true
end

-- Returns the preset assigned to a player, used by lib.callback
lib.callback.register(resName .. ':getPreset', function(source)
    return playerPresets[source] or config.defaultPreset
end)

AddEventHandler('playerDropped', function()
    playerPresets[source] = nil
end)

-- Opens the live tuner on the requesting admin's screen
lib.addCommand(config.tuner.command, {
    help       = 'Open the live weapon tuner',
    restricted = config.tuner.permission,
}, function(src)
    TriggerClientEvent(resName .. ':openTuner', src)
end)

-- Assigns a named preset to a specific player by server ID
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

-- Switches all connected players to a preset and updates the server default
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
    _info('Global preset → "%s" (%d players, by %d)', args.preset, count, src)
end)

-- Prints all available preset names to the requesting admin's F8 console
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

RegisterNetEvent(resName .. ':printConsole', function(text) print(text) end)

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

-- Startup validation
CreateThread(function()
    local ok = config.presets[config.defaultPreset] ~= nil
        and (config.mode == 'single' or config.mode == 'multi')

    if not ok then
        if not config.presets[config.defaultPreset] then
            _error('defaultPreset "%s" not found in config/presets.lua', config.defaultPreset)
        end
        if config.mode ~= 'single' and config.mode ~= 'multi' then
            _error('config.mode must be "single" or "multi", got "%s"', tostring(config.mode))
        end
        return
    end

    _info('Ready  |  mode: %s  |  default: %s (%s)',
        config.mode, config.defaultPreset, config.presets[config.defaultPreset].label)
end)
