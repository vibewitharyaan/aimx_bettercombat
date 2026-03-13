presets = {}

local presetRegistry = {}

-- Initialize presets from config
CreateThread(function()
    if config.presets then
        for name, data in pairs(config.presets) do
            presetRegistry[name] = data
        end
    end
end)

-- Get preset by name
function presets.get(name)
    return presetRegistry[name]
end

-- Get all preset names
function presets.getAll()
    local names = {}
    for name in pairs(presetRegistry) do
        table.insert(names, name)
    end
    return names
end

-- Register custom preset
function presets.register(preset)
    if not preset.name then
        error('Preset must have a name field')
    end

    if not preset.recoil or not preset.damage or not preset.validation then
        error('Invalid preset structure: missing required fields')
    end

    presetRegistry[preset.name] = preset

    if config.debug.code then
        _debug(('[Weapon Framework] Registered custom preset: %s'):format(preset.name))
    end
end

-- Calculate effective recoil for weapon with preset
function presets.calculateRecoil(weaponHash, preset, inVehicle)
    local weapon = config.getWeapon(weaponHash)
    if not weapon then return 0 end

    local recoil = weapon.baseRecoil
    recoil = recoil * preset.recoil.globalMultiplier

    if preset.recoil.weaponMultipliers[weaponHash] then
        recoil = recoil * preset.recoil.weaponMultipliers[weaponHash]
    end

    if inVehicle then
        local driveByMult = config.getDriveByMultiplier(weaponHash).recoil
        recoil = recoil * driveByMult * preset.recoil.driveByMultiplier
    end

    return recoil
end

-- Calculate effective damage for weapon with preset
function presets.calculateDamage(weaponHash, boneGroup, preset, inVehicle)
    local weapon = config.getWeapon(weaponHash)
    if not weapon then return 0 end

    local damage = weapon.baseDamage
    damage = damage * preset.damage.globalMultiplier

    if preset.damage.weaponMultipliers[weaponHash] then
        damage = damage * preset.damage.weaponMultipliers[weaponHash]
    end

    local boneMult = preset.damage.boneMultipliers[boneGroup] or 1.0
    damage = damage * boneMult

    if boneGroup == 'head' and preset.damage.headshotCap then
        damage = math.min(damage, preset.damage.headshotCap)
    end

    if inVehicle then
        local driveByMult = config.getDriveByMultiplier(weaponHash).damage
        damage = damage * driveByMult * preset.damage.driveByMultiplier
    end

    return damage
end

-- Validate damage against preset tolerance
function presets.validateDamage(reported, expected, preset)
    if expected == 0 then return true, 0 end

    local variance = math.abs(reported - expected) / expected
    local tolerance = preset.validation.damageTolerance

    return variance <= tolerance, variance
end

return presets
