-- ============================================================================
-- WEAPON FRAMEWORK - SERVER PRESET MANAGER
-- ============================================================================
-- Manages preset assignment and tracking for players
-- Supports both single-preset and multi-preset modes
-- ============================================================================

local PresetManager = {}

-- ============================================================================
-- PRESET ASSIGNMENT STATE
-- ============================================================================

local playerPresets = {
    --[[
    [source] = {
        presetName = 'realistic',
        assignedAt = timestamp,
        assignedBy = 'system' or playerSource,
        lobby = nil or 'lobby_name' (for multi-preset mode)
    }
    ]]--
}

-- ============================================================================
-- PRESET ASSIGNMENT
-- ============================================================================

---Assign preset to player
---@param source number
---@param presetName string
---@param assignedBy string|number
---@param lobby string|nil
---@return boolean success
function PresetManager.AssignPreset(source, presetName, assignedBy, lobby)
    -- Validate preset exists
    local preset = Presets.Get(presetName)
    if not preset then
        print(('[Preset Manager] ERROR: Invalid preset "%s"'):format(presetName))
        return false
    end
    
    -- Store assignment
    playerPresets[source] = {
        presetName = presetName,
        assignedAt = os.time(),
        assignedBy = assignedBy or 'system',
        lobby = lobby
    }
    
    -- Notify client
    TriggerClientEvent('weaponFramework:setPreset', source, presetName)
    
    if Config.Debug.enabled then
        print(('[Preset Manager] Assigned "%s" to player %d'):format(presetName, source))
    end
    
    return true
end

---Get player's active preset
---@param source number
---@return table|nil preset
function PresetManager.GetPlayerPreset(source)
    local assignment = playerPresets[source]
    if not assignment then return nil end
    
    return Presets.Get(assignment.presetName)
end

---Get player's preset name
---@param source number
---@return string|nil
function PresetManager.GetPlayerPresetName(source)
    local assignment = playerPresets[source]
    return assignment and assignment.presetName or nil
end

---Get player's preset assignment info
---@param source number
---@return table|nil
function PresetManager.GetPlayerAssignment(source)
    return playerPresets[source]
end

-- ============================================================================
-- SINGLE-PRESET MODE
-- ============================================================================

---Initialize player with default preset (single-preset mode)
---@param source number
function PresetManager.InitializePlayer(source)
    if Config.Mode == 'single' then
        -- Assign default preset
        PresetManager.AssignPreset(source, Config.DefaultPreset, 'system')
    end
    -- In multi-preset mode, server must explicitly assign via lobby system
end

---Change global preset (single-preset mode only)
---@param presetName string
---@param changedBy number
---@return boolean success
function PresetManager.ChangeGlobalPreset(presetName, changedBy)
    if Config.Mode ~= 'single' then
        print('[Preset Manager] ERROR: Cannot change global preset in multi-preset mode')
        return false
    end
    
    local preset = Presets.Get(presetName)
    if not preset then
        print(('[Preset Manager] ERROR: Invalid preset "%s"'):format(presetName))
        return false
    end
    
    -- Update config
    Config.DefaultPreset = presetName
    
    -- Reassign all players
    for source in pairs(playerPresets) do
        PresetManager.AssignPreset(source, presetName, changedBy)
    end
    
    print(('[Preset Manager] Global preset changed to "%s" by player %d'):format(
        presetName, changedBy
    ))
    
    return true
end

-- ============================================================================
-- MULTI-PRESET MODE (LOBBY SYSTEM)
-- ============================================================================

---Assign preset by lobby (multi-preset mode)
---@param source number
---@param lobbyName string
---@param lobbyPreset string
---@return boolean success
function PresetManager.AssignByLobby(source, lobbyName, lobbyPreset)
    if Config.Mode ~= 'multi' then
        print('[Preset Manager] WARNING: AssignByLobby called in single-preset mode')
    end
    
    return PresetManager.AssignPreset(source, lobbyPreset, 'lobby_system', lobbyName)
end

---Get all players with a specific preset
---@param presetName string
---@return number[] sources
function PresetManager.GetPlayersWithPreset(presetName)
    local players = {}
    for source, assignment in pairs(playerPresets) do
        if assignment.presetName == presetName then
            table.insert(players, source)
        end
    end
    return players
