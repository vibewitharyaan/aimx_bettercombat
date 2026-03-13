presets = {}

presets.realistic = {
    name = 'realistic',
    description = 'Balanced realistic combat for RP servers',
    recoil = {
        globalMultiplier = 1.0,
        weaponMultipliers = {
            [`WEAPON_PISTOL`] = 0.8,
            [`WEAPON_PISTOL50`] = 1.2,
        },
        driveByMultiplier = 1.0,
        recoveryDelay = 150,
        recoveryRate = 0.002,
    },
    damage = {
        globalMultiplier = 1.0,
        weaponMultipliers = {
            [`WEAPON_HEAVYSNIPER`] = 0.7,
        },
        boneMultipliers = {
            head = 2.5,
            torso = 1.0,
            legs = 0.7,
            arms = 0.8,
        },
        headshotCap = 120,
        driveByMultiplier = 1.0,
    },
    validation = {
        damageTolerance = 0.15,
        recoilTolerance = 0.20,
        maxHeadshotRate = 0.50,
        minShotsForHeadshotCalc = 20,
    },
}

presets.competitive = {
    name = 'competitive',
    description = 'Low-recoil competitive PvP',
    recoil = {
        globalMultiplier = 0.6,
        weaponMultipliers = {},
        driveByMultiplier = 1.2,
        recoveryDelay = 100,
        recoveryRate = 0.003,
    },
    damage = {
        globalMultiplier = 1.2,
        weaponMultipliers = {},
        boneMultipliers = {
            head = 3.0,
            torso = 1.0,
            legs = 0.6,
            arms = 0.7,
        },
        headshotCap = nil,
        driveByMultiplier = 0.8,
    },
    validation = {
        damageTolerance = 0.10,
        recoilTolerance = 0.15,
        maxHeadshotRate = 0.65,
        minShotsForHeadshotCalc = 30,
    },
}

presets.hardcore = {
    name = 'hardcore',
    description = 'High recoil, realistic lethality',
    recoil = {
        globalMultiplier = 1.5,
        weaponMultipliers = {
            [`WEAPON_COMBATMG`] = 1.8,
            [`WEAPON_GUSENBERG`] = 1.6,
        },
        driveByMultiplier = 2.0,
        recoveryDelay = 200,
        recoveryRate = 0.0015,
    },
    damage = {
        globalMultiplier = 1.5,
        weaponMultipliers = {},
        boneMultipliers = {
            head = 5.0,
            torso = 1.2,
            legs = 0.8,
            arms = 0.9,
        },
        headshotCap = nil,
        driveByMultiplier = 0.6,
    },
    validation = {
        damageTolerance = 0.15,
        recoilTolerance = 0.20,
        maxHeadshotRate = 0.45,
        minShotsForHeadshotCalc = 25,
    },
}

presets.arcade = {
    name = 'arcade',
    description = 'Easy recoil, forgiving damage',
    recoil = {
        globalMultiplier = 0.3,
        weaponMultipliers = {},
        driveByMultiplier = 0.8,
        recoveryDelay = 80,
        recoveryRate = 0.005,
    },
    damage = {
        globalMultiplier = 0.8,
        weaponMultipliers = {},
        boneMultipliers = {
            head = 1.5,
            torso = 1.0,
            legs = 0.9,
            arms = 0.95,
        },
        headshotCap = 80,
        driveByMultiplier = 1.0,
    },
    validation = {
        damageTolerance = 0.20,
        recoilTolerance = 0.25,
        maxHeadshotRate = 0.70,
        minShotsForHeadshotCalc = 15,
    },
}

local presetRegistry = {
    realistic = presets.realistic,
    competitive = presets.competitive,
    hardcore = presets.hardcore,
    arcade = presets.arcade,
}

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
