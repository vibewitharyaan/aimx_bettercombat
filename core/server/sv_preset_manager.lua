api.presetManager = {}

local playerPresets = {}

-- Assign preset to player
function api.presetManager.assignPreset(source, presetName, assignedBy, lobby)
    local preset = api.presets.get(presetName)
    if not preset then
        _error(('Invalid preset "%s"'):format(presetName))
        return false
    end
    
    playerPresets[source] = {
        presetName = presetName,
        assignedAt = os.time(),
        assignedBy = assignedBy or 'system',
        lobby = lobby
    }
    
    TriggerClientEvent('weaponFramework:setPreset', source, presetName)
    
    if config.debug.code then
        _debug(('Assigned "%s" to player %d'):format(presetName, source))
    end
    
    return true
end

-- Get player's active preset
function api.presetManager.getPlayerPreset(source)
    local assignment = playerPresets[source]
    if not assignment then return nil end
    return api.presets.get(assignment.presetName)
end

-- Get player's preset name
function api.presetManager.getPlayerPresetName(source)
    local assignment = playerPresets[source]
    return assignment and assignment.presetName or nil
end

-- Get player's preset assignment info
function api.presetManager.getPlayerAssignment(source)
    return playerPresets[source]
end

-- Initialize player with default preset (single-preset mode)
function api.presetManager.initializePlayer(source)
    if config.mode == 'single' then
        api.presetManager.assignPreset(source, config.defaultPreset, 'system')
    end
end

-- Change global preset (single-preset mode only)
function api.presetManager.changeGlobalPreset(presetName, changedBy)
    if config.mode ~= 'single' then
        _error('Cannot change global preset in multi-preset mode')
        return false
    end
    
    local preset = api.presets.get(presetName)
    if not preset then
        _error(('Invalid preset "%s"'):format(presetName))
        return false
    end
    
    config.defaultPreset = presetName
    
    for source in pairs(playerPresets) do
        api.presetManager.assignPreset(source, presetName, changedBy)
    end
    
    _info(('Global preset changed to "%s" by player %d'):format(presetName, changedBy))
    
    return true
end

-- Assign preset by lobby (multi-preset mode)
function api.presetManager.assignByLobby(source, lobbyName, lobbyPreset)
    if config.mode ~= 'multi' then
        _warn('assignByLobby called in single-preset mode')
    end
    return api.presetManager.assignPreset(source, lobbyPreset, 'lobby_system', lobbyName)
end

-- Get all players with a specific preset
function api.presetManager.getPlayersWithPreset(presetName)
    local players = {}
    for source, assignment in pairs(playerPresets) do
        if assignment.presetName == presetName then
            table.insert(players, source)
        end
    end
    return players
end

-- Get all players in a lobby
function api.presetManager.getPlayersInLobby(lobbyName)
    local players = {}
    for source, assignment in pairs(playerPresets) do
        if assignment.lobby == lobbyName then
            table.insert(players, source)
        end
    end
    return players
end

-- Reload presets from config
function api.presetManager.reloadPresets()
    for source in pairs(playerPresets) do
        TriggerClientEvent('weaponFramework:reloadRecoil', source)
    end
    _info('Presets reloaded for all players')
end

-- Get preset usage statistics
function api.presetManager.getStatistics()
    local stats = {
        totalPlayers = 0,
        presetCounts = {},
        lobbyCounts = {}
    }
    
    for source, assignment in pairs(playerPresets) do
        stats.totalPlayers = stats.totalPlayers + 1
        
        local preset = assignment.presetName
        stats.presetCounts[preset] = (stats.presetCounts[preset] or 0) + 1
        
        if assignment.lobby then
            local lobby = assignment.lobby
            stats.lobbyCounts[lobby] = (stats.lobbyCounts[lobby] or 0) + 1
        end
    end
    
    return stats
end

-- Player joined server
RegisterNetEvent('weaponFramework:requestDefaultPreset', function()
    local source = source
    api.presetManager.initializePlayer(source)
end)

-- Player disconnected
AddEventHandler('playerDropped', function()
    local source = source
    playerPresets[source] = nil
    
    if config.debug.code then
        _debug(('Cleaned up player %d'):format(source))
    end
end)

-- Admin command to change player preset
RegisterNetEvent('weaponFramework:admin:changePlayerPreset', function(targetSource, presetName)
    local source = source
    
    if not api.presetManager.assignPreset(targetSource, presetName, source) then
        TriggerClientEvent('weaponFramework:notify', source, {
            type = 'error',
            message = ('Invalid preset: %s'):format(presetName)
        })
        return
    end
    
    TriggerClientEvent('weaponFramework:notify', source, {
        type = 'success',
        message = ('Assigned "%s" to player %d'):format(presetName, targetSource)
    })
end)

-- Admin command to change global preset (single-preset mode)
RegisterNetEvent('weaponFramework:admin:changeGlobalPreset', function(presetName)
    local source = source
    
    if not api.presetManager.changeGlobalPreset(presetName, source) then
        TriggerClientEvent('weaponFramework:notify', source, {
            type = 'error',
            message = 'Failed to change global preset'
        })
        return
    end
    
    TriggerClientEvent('weaponFramework:notify', source, {
        type = 'success',
        message = ('Global preset changed to: %s'):format(presetName)
    })
    
    TriggerClientEvent('weaponFramework:notify', -1, {
        type = 'info',
        message = ('Server preset changed to: %s'):format(presetName)
    })
end)

CreateThread(function()
    if config.mode == 'single' then
        local defaultPreset = api.presets.get(config.defaultPreset)
        if not defaultPreset then
            _error(('FATAL: Default preset "%s" not found'):format(config.defaultPreset))
        else
            _info(('Running in SINGLE-PRESET mode: %s'):format(config.defaultPreset))
        end
    else
        _info('Running in MULTI-PRESET mode (lobby-based)')
    end
    
    _info('Preset Manager Initialized')
end)

exports('assignPreset', api.presetManager.assignPreset)
exports('getPlayerPreset', api.presetManager.getPlayerPreset)
exports('getPlayerPresetName', api.presetManager.getPlayerPresetName)
exports('getPlayerAssignment', api.presetManager.getPlayerAssignment)
exports('assignByLobby', api.presetManager.assignByLobby)
exports('getPlayersWithPreset', api.presetManager.getPlayersWithPreset)
exports('getPlayersInLobby', api.presetManager.getPlayersInLobby)
exports('reloadPresets', api.presetManager.reloadPresets)
exports('getStatistics', api.presetManager.getStatistics)
exports('changeGlobalPreset', api.presetManager.changeGlobalPreset)

return api.presetManager