end

---Get all players in a lobby
---@param lobbyName string
---@return number[] sources
function PresetManager.GetPlayersInLobby(lobbyName)
    local players = {}
    for source, assignment in pairs(playerPresets) do
        if assignment.lobby == lobbyName then
            table.insert(players, source)
        end
    end
    return players
end

-- ============================================================================
-- PRESET RELOADING
-- ============================================================================

---Reload presets from config (for runtime changes)
function PresetManager.ReloadPresets()
    -- Force clients to recalculate
    for source in pairs(playerPresets) do
        TriggerClientEvent('weaponFramework:reloadRecoil', source)
    end
    
    print('[Preset Manager] Presets reloaded for all players')
end

-- ============================================================================
-- STATISTICS
-- ============================================================================

---Get preset usage statistics
---@return table statistics
function PresetManager.GetStatistics()
    local stats = {
        totalPlayers = 0,
        presetCounts = {},
        lobbyCounts = {}
    }
    
    for source, assignment in pairs(playerPresets) do
        stats.totalPlayers = stats.totalPlayers + 1
        
        -- Count by preset
        local preset = assignment.presetName
        stats.presetCounts[preset] = (stats.presetCounts[preset] or 0) + 1
        
        -- Count by lobby (if multi-preset mode)
        if assignment.lobby then
            local lobby = assignment.lobby
            stats.lobbyCounts[lobby] = (stats.lobbyCounts[lobby] or 0) + 1
        end
    end
    
    return stats
end

-- ============================================================================
-- PLAYER EVENTS
-- ============================================================================

---Player joined server
RegisterNetEvent('weaponFramework:requestDefaultPreset', function()
    local source = source
    PresetManager.InitializePlayer(source)
end)

---Player disconnected
AddEventHandler('playerDropped', function()
    local source = source
    playerPresets[source] = nil
    
    if Config.Debug.enabled then
        print(('[Preset Manager] Cleaned up player %d'):format(source))
    end
end)

-- ============================================================================
-- ADMIN COMMANDS
-- ============================================================================

---Admin command to change player preset
RegisterNetEvent('weaponFramework:admin:changePlayerPreset', function(targetSource, presetName)
    local source = source
    
    -- Verify admin permission (handled by command registration)
    if not PresetManager.AssignPreset(targetSource, presetName, source) then
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

---Admin command to change global preset (single-preset mode)
RegisterNetEvent('weaponFramework:admin:changeGlobalPreset', function(presetName)
    local source = source
    
    if not PresetManager.ChangeGlobalPreset(presetName, source) then
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
    
    -- Broadcast to all players
    TriggerClientEvent('weaponFramework:notify', -1, {
        type = 'info',
        message = ('Server preset changed to: %s'):format(presetName)
    })
end)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    -- Validate default preset
    if Config.Mode == 'single' then
        local defaultPreset = Presets.Get(Config.DefaultPreset)
        if not defaultPreset then
            error(('[Preset Manager] FATAL: Default preset "%s" not found'):format(Config.DefaultPreset))
        end
        
        print(('[Preset Manager] Running in SINGLE-PRESET mode: %s'):format(Config.DefaultPreset))
    else
        print('[Preset Manager] Running in MULTI-PRESET mode (lobby-based)')
    end
    
    print('[Preset Manager] Initialized')
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('assignPreset', PresetManager.AssignPreset)
exports('getPlayerPreset', PresetManager.GetPlayerPreset)
exports('getPlayerPresetName', PresetManager.GetPlayerPresetName)
exports('getPlayerAssignment', PresetManager.GetPlayerAssignment)
exports('assignByLobby', PresetManager.AssignByLobby)
exports('getPlayersWithPreset', PresetManager.GetPlayersWithPreset)
exports('getPlayersInLobby', PresetManager.GetPlayersInLobby)
exports('reloadPresets', PresetManager.ReloadPresets)
exports('getStatistics', PresetManager.GetStatistics)
exports('changeGlobalPreset', PresetManager.ChangeGlobalPreset)

-- Legacy compatibility
exports('GetPlayerPreset', PresetManager.GetPlayerPreset)

return PresetManager
