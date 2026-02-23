-- ============================================================================
-- WEAPON FRAMEWORK - PERMISSION-GATED TUNER COMMANDS
-- ============================================================================
-- Uses ox_lib AddCommand for ACE-integrated permission checking
-- Only accessible to authorized admin/developer roles
-- ============================================================================

-- ============================================================================
-- TUNER ACCESS COMMAND
-- ============================================================================

lib.addCommand(Config.Tuner.command, {
    help = 'Open weapon tuner interface (admin only)',
    restricted = Config.Tuner.permission  -- e.g., 'group.admin'
}, function(source, args, raw)
    -- Permission automatically validated by ox_lib
    -- This code ONLY runs if player has the required ACE
    
    -- Open NUI tuner
    TriggerClientEvent('weaponFramework:openTuner', source)
    
    print(('[Tuner] Player %d (%s) opened weapon tuner'):format(
        source,
        GetPlayerName(source)
    ))
end)

-- ============================================================================
-- TUNER SAVE HANDLER
-- ============================================================================

---Handle weapon configuration save from tuner
RegisterNetEvent('weaponFramework:tuner:saveWeapon', function(config, presetName)
    local source = source
    
    -- Verify player has permission
    if not IsPlayerAceAllowed(source, Config.Tuner.permission) then
        print(('[Tuner] SECURITY: Player %d attempted to save without permission'):format(source))
        return
    end
    
    -- Log the save
    print(('[Tuner] Player %d saved weapon config for %s to preset %s'):format(
        source,
        config.hash,
        presetName
    ))
    
    -- Here you could save to database or file
    -- For now, just log it - the exported code is the primary output
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Saved %s configuration!\nUse the export code to update your config files.'):format(config.name)
    })
end)

-- ============================================================================
-- PRESET MANAGEMENT COMMANDS
-- ============================================================================

lib.addCommand('setpreset', {
    help = 'Assign preset to a player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player server ID'
        },
        {
            name = 'preset',
            type = 'string',
            help = 'Preset name (realistic, competitive, hardcore, arcade)'
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    local presetName = args.preset
    
    -- Validate player exists
    local targetName = GetPlayerName(targetSource)
    if not targetName then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('Player %d not found'):format(targetSource)
        })
        return
    end
    
    -- Assign preset
    local success = exports['weapon_framework']:assignPreset(targetSource, presetName, source)
    
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

lib.addCommand('changeglobalpreset', {
    help = 'Change server-wide preset (single-preset mode only)',
    params = {
        {
            name = 'preset',
            type = 'string',
            help = 'Preset name'
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local presetName = args.preset
    
    local success = exports['weapon_framework']:changeGlobalPreset(presetName, source)
    
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

-- ============================================================================
-- PRESET INFORMATION COMMANDS
-- ============================================================================

lib.addCommand('listpresets', {
    help = 'List all available presets',
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local presets = Presets.GetAll()
    
    local message = 'Available Presets:\n'
    for _, name in ipairs(presets) do
        local preset = Presets.Get(name)
        message = message .. ('- %s: %s\n'):format(name, preset.description)
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = message,
        duration = 8000
    })
end)

lib.addCommand('presetstats', {
    help = 'Show preset usage statistics',
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local stats = exports['weapon_framework']:getStatistics()
    
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

-- ============================================================================
-- ANTI-CHEAT MANAGEMENT COMMANDS
-- ============================================================================

lib.addCommand('playerstats', {
    help = 'View player combat statistics',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player server ID'
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    
    local stats = exports['weapon_framework']:getPlayerStats(targetSource)
    
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

lib.addCommand('resetstats', {
    help = 'Reset player combat statistics',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player server ID'
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local targetSource = args.target
    
    exports['weapon_framework']:resetPlayerStats(targetSource)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Reset stats for player %d'):format(targetSource)
    })
end)

lib.addCommand('detectionlog', {
    help = 'View recent anti-cheat detections',
    params = {
        {
            name = 'count',
            type = 'number',
            help = 'Number of recent detections to show',
            optional = true
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local count = args.count or 10
    local log = exports['weapon_framework']:getDetectionLog()
    
    if #log == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'info',
            description = 'No detections recorded'
        })
        return
    end
    
    -- Get most recent detections
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

-- ============================================================================
-- RELOAD COMMAND
-- ============================================================================

lib.addCommand('reloadpresets', {
    help = 'Reload preset configuration for all players',
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    exports['weapon_framework']:reloadPresets()
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Presets reloaded for all players'
    })
end)

-- ============================================================================
-- WEAPON INFO COMMANDS
-- ============================================================================

lib.addCommand('weaponinfo', {
    help = 'Show weapon statistics',
    params = {
        {
            name = 'weapon',
            type = 'string',
            help = 'Weapon name (e.g., WEAPON_PISTOL)'
        },
        {
            name = 'preset',
            type = 'string',
            help = 'Preset name (optional)',
            optional = true
        }
    },
    restricted = Config.Tuner.permission
}, function(source, args, raw)
    local weaponName = args.weapon
    local weaponHash = GetHashKey(weaponName)
    
    local weapon = Config.GetWeapon(weaponHash)
    if not weapon then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = ('Weapon not found: %s'):format(weaponName)
        })
        return
    end
    
    local preset = args.preset and Presets.Get(args.preset) or Presets.Get(Config.DefaultPreset)
    
    local message = ('Weapon: %s\n'):format(weapon.name)
    message = message .. ('Class: %s\n'):format(weapon.class)
    message = message .. ('Base Damage: %.1f\n'):format(weapon.baseDamage)
    message = message .. ('Base Recoil: %.3f\n'):format(weapon.baseRecoil)
    
    if preset then
        message = message .. ('\nWith Preset "%s":\n'):format(preset.name)
        
        -- Calculate effective values
        local effectiveRecoil = Presets.CalculateRecoil(weaponHash, preset, false)
        local headDamage = Presets.CalculateDamage(weaponHash, 'head', preset, false)
        local torsoDamage = Presets.CalculateDamage(weaponHash, 'torso', preset, false)
        
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

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    print(('[Tuner Commands] Registered with permission: %s'):format(Config.Tuner.permission))
    print('[Tuner Commands] Available commands:')
    print(('  /%s - Open tuner UI'):format(Config.Tuner.command))
    print('  /setpreset <player> <preset> - Assign preset')
    print('  /changeglobalpreset <preset> - Change server preset')
    print('  /listpresets - List presets')
    print('  /presetstats - Preset statistics')
    print('  /playerstats <player> - Player stats')
    print('  /resetstats <player> - Reset player stats')
    print('  /detectionlog [count] - View detections')
    print('  /reloadpresets - Reload presets')
    print('  /weaponinfo <weapon> [preset] - Weapon info')
end)
