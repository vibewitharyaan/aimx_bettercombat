-- ============================================================================
-- WEAPON FRAMEWORK - CORE CONFIGURATION
-- ============================================================================
-- Production-grade weapon recoil and damage system
-- Server-authoritative, client-assisted, cache-optimized
-- ============================================================================

Config = {}

-- ============================================================================
-- FRAMEWORK MODE
-- ============================================================================

-- Operation mode: 'single' or 'multi'
-- single: One preset for entire server (RP mode)
-- multi: Multiple presets assigned per player (PvP/Arena mode)
Config.Mode = 'single'

-- Default preset name (used in single-preset mode)
Config.DefaultPreset = 'realistic'

-- ============================================================================
-- PERFORMANCE SETTINGS
-- ============================================================================

-- Recoil update frequency (ms) - only runs while shooting
Config.RecoilUpdateInterval = 0 -- 0 = every frame (recommended)

-- Recoil recovery window (ms) - time before decay starts
Config.RecoilRecoveryWindow = 150

-- Recoil decay rate (per ms)
Config.RecoilDecayRate = 0.002

-- ============================================================================
-- ANTI-CHEAT CONFIGURATION
-- ============================================================================

Config.AntiCheat = {
    -- Enable damage validation and anti-cheat system
    -- Set to false during development/tuning to allow unrestricted testing
    enabled = false,  -- Change to true for production
    
    -- Logging level: 'none', 'suspicious', 'all'
    logLevel = 'suspicious',
    
    -- Action on detection: 'log', 'kick', 'ban'
    action = 'log',
    
    -- Minimum detections before action (if action != 'log')
    minDetections = 5,
    
    -- Detection window (seconds) - reset count after this period
    detectionWindow = 300,
    
    -- Database logging (set your export here if enabled)
    useDatabase = false,
    databaseExport = nil, -- e.g., 'oxmysql'
}

-- ============================================================================
-- WEAPON DEFINITIONS
-- ============================================================================
-- Base weapon properties that presets will modify
-- All damage values are BASE values before multipliers
-- ============================================================================

Config.Weapons = {
    -- Pistols
    [`WEAPON_PISTOL`] = {
        name = 'Combat Pistol',
        class = 'pistol',
        baseDamage = 25,
        baseRecoil = 0.15,
        verticalRecoil = 0.12,
        horizontalRecoil = 0.08,
        fireRate = 400, -- RPM
    },
    
    [`WEAPON_PISTOL50`] = {
        name = 'Pistol .50',
        class = 'pistol',
        baseDamage = 40,
        baseRecoil = 0.35,
        verticalRecoil = 0.30,
        horizontalRecoil = 0.15,
        fireRate = 300,
    },
    
    [`WEAPON_APPISTOL`] = {
        name = 'AP Pistol',
        class = 'pistol',
        baseDamage = 22,
        baseRecoil = 0.10,
        verticalRecoil = 0.08,
        horizontalRecoil = 0.06,
        fireRate = 800,
    },
    
    -- SMGs
    [`WEAPON_MICROSMG`] = {
        name = 'Micro SMG',
        class = 'smg',
        baseDamage = 18,
        baseRecoil = 0.12,
        verticalRecoil = 0.10,
        horizontalRecoil = 0.08,
        fireRate = 900,
    },
    
    [`WEAPON_SMG`] = {
        name = 'SMG',
        class = 'smg',
        baseDamage = 20,
        baseRecoil = 0.14,
        verticalRecoil = 0.11,
        horizontalRecoil = 0.09,
        fireRate = 750,
    },
    
    -- Assault Rifles
    [`WEAPON_ASSAULTRIFLE`] = {
        name = 'Assault Rifle',
        class = 'rifle',
        baseDamage = 30,
        baseRecoil = 0.18,
        verticalRecoil = 0.15,
        horizontalRecoil = 0.10,
        fireRate = 600,
    },
    
    [`WEAPON_CARBINERIFLE`] = {
        name = 'Carbine Rifle',
        class = 'rifle',
        baseDamage = 28,
        baseRecoil = 0.16,
        verticalRecoil = 0.13,
        horizontalRecoil = 0.09,
        fireRate = 700,
    },
    
    [`WEAPON_ADVANCEDRIFLE`] = {
        name = 'Advanced Rifle',
        class = 'rifle',
        baseDamage = 32,
        baseRecoil = 0.20,
        verticalRecoil = 0.17,
        horizontalRecoil = 0.11,
        fireRate = 650,
    },
    
    -- Sniper Rifles
    [`WEAPON_SNIPERRIFLE`] = {
        name = 'Sniper Rifle',
        class = 'sniper',
        baseDamage = 100,
        baseRecoil = 0.50,
        verticalRecoil = 0.45,
        horizontalRecoil = 0.10,
        fireRate = 60,
    },
    
    [`WEAPON_HEAVYSNIPER`] = {
        name = 'Heavy Sniper',
        class = 'sniper',
        baseDamage = 150,
        baseRecoil = 0.80,
        verticalRecoil = 0.75,
        horizontalRecoil = 0.15,
        fireRate = 30,
    },
    
    -- Shotguns
    [`WEAPON_PUMPSHOTGUN`] = {
        name = 'Pump Shotgun',
        class = 'shotgun',
        baseDamage = 80,
        baseRecoil = 0.40,
        verticalRecoil = 0.38,
        horizontalRecoil = 0.12,
        fireRate = 90,
    },
    
    [`WEAPON_SAWNOFFSHOTGUN`] = {
        name = 'Sawed-Off Shotgun',
        class = 'shotgun',
        baseDamage = 75,
        baseRecoil = 0.50,
        verticalRecoil = 0.45,
        horizontalRecoil = 0.20,
        fireRate = 100,
    },
    
    -- Machine Guns
    [`WEAPON_COMBATMG`] = {
        name = 'Combat MG',
        class = 'mg',
        baseDamage = 35,
        baseRecoil = 0.25,
        verticalRecoil = 0.22,
        horizontalRecoil = 0.15,
        fireRate = 800,
    },
    
    [`WEAPON_GUSENBERG`] = {
        name = 'Gusenberg Sweeper',
        class = 'mg',
        baseDamage = 25,
        baseRecoil = 0.20,
        verticalRecoil = 0.18,
        horizontalRecoil = 0.12,
        fireRate = 550,
    },
}

