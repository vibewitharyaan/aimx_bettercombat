-- ============================================================================
-- WEAPON FRAMEWORK - PRESET DEFINITIONS
-- ============================================================================
-- Defines combat behavior profiles for different game modes
-- Each preset is the SINGLE SOURCE OF TRUTH for validation
-- ============================================================================

presets = {}

-- ============================================================================
-- PRESET: REALISTIC (Default RP Mode)
-- ============================================================================
-- Balanced for roleplay servers
-- Moderate recoil, realistic damage, headshots significant
-- ============================================================================

presets.realistic = {
    name = 'realistic',
    description = 'Balanced realistic combat for RP servers',
    
    -- ========================================================================
    -- RECOIL MODIFIERS
    -- ========================================================================
    recoil = {
        -- Global multiplier applied to all weapons
        globalMultiplier = 1.0,
        
        -- Per-weapon multipliers (override global for specific weapons)
        weaponMultipliers = {
            -- Example: Make pistols easier to control
            [`WEAPON_PISTOL`] = 0.8,
            [`WEAPON_PISTOL50`] = 1.2, -- Heavy pistol harder to control
        },
        
        -- Drive-by multiplier (applied to base drive-by values)
        driveByMultiplier = 1.0,
        
        -- Recovery settings
        recoveryDelay = 150,    -- ms before decay starts
        recoveryRate = 0.002,   -- decay per ms
    },
    
    -- ========================================================================
    -- DAMAGE MODIFIERS
    -- ========================================================================
    damage = {
        -- Global damage multiplier
        globalMultiplier = 1.0,
        
        -- Per-weapon multipliers
        weaponMultipliers = {
            -- Example: Nerf heavy sniper for RP balance
            [`WEAPON_HEAVYSNIPER`] = 0.7,
        },
        
        -- Bone group damage multipliers
        boneMultipliers = {
            head = 2.5,     -- Headshots deal 2.5x damage
            torso = 1.0,    -- Body shots normal damage
            legs = 0.7,     -- Leg shots deal 70% damage
            arms = 0.8,     -- Arm shots deal 80% damage
        },
        
        -- Maximum headshot damage cap (prevents one-shot kills in RP)
        -- Set to nil for no cap
        headshotCap = 120,
        
        -- Drive-by damage multiplier
        driveByMultiplier = 1.0,
    },
    
    -- ========================================================================
    -- VALIDATION TOLERANCES (ANTI-CHEAT)
    -- ========================================================================
    -- Players are ONLY flagged if they exceed these bounds
    validation = {
        -- Damage variance tolerance (0.15 = ±15%)
        -- Accounts for network latency and floating point precision
        damageTolerance = 0.15,
        
        -- Recoil variance tolerance (0.20 = ±20%)
        -- More lenient due to client-side calculations
        recoilTolerance = 0.20,
        
        -- Maximum allowed headshot percentage (0.50 = 50% headshot rate)
        -- Flags players with suspiciously high headshot rates
        maxHeadshotRate = 0.50,
        
        -- Minimum shots before headshot rate is calculated
        minShotsForHeadshotCalc = 20,
    },
}

-- ============================================================================
-- PRESET: COMPETITIVE (PvP Mode)
-- ============================================================================
-- Lower recoil, faster-paced combat
-- Headshots critical, rewards accuracy
-- ============================================================================

presets.competitive = {
    name = 'competitive',
    description = 'Low-recoil competitive PvP',
    
    recoil = {
        globalMultiplier = 0.6,  -- 40% less recoil than realistic
        weaponMultipliers = {},
        driveByMultiplier = 1.2, -- Drive-by is harder
        recoveryDelay = 100,
        recoveryRate = 0.003,
    },
    
    damage = {
        globalMultiplier = 1.2,  -- 20% more damage for faster TTK
        weaponMultipliers = {},
        boneMultipliers = {
            head = 3.0,      -- Headshots critical
            torso = 1.0,
            legs = 0.6,
            arms = 0.7,
        },
        headshotCap = nil,   -- No cap in competitive
        driveByMultiplier = 0.8,
    },
    
    validation = {
        damageTolerance = 0.10,  -- Tighter tolerance in competitive
        recoilTolerance = 0.15,
        maxHeadshotRate = 0.65,  -- Skilled players allowed higher
        minShotsForHeadshotCalc = 30,
    },
}

-- ============================================================================
-- PRESET: HARDCORE (Realism Mode)
-- ============================================================================
-- High recoil, low TTK
-- Every bullet counts
-- ============================================================================

