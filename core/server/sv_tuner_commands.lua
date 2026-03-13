-- Tuner Access Command
lib.addCommand(config.tuner.command, {
    help = 'Open weapon tuner interface (admin only)',
    restricted = config.tuner.permission
}, function(source, args, raw)
    TriggerClientEvent('weaponFramework:openTuner', source)
    _info(('Player %d (%s) opened weapon tuner'):format(source, GetPlayerName(source)))
end)

-- Handle weapon configuration save from tuner
RegisterNetEvent('weaponFramework:tuner:saveWeapon', function(data, presetName)
    local source = source
    
    if not IsPlayerAceAllowed(source, config.tuner.permission) then
        _warn(('SECURITY: Player %d attempted to save without permission'):format(source))
        return
    end
    
    _info(('Player %d saved weapon config for %s to preset %s'):format(source, data.hash, presetName))
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Saved %s configuration!\nUse the export code to update your config files.'):format(data.name)
    })
end)

-- Assign preset to a player
lib.addCommand('setpreset', {
    help = 'Assign preset to a player',
    params = {
        { name = 'target', type = 'playerId', help = 'Target player server ID' },
        { name = 'preset', type = 'string', help = 'Preset name (realistic, competitive, hardcore, arcade)' }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    local presetName = args.preset
    
    local targetName = GetPlayerName(targetSource)
    if not targetName then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('Player %d not found'):format(targetSource)
        })
        return
    end
    
    local success = exports[resName]:assignPreset(targetSource, presetName, source)
    
    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = ('Assigned "%s" to %s'):format(presetName, targetName)
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('Invalid preset: %s'):format(presetName)
        })
    end
end)

-- Change server-wide preset
lib.addCommand('changeglobalpreset', {
    help = 'Change server-wide preset (single-preset mode only)',
    params = {
        { name = 'preset', type = 'string', help = 'Preset name' }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local presetName = args.preset
    local success = exports[resName]:changeGlobalPreset(presetName, source)
    
    if success then
        TriggerClientEvent('ox_lib:notify', -1, {
            type = 'info',
            description = ('Server preset changed to: %s'):format(presetName)
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Failed to change preset (check mode and preset name)'
        })
    end
end)

-- List all available presets
lib.addCommand('listpresets', {
    help = 'List all available presets',
    restricted = config.tuner.permission
}, function(source, args, raw)
    local presetList = presets.getAll()
    local message = 'Available Presets:\n'
    
    for _, name in ipairs(presetList) do
        local preset = presets.get(name)
        message = message .. ('- %s: %s\n'):format(name, preset.description)
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 8000
    })
end)

-- Show preset usage statistics
lib.addCommand('presetstats', {
    help = 'Show preset usage statistics',
    restricted = config.tuner.permission
}, function(source, args, raw)
    local stats = exports[resName]:getStatistics()
    local message = ('Preset Statistics:\nTotal Players: %d\n'):format(stats.totalPlayers)
    
    for preset, count in pairs(stats.presetCounts) do
        message = message .. ('- %s: %d players\n'):format(preset, count)
    end
    
    if next(stats.lobbyCounts) then
        message = message .. '\nLobbies:\n'
        for lobby, count in pairs(stats.lobbyCounts) do
            message = message .. ('- %s: %d players\n'):format(lobby, count)
        end
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 8000
    })
end)

-- View player combat statistics
lib.addCommand('playerstats', {
    help = 'View player combat statistics',
    params = {
        { name = 'target', type = 'playerId', help = 'Target player server ID' }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    local stats = exports[resName]:getPlayerStats(targetSource)
    
    if not stats then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('No stats found for player %d'):format(targetSource)
        })
        return
    end
    
    local message = ('Stats for Player %d:\n'):format(targetSource)
    message = message .. ('Total Shots: %d\n'):format(stats.totalShots)
    message = message .. ('Headshots: %d\n'):format(stats.headshots)
    message = message .. ('Headshot Rate: %.1f%%\n'):format(stats.headshotRate * 100)
    message = message .. ('Detections: %d\n'):format(#stats.detections)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 8000
    })
end)

-- Reset player combat statistics
lib.addCommand('resetstats', {
    help = 'Reset player combat statistics',
    params = {
        { name = 'target', type = 'playerId', help = 'Target player server ID' }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    exports[resName]:resetPlayerStats(targetSource)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Reset stats for player %d'):format(targetSource)
    })
end)

-- View recent anti-cheat detections
lib.addCommand('detectionlog', {
    help = 'View recent anti-cheat detections',
    params = {
        { name = 'count', type = 'number', help = 'Number of recent detections to show', optional = true }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local count = args.count or 10
    local log = exports[resName]:getDetectionLog()
    
    if #log == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'info',
            description = 'No detections recorded'
        })
        return
    end
    
    local recent = {}
    for i = math.max(1, #log - count + 1), #log do
        table.insert(recent, log[i])
    end
    
    local message = ('Recent Detections (%d):\n'):format(#recent)
    for _, entry in ipairs(recent) do
        local det = entry.detection
        message = message .. ('Player %d: %s (%.2f%% variance)\n'):format(
            entry.source,
            det.type,
            (det.variance or 0) * 100
        )
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 10000
    })
end)

-- Reload preset configuration for all players
lib.addCommand('reloadpresets', {
    help = 'Reload preset configuration for all players',
    restricted = config.tuner.permission
}, function(source, args, raw)
    exports[resName]:reloadPresets()
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Presets reloaded for all players'
    })
end)

-- Show weapon statistics
lib.addCommand('weaponinfo', {
    help = 'Show weapon statistics',
    params = {
        { name = 'weapon', type = 'string', help = 'Weapon name (e.g., WEAPON_PISTOL)' },
        { name = 'preset', type = 'string', help = 'Preset name (optional)', optional = true }
    },
    restricted = config.tuner.permission
}, function(source, args, raw)
    local weaponName = args.weapon
    local weaponHash = GetHashKey(weaponName)
    local weapon = config.getWeapon(weaponHash)
    
    if not weapon then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('Weapon not found: %s'):format(weaponName)
        })
        return
    end
    
    local preset = args.preset and presets.get(args.preset) or presets.get(config.defaultPreset)
    local message = ('Weapon: %s\n'):format(weapon.name)
    message = message .. ('Class: %s\n'):format(weapon.class)
    message = message .. ('Base Damage: %.1f\n'):format(weapon.baseDamage)
    message = message .. ('Base Recoil: %.3f\n'):format(weapon.baseRecoil)
    
    if preset then
        message = message .. ('\nWith Preset "%s":\n'):format(preset.name)
        
        local effectiveRecoil = presets.calculateRecoil(weaponHash, preset, false)
        local headDamage = presets.calculateDamage(weaponHash, 'head', preset, false)
        local torsoDamage = presets.calculateDamage(weaponHash, 'torso', preset, false)
        
        message = message .. ('Effective Recoil: %.3f\n'):format(effectiveRecoil)
        message = message .. ('Headshot Damage: %.1f\n'):format(headDamage)
        message = message .. ('Torso Damage: %.1f\n'):format(torsoDamage)
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 10000
    })
end)

CreateThread(function()
    _info(('Tuner Commands Registered with permission: %s'):format(config.tuner.permission))
end)
