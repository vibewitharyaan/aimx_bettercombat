api.damageValidator = {}

local validationState = {
    playerStats = {},
    detectionLog = {},
}

-- Main damage validation handler
AddEventHandler('weaponDamageEvent', function(sender, data)
    if not config.antiCheat.enabled then return end

    local preset = exports[resName]:getPlayerPreset(sender)
    if not preset then return end

    if not data.overrideDefaultDamage then
        if config.antiCheat.logLevel == 'all' then
            api.damageValidator.logDamageEvent(sender, data, nil, 'default_damage')
        end
        return
    end

    local targetEntity = NetworkGetEntityFromNetworkId(data.hitGlobalId)
    if not targetEntity or targetEntity == 0 then
        CancelEvent()
        return
    end

    if not IsPedAPlayer(targetEntity) then return end

    local boneGroup = api.bonemap.getGroupWithFallback(data.hitComponent, true)
    local shooterPed = GetPlayerPed(sender)
    local inVehicle = IsPedInAnyVehicle(shooterPed, false)

    local expectedDamage = api.presets.calculateDamage(data.weaponType, boneGroup, preset, inVehicle)
    local withinBounds, variance = api.presets.validateDamage(data.weaponDamage, expectedDamage, preset)

    api.damageValidator.updatePlayerStats(sender, boneGroup, preset)

    if not withinBounds then
        api.damageValidator.handleDetection(sender, {
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

        CancelEvent()
        api.damageValidator.applyCorrectDamage(targetEntity, expectedDamage, sender)
    else
        if config.antiCheat.logLevel == 'all' then
            api.damageValidator.logDamageEvent(sender, data, {
                expected = expectedDamage,
                variance = variance,
                boneGroup = boneGroup
            }, 'valid')
        end
    end
end)

-- Update player shot statistics
function api.damageValidator.updatePlayerStats(source, boneGroup, preset)
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

    if stats.totalShots >= preset.validation.minShotsForHeadshotCalc then
        stats.headshotRate = stats.headshots / stats.totalShots

        if stats.headshotRate > preset.validation.maxHeadshotRate then
            api.damageValidator.handleHeadshotRateDetection(source, stats, preset)
        end
    end
end

-- Handle suspicious headshot rate
function api.damageValidator.handleHeadshotRateDetection(source, stats, preset)
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
        source, stats.headshotRate * 100, preset.validation.maxHeadshotRate * 100
    ))

    if config.antiCheat.useDatabase and config.antiCheat.databaseExport then
        api.damageValidator.logToDatabase(source, detection)
    end

    if #stats.detections >= config.antiCheat.minDetections then
        api.damageValidator.takeAction(source, 'headshot_rate', detection)
    end
end

-- Handle damage validation detection
function api.damageValidator.handleDetection(source, detection)
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

    table.insert(validationState.detectionLog, { source = source, detection = detection })

    local weaponData = config.getWeapon(detection.weapon)
    local weaponName = weaponData and weaponData.name or 'Unknown'

    _warn(('Player %d: Damage variance detected'):format(source))
    _debug(('  Weapon: %s | Bone: %s | Preset: %s'):format(weaponName, detection.boneGroup, detection.preset))
    _debug(('  Reported: %.1f | Expected: %.1f | Variance: %.2f%% (limit: %.2f%%)'):format(
        detection.reported, detection.expected, detection.variance * 100, detection.tolerance * 100
    ))

    if config.antiCheat.useDatabase and config.antiCheat.databaseExport then
        api.damageValidator.logToDatabase(source, detection)
    end

    local detectionWindow = config.antiCheat.detectionWindow
    local recentDetections = 0
    local currentTime = os.time()

    for _, det in ipairs(stats.detections) do
        if currentTime - det.timestamp <= detectionWindow then
            recentDetections = recentDetections + 1
        end
    end

    if recentDetections >= config.antiCheat.minDetections then
        api.damageValidator.takeAction(source, 'damage_variance', detection)
    end
end

-- Take action against player based on config
function api.damageValidator.takeAction(source, detectionType, detection)
    local playerName = GetPlayerName(source)
    local reason = ('[Weapon Framework] Suspicious activity: %s'):format(detectionType)

    if config.antiCheat.allowBan then
        _warn(('BANNING player %d (%s) - %s'):format(source, playerName, detectionType))
        DropPlayer(source, reason .. ' (Ban)')
    elseif config.antiCheat.allowKick then
        _warn(('KICKING player %d (%s) - %s'):format(source, playerName, detectionType))
        DropPlayer(source, reason)
    end
end

-- Apply correct damage to target
function api.damageValidator.applyCorrectDamage(targetEntity, damage, attacker)
    local targetPed = NetworkGetEntityFromNetworkId(targetEntity)
    if targetPed and targetPed ~= 0 then
        ApplyDamageToPed(targetPed, damage, false)
        if config.debug.printDamage then
            _debug(('Applied %.1f damage from player %d to entity %d'):format(damage, attacker, targetEntity))
        end
    end
end

-- Log damage event
function api.damageValidator.logDamageEvent(source, data, validation, status)
    if config.debug.code then
        _debug(('Damage Log] Player %d | Status: %s'):format(source, status))
        if validation then
            _debug(('  Expected: %.1f | Variance: %.2f%% | Bone: %s'):format(
                validation.expected, validation.variance * 100, validation.boneGroup
            ))
        end
    end
end

-- Log detection to database
function api.damageValidator.logToDatabase(source, detection)
    if not config.antiCheat.databaseExport then return end
end

-- Clean up player data on disconnect
AddEventHandler('playerDropped', function()
    local source = source
    validationState.playerStats[source] = nil

    if config.debug.code then
        _debug(('[Damage Validator] Cleaned up data for player %d'):format(source))
    end
end)

-- Get player statistics
function api.damageValidator.getPlayerStats(source)
    return validationState.playerStats[source]
end

-- Get detection log
function api.damageValidator.getDetectionLog()
    return validationState.detectionLog
end

-- Reset player statistics
function api.damageValidator.resetPlayerStats(source)
    validationState.playerStats[source] = nil
    _debug(('[Damage Validator] Reset stats for player %d'):format(source))
end

exports('getPlayerStats', api.damageValidator.getPlayerStats)
exports('getDetectionLog', api.damageValidator.getDetectionLog)
exports('resetPlayerStats', api.damageValidator.resetPlayerStats)

return api.damageValidator