presets.hardcore = {
    name = 'hardcore',
    description = 'High recoil, realistic lethality',
    
    recoil = {
        globalMultiplier = 1.5,  -- 50% more recoil
        weaponMultipliers = {
            -- Machine guns significantly harder
            [`WEAPON_COMBATMG`] = 1.8,
            [`WEAPON_GUSENBERG`] = 1.6,
        },
        driveByMultiplier = 2.0, -- Drive-by nearly impossible
        recoveryDelay = 200,
        recoveryRate = 0.0015,
    },
    
    damage = {
        globalMultiplier = 1.5,  -- High lethality
        weaponMultipliers = {},
        boneMultipliers = {
            head = 5.0,      -- Instant or near-instant headshot kills
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
        maxHeadshotRate = 0.45,  -- Lower due to high recoil
        minShotsForHeadshotCalc = 25,
    },
}

-- ============================================================================
-- PRESET: ARCADE (Casual Mode)
-- ============================================================================
-- Very low recoil, forgiving damage
-- Fun and accessible
-- ============================================================================

presets.arcade = {
    name = 'arcade',
    description = 'Easy recoil, forgiving damage',
    
    recoil = {
        globalMultiplier = 0.3,  -- 70% less recoil
        weaponMultipliers = {},
        driveByMultiplier = 0.8, -- Drive-by easier
        recoveryDelay = 80,
        recoveryRate = 0.005,
    },
    
    damage = {
        globalMultiplier = 0.8,  -- Lower damage for longer fights
        weaponMultipliers = {},
        boneMultipliers = {
            head = 1.5,      -- Headshots less critical
            torso = 1.0,
            legs = 0.9,
            arms = 0.95,
        },
        headshotCap = 80,    -- Cap headshot damage
        driveByMultiplier = 1.0,
    },
    
    validation = {
        damageTolerance = 0.20,  -- More lenient
        recoilTolerance = 0.25,
        maxHeadshotRate = 0.70,  -- High accuracy acceptable
        minShotsForHeadshotCalc = 15,
    },
}

-- ============================================================================
-- PRESET REGISTRY
-- ============================================================================

local presetRegistry = {
    realistic = presets.realistic,
    competitive = presets.competitive,
    hardcore = presets.hardcore,
    arcade = presets.arcade,
}

-- ============================================================================
-- PRESET UTILITIES
-- ============================================================================

---Get preset by name
---@param name string
---@return table|nil
function presets.get(name)
    return presetRegistry[name]
end

---Get all preset names
---@return string[]
function presets.getAll()
    local names = {}
    for name in pairs(presetRegistry) do
        table.insert(names, name)
    end
    return names
end

---Register custom preset
---@param preset table
function presets.register(preset)
    if not preset.name then
        error('Preset must have a name field')
    end
    
    -- Validate preset structure
    if not preset.recoil or not preset.damage or not preset.validation then
        error('Invalid preset structure: missing required fields')
    end
    
    presetRegistry[preset.name] = preset
    
    if config.debug.enabled then
        print(('[Weapon Framework] Registered custom preset: %s'):format(preset.name))
    end
end

---Calculate effective recoil for weapon with preset
---@param weaponHash number
---@param preset table
---@param inVehicle boolean
---@return number
function presets.calculateRecoil(weaponHash, preset, inVehicle)
    local weapon = config.getWeapon(weaponHash)
    if not weapon then return 0 end
    
    local recoil = weapon.baseRecoil
    
    -- Apply preset global multiplier
    recoil = recoil * preset.recoil.globalMultiplier
    
    -- Apply weapon-specific multiplier if exists
    if preset.recoil.weaponMultipliers[weaponHash] then
        recoil = recoil * preset.recoil.weaponMultipliers[weaponHash]
    end
    
    -- Apply drive-by multiplier if in vehicle
    if inVehicle then
        local driveByMult = config.getDriveByMultiplier(weaponHash).recoil
        recoil = recoil * driveByMult * preset.recoil.driveByMultiplier
    end
    
    return recoil
end

---Calculate effective damage for weapon with preset
---@param weaponHash number
---@param boneGroup string
---@param preset table
---@param inVehicle boolean
---@return number
function presets.calculateDamage(weaponHash, boneGroup, preset, inVehicle)
    local weapon = config.getWeapon(weaponHash)
    if not weapon then return 0 end
    
    local damage = weapon.baseDamage
    
    -- Apply preset global multiplier
    damage = damage * preset.damage.globalMultiplier
    
    -- Apply weapon-specific multiplier if exists
    if preset.damage.weaponMultipliers[weaponHash] then
        damage = damage * preset.damage.weaponMultipliers[weaponHash]
    end
    
    -- Apply bone multiplier
    local boneMult = preset.damage.boneMultipliers[boneGroup] or 1.0
    damage = damage * boneMult
    
    -- Apply headshot cap if applicable
    if boneGroup == 'head' and preset.damage.headshotCap then
        damage = math.min(damage, preset.damage.headshotCap)
    end
    
    -- Apply drive-by multiplier if in vehicle
    if inVehicle then
        local driveByMult = config.getDriveByMultiplier(weaponHash).damage
        damage = damage * driveByMult * preset.damage.driveByMultiplier
    end
    
    return damage
end

---Validate damage against preset tolerance
---@param reported number
---@param expected number
---@param preset table
---@return boolean withinBounds
---@return number variance
function presets.validateDamage(reported, expected, preset)
    if expected == 0 then return true, 0 end
    
    local variance = math.abs(reported - expected) / expected
    local tolerance = preset.validation.damageTolerance
    
    return variance <= tolerance, variance
end

return Presets
