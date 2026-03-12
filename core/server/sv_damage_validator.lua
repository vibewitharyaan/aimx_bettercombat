-- ============================================================================
-- WEAPON FRAMEWORK - SERVER DAMAGE VALIDATOR
-- ============================================================================
-- Server-authoritative damage validation using weaponDamageEvent
-- Preset-based anti-cheat with zero false positives
-- ============================================================================

local DamageValidator = {}

-- ============================================================================
-- VALIDATION STATE
-- ============================================================================

local validationState = {
    -- Player shot statistics for headshot rate detection
    playerStats = {
        --[[
        [source] = {
            totalShots = 0,
            headshots = 0,
            headshotRate = 0.0,
            lastUpdate = 0,
            detections = {}
        }
        ]]--
    },
    
    -- Detection log for persistent tracking
    detectionLog = {},
}

-- ============================================================================
-- DAMAGE EVENT HANDLER (CRITICAL)
-- ============================================================================

---Main damage validation handler
---Runs BEFORE damage is applied, allowing modification/cancellation
AddEventHandler('weaponDamageEvent', function(sender, data)
    -- Only validate if anti-cheat is enabled
    if not config.antiCheat.enabled then return end
    
    -- Get player preset
    local preset = exports[resName]:getPlayerPreset(sender)
    if not preset then
        -- No preset = no validation (server hasn't assigned one yet)
        return
    end
    
    -- Only validate if client is overriding default damage
    if not data.overrideDefaultDamage then
        -- Client using default game damage, log but allow
        if config.antiCheat.logLevel == 'all' then
            DamageValidator.LogDamageEvent(sender, data, nil, 'default_damage')
        end
        return
    end
    
    -- Get target entity
    local targetEntity = NetworkGetEntityFromNetworkId(data.hitGlobalId)
    if not targetEntity or targetEntity == 0 then
        -- Invalid target, cancel damage
        CancelEvent()
        return
    end
    
    -- Check if target is a ped
    if not IsPedAPlayer(targetEntity) then
        -- Allow NPC damage without validation (or validate with different rules)
        return
    end
    
    -- Get bone group from hit component
    local boneGroup = bonemap.getGroupWithFallback(data.hitComponent, true)
    
    -- Check if shooter is in vehicle (affects damage calculation)
    local shooterPed = GetPlayerPed(sender)
    local inVehicle = IsPedInAnyVehicle(shooterPed, false)
    
    -- Calculate expected damage based on preset
    local expectedDamage = presets.calculateDamage(
        data.weaponType,
        boneGroup,
        preset,
        inVehicle
    )
    
    -- Validate reported damage against expected
    local withinBounds, variance = presets.validateDamage(
        data.weaponDamage,
        expectedDamage,
        preset
    )
    
    -- Update shot statistics
    DamageValidator.UpdatePlayerStats(sender, boneGroup, preset)
    
    if not withinBounds then
        -- DETECTION: Damage outside preset bounds
        DamageValidator.HandleDetection(sender, {
            weapon = data.weaponType,
            boneGroup = boneGroup,
            reported = data.weaponDamage,
            expected = expectedDamage,
            variance = variance,
            tolerance = preset.validation.damageTolerance,
            preset = preset.name,
            inVehicle = inVehicle,
            willKill = data.willKill,
            timestamp = os.time()
        })
        
        -- Cancel client's damage and apply correct value
        CancelEvent()
        DamageValidator.ApplyCorrectDamage(targetEntity, expectedDamage, sender)
        
    else
        -- Damage within bounds, log if configured
        if config.antiCheat.logLevel == 'all' then
            DamageValidator.LogDamageEvent(sender, data, {
                expected = expectedDamage,
                variance = variance,
                boneGroup = boneGroup
            }, 'valid')
        end
    end
end)

-- ============================================================================
-- PLAYER STATISTICS TRACKING
-- ============================================================================

---Update player shot statistics
---@param source number
---@param boneGroup string
---@param preset table
function DamageValidator.UpdatePlayerStats(source, boneGroup, preset)
    if not validationState.playerStats[source] then
        validationState.playerStats[source] = {
            totalShots = 0,
            headshots = 0,
            headshotRate = 0.0,
            lastUpdate = os.time(),
            detections = {}
        }
    end
    
    local stats = validationState.playerStats[source]
    stats.totalShots = stats.totalShots + 1
    
    if boneGroup == 'head' then
        stats.headshots = stats.headshots + 1
    end
    
    stats.lastUpdate = os.time()
    
    -- Calculate headshot rate if sufficient shots
    if stats.totalShots >= preset.validation.minShotsForHeadshotCalc then
        stats.headshotRate = stats.headshots / stats.totalShots
        
        -- Check if headshot rate is suspiciously high
        if stats.headshotRate > preset.validation.maxHeadshotRate then
            DamageValidator.HandleHeadshotRateDetection(source, stats, preset)
        end
    end
end

---Handle suspicious headshot rate
---@param source number
---@param stats table
---@param preset table
function DamageValidator.HandleHeadshotRateDetection(source, stats, preset)
    local detection = {
        type = 'headshot_rate',
        rate = stats.headshotRate,
        threshold = preset.validation.maxHeadshotRate,
        totalShots = stats.totalShots,
        headshots = stats.headshots,
        preset = preset.name,
        timestamp = os.time()
    }
    
    table.insert(stats.detections, detection)
    
    _warn(('Player %d: Suspicious headshot rate %.2f%% (threshold: %.2f%%)'):format(
        source,
        stats.headshotRate * 100,
        preset.validation.maxHeadshotRate * 100
    ))
    
    -- Log to database if configured
    if config.antiCheat.useDatabase and config.antiCheat.databaseExport then
        DamageValidator.LogToDatabase(source, detection)
    end
    
    -- Take action if threshold reached
    if #stats.detections >= config.antiCheat.minDetections then
        DamageValidator.TakeAction(source, 'headshot_rate', detection)
    end
end

-- ============================================================================
-- DETECTION HANDLING
-- ============================================================================

---Handle damage validation detection
---@param source number
---@param detection table
function DamageValidator.HandleDetection(source, detection)
    detection.type = 'damage_variance'
    
    if not validationState.playerStats[source] then
        validationState.playerStats[source] = {
            totalShots = 0,
            headshots = 0,
            headshotRate = 0.0,
            lastUpdate = os.time(),
            detections = {}
        }
    end
    
    local stats = validationState.playerStats[source]
    table.insert(stats.detections, detection)
    
    -- Add to global log
    table.insert(validationState.detectionLog, {
        source = source,
        detection = detection
    })
    
    -- Console log
    local weaponData = config.getWeapon(detection.weapon)
    local weaponName = weaponData and weaponData.name or 'Unknown'
    
    _warn(('Player %d: Damage variance detected'):format(source))
    _debug(('  Weapon: %s | Bone: %s | Preset: %s'):format(weaponName, detection.boneGroup, detection.preset))
    _debug(('  Reported: %.1f | Expected: %.1f | Variance: %.2f%% (limit: %.2f%%)'):format(
        detection.reported,
        detection.expected,
        detection.variance * 100,
        detection.tolerance * 100
    ))
    
    -- Database logging
    if config.antiCheat.useDatabase and config.antiCheat.databaseExport then
        DamageValidator.LogToDatabase(source, detection)
    end
    
    -- Take action if threshold reached
    local detectionWindow = config.antiCheat.detectionWindow
    local recentDetections = 0
    local currentTime = os.time()
    
    for _, det in ipairs(stats.detections) do
        if currentTime - det.timestamp <= detectionWindow then
            recentDetections = recentDetections + 1
        end
    end
    
    if recentDetections >= config.antiCheat.minDetections then
        DamageValidator.TakeAction(source, 'damage_variance', detection)
    end
end

---Take action against player
---@param source number
---@param detectionType string
---@param detection table
function DamageValidator.TakeAction(source, detectionType, detection)
    local action = config.antiCheat.action
    
    if action == 'log' then
        -- Already logged, do nothing more
        return
    end
    
    local playerName = GetPlayerName(source)
    local reason = ('[Weapon Framework] Suspicious activity: %s'):format(detectionType)
    
    if action == 'kick' then
        _warn(('KICKING player %d (%s) - %s'):format(source, playerName, detectionType))
        DropPlayer(source, reason)
        
    elseif action == 'ban' then
        _warn(('BANNING player %d (%s) - %s'):format(source, playerName, detectionType))
        
        -- Integration point for ban system
        -- Example: TriggerEvent('yourBanSystem:ban', source, reason, detection)
        
        -- Fallback: kick if no ban system
        DropPlayer(source, reason .. ' (Ban)')
    end
end

-- ============================================================================
-- DAMAGE APPLICATION
-- ============================================================================

---Apply correct damage to target
---@param targetEntity number
---@param damage number
---@param attacker number
function DamageValidator.ApplyCorrectDamage(targetEntity, damage, attacker)
    -- Apply damage using native
    local targetPed = NetworkGetEntityFromNetworkId(targetEntity)
    if targetPed and targetPed ~= 0 then
        -- Apply damage from attacker
        local attackerPed = GetPlayerPed(attacker)
        ApplyDamageToPed(targetPed, damage, false)
        
        if config.debug.printDamage then
            _debug(('Applied %.1f damage from player %d to entity %d'):format(
                damage, attacker, targetEntity
            ))
        end
    end
end

-- ============================================================================
-- LOGGING
-- ============================================================================

---Log damage event
---@param source number
---@param data table
---@param validation table|nil
---@param status string
function DamageValidator.LogDamageEvent(source, data, validation, status)
    if config.debug.enabled then
        _debug(('Damage Log] Player %d | Status: %s'):format(source, status))
        if validation then
            _debug(('  Expected: %.1f | Variance: %.2f%% | Bone: %s'):format(
                validation.expected,
                validation.variance * 100,
                validation.boneGroup
            ))
        end
    end
end

---Log detection to database
---@param source number
---@param detection table
function DamageValidator.LogToDatabase(source, detection)
    if not config.antiCheat.databaseExport then return end
    
    -- Example: Using oxmysql
    -- exports[config.antiCheat.databaseExport]:execute(
    --     'INSERT INTO weapon_detections (player_id, detection_type, data, timestamp) VALUES (?, ?, ?, ?)',
    --     {source, detection.type, json.encode(detection), detection.timestamp}
    -- )
end

-- ============================================================================
-- PLAYER CLEANUP
-- ============================================================================

---Clean up player data on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    validationState.playerStats[source] = nil
    
    if Config.Debug.enabled then
        print(('[Damage Validator] Cleaned up data for player %d'):format(source))
    end
end)

-- ============================================================================
-- ADMIN COMMANDS / EXPORTS
-- ============================================================================

---Get player statistics (export for admin tools)
---@param source number
---@return table|nil
function DamageValidator.GetPlayerStats(source)
    return validationState.playerStats[source]
end

---Get detection log (export for admin tools)
---@return table
function DamageValidator.GetDetectionLog()
    return validationState.detectionLog
end

---Reset player statistics
---@param source number
function DamageValidator.ResetPlayerStats(source)
    validationState.playerStats[source] = nil
    print(('[Damage Validator] Reset stats for player %d'):format(source))
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('getPlayerStats', DamageValidator.GetPlayerStats)
exports('getDetectionLog', DamageValidator.GetDetectionLog)
exports('resetPlayerStats', DamageValidator.ResetPlayerStats)

return DamageValidator