-- ============================================================================
-- DRIVE-BY MULTIPLIERS
-- ============================================================================
-- Applied when shooting from vehicle
-- Format: { recoilMultiplier, damageMultiplier }
-- ============================================================================

Config.DriveByMultipliers = {
    pistol = { recoil = 1.5, damage = 0.8 },   -- +50% recoil, -20% damage
    smg = { recoil = 1.8, damage = 0.7 },       -- +80% recoil, -30% damage
    rifle = { recoil = 2.5, damage = 0.6 },     -- +150% recoil, -40% damage
    sniper = { recoil = 3.0, damage = 0.5 },    -- +200% recoil, -50% damage
    shotgun = { recoil = 2.0, damage = 0.7 },   -- +100% recoil, -30% damage
    mg = { recoil = 2.2, damage = 0.65 },       -- +120% recoil, -35% damage
}

-- ============================================================================
-- TUNER SETTINGS
-- ============================================================================

Config.Tuner = {
    -- Permission required to access tuner
    -- Uses ox_lib ACE system: 'group.admin', 'group.developer', etc.
    permission = 'group.admin',
    
    -- Command to open tuner
    command = 'weapontuner',
    
    -- Allow real-time preview (applies changes immediately)
    livePreview = true,
    
    -- Export format: 'lua', 'json', 'both'
    exportFormat = 'both',
}

-- ============================================================================
-- DEBUG SETTINGS
-- ============================================================================

Config.Debug = {
    -- Enable debug logging
    enabled = false,
    
    -- Show recoil visualization (client-side overlay)
    visualizeRecoil = false,
    
    -- Print damage calculations
    printDamage = false,
    
    -- Show bone hit locations
    showBoneHits = false,
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

---Get weapon data by hash
---@param weaponHash number
---@return table|nil
function Config.GetWeapon(weaponHash)
    return Config.Weapons[weaponHash]
end

---Get weapon class by hash
---@param weaponHash number
---@return string|nil
function Config.GetWeaponClass(weaponHash)
    local weapon = Config.GetWeapon(weaponHash)
    return weapon and weapon.class or nil
end

---Get drive-by multiplier for weapon
---@param weaponHash number
---@return table|nil { recoil: number, damage: number }
function Config.GetDriveByMultiplier(weaponHash)
    local class = Config.GetWeaponClass(weaponHash)
    return class and Config.DriveByMultipliers[class] or { recoil = 1.0, damage = 1.0 }
end

return Config
