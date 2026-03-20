--[[
    WEAPON DEFINITIONS
    ────────────────────────────────────────────────────────────────────────────
    Each entry is keyed by GetHashKey('WEAPON_XXX').

    ── damage ───────────────────────────────────────────────────────────────────
    Passed directly to SetWeaponDamageModifier(hash, value).
    Applied once on weapon equip and again whenever the active preset changes.
    GTA's engine applies it to every outgoing bullet automatically.
    GTA's native headshot advantage stays active at all times — no extra code.

        1.0  = GTA default
        0.7  = 30% less  (RP servers, longer fights)
        1.4  = 40% more  (PvP servers, faster TTK)

    ── recoil.fpp / .tpp / .driveby ─────────────────────────────────────────────
    Per-shot camera kick in degrees, BEFORE the active preset's recoilMult.
    These are the base values. The preset scales them at runtime.

        up    — degrees camera is pushed upward each shot
        side  — max random horizontal drift ± each shot (degrees)

    WHY SEPARATE FPP AND TPP?
    The same angular movement feels 2–3× more pronounced in first-person
    because the FOV is tighter and there is no character body as visual anchor.
    FPP values are ~45–55% of TPP so both views feel equally controllable.

    ── shake ─────────────────────────────────────────────────────────────────────
    Amplitude for ShakeGameplayCam('HAND_SHAKE', n). Range 0.0 – 1.0.
    Adds tactile feel without rotating the camera.

    ── fireRate ──────────────────────────────────────────────────────────────────
    Rounds per minute. Used to throttle recoil kicks on automatic weapons so
    exactly one kick is applied per bullet, not one per frame.

    ── CONFIG.weaponGroups (bottom of file) ──────────────────────────────────────
    Fallback table keyed by GetWeapontypeGroup() for addon / custom weapons
    not listed in config.weapons. Ensures modded servers always get a sensible
    result instead of a generic placeholder.
    Group hash values match the popular server's GroupRecoil table exactly.
]]

config.weapons = {

    -- ── PISTOLS ───────────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_PISTOL')] = {
        hashStr  = 'WEAPON_PISTOL',
        name     = 'Pistol',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.60, side = 0.18 },
            tpp     = { up = 1.10, side = 0.32 },
            driveby = { up = 1.80, side = 0.65 },
        },
        shake    = 0.08,
        fireRate = 400,
    },

    [GetHashKey('WEAPON_COMBATPISTOL')] = {
        hashStr  = 'WEAPON_COMBATPISTOL',
        name     = 'Combat Pistol',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.55, side = 0.16 },
            tpp     = { up = 1.00, side = 0.28 },
            driveby = { up = 1.70, side = 0.58 },
        },
        shake    = 0.08,
        fireRate = 450,
    },

    [GetHashKey('WEAPON_PISTOL50')] = {
        hashStr  = 'WEAPON_PISTOL50',
        name     = 'Pistol .50',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.00, side = 0.28 },
            tpp     = { up = 1.80, side = 0.50 },
            driveby = { up = 2.80, side = 0.90 },
        },
        shake    = 0.16,
        fireRate = 280,
    },

    [GetHashKey('WEAPON_HEAVYPISTOL')] = {
        hashStr  = 'WEAPON_HEAVYPISTOL',
        name     = 'Heavy Pistol',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.85, side = 0.24 },
            tpp     = { up = 1.55, side = 0.45 },
            driveby = { up = 2.50, side = 0.80 },
        },
        shake    = 0.14,
        fireRate = 320,
    },

    [GetHashKey('WEAPON_APPISTOL')] = {
        hashStr  = 'WEAPON_APPISTOL',
        name     = 'AP Pistol',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.40, side = 0.20 },
            tpp     = { up = 0.75, side = 0.38 },
            driveby = { up = 1.30, side = 0.70 },
        },
        shake    = 0.07,
        fireRate = 800,
    },

    [GetHashKey('WEAPON_SNSPISTOL')] = {
        hashStr  = 'WEAPON_SNSPISTOL',
        name     = 'SNS Pistol',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.65, side = 0.20 },
            tpp     = { up = 1.20, side = 0.36 },
            driveby = { up = 1.90, side = 0.70 },
        },
        shake    = 0.10,
        fireRate = 420,
    },

    [GetHashKey('WEAPON_REVOLVER')] = {
        hashStr  = 'WEAPON_REVOLVER',
        name     = 'Revolver',
        class    = 'pistol',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.20, side = 0.30 },
            tpp     = { up = 2.20, side = 0.55 },
            driveby = { up = 3.50, side = 1.00 },
        },
        shake    = 0.20,
        fireRate = 90,
    },

    -- ── SMGs ──────────────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_MICROSMG')] = {
        hashStr  = 'WEAPON_MICROSMG',
        name     = 'Micro SMG',
        class    = 'smg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.38, side = 0.25 },
            tpp     = { up = 0.70, side = 0.45 },
            driveby = { up = 1.20, side = 0.80 },
        },
        shake    = 0.07,
        fireRate = 900,
    },

    [GetHashKey('WEAPON_SMG')] = {
        hashStr  = 'WEAPON_SMG',
        name     = 'SMG',
        class    = 'smg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.45, side = 0.22 },
            tpp     = { up = 0.85, side = 0.40 },
            driveby = { up = 1.40, side = 0.75 },
        },
        shake    = 0.08,
        fireRate = 750,
    },

    [GetHashKey('WEAPON_ASSAULTSMG')] = {
        hashStr  = 'WEAPON_ASSAULTSMG',
        name     = 'Assault SMG',
        class    = 'smg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.42, side = 0.22 },
            tpp     = { up = 0.78, side = 0.40 },
            driveby = { up = 1.30, side = 0.72 },
        },
        shake    = 0.08,
        fireRate = 800,
    },

    [GetHashKey('WEAPON_COMBATPDW')] = {
        hashStr  = 'WEAPON_COMBATPDW',
        name     = 'Combat PDW',
        class    = 'smg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.40, side = 0.20 },
            tpp     = { up = 0.75, side = 0.36 },
            driveby = { up = 1.25, side = 0.68 },
        },
        shake    = 0.07,
        fireRate = 820,
    },

    [GetHashKey('WEAPON_MINISMG')] = {
        hashStr  = 'WEAPON_MINISMG',
        name     = 'Mini SMG',
        class    = 'smg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.50, side = 0.28 },
            tpp     = { up = 0.92, side = 0.50 },
            driveby = { up = 1.55, side = 0.88 },
        },
        shake    = 0.09,
        fireRate = 850,
    },

    -- ── ASSAULT RIFLES ────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_ASSAULTRIFLE')] = {
        hashStr  = 'WEAPON_ASSAULTRIFLE',
        name     = 'Assault Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.65, side = 0.22 },
            tpp     = { up = 1.20, side = 0.40 },
            driveby = { up = 2.20, side = 0.85 },
        },
        shake    = 0.10,
        fireRate = 600,
    },

    [GetHashKey('WEAPON_ASSAULTRIFLE_MK2')] = {
        hashStr  = 'WEAPON_ASSAULTRIFLE_MK2',
        name     = 'Assault Rifle Mk II',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.62, side = 0.21 },
            tpp     = { up = 1.15, side = 0.38 },
            driveby = { up = 2.10, side = 0.82 },
        },
        shake    = 0.10,
        fireRate = 620,
    },

    [GetHashKey('WEAPON_CARBINERIFLE')] = {
        hashStr  = 'WEAPON_CARBINERIFLE',
        name     = 'Carbine Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.60, side = 0.20 },
            tpp     = { up = 1.10, side = 0.36 },
            driveby = { up = 2.00, side = 0.78 },
        },
        shake    = 0.10,
        fireRate = 650,
    },

    [GetHashKey('WEAPON_CARBINERIFLE_MK2')] = {
        hashStr  = 'WEAPON_CARBINERIFLE_MK2',
        name     = 'Carbine Rifle Mk II',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.58, side = 0.19 },
            tpp     = { up = 1.05, side = 0.34 },
            driveby = { up = 1.90, side = 0.75 },
        },
        shake    = 0.09,
        fireRate = 670,
    },

    [GetHashKey('WEAPON_ADVANCEDRIFLE')] = {
        hashStr  = 'WEAPON_ADVANCEDRIFLE',
        name     = 'Advanced Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.55, side = 0.18 },
            tpp     = { up = 1.00, side = 0.32 },
            driveby = { up = 1.90, side = 0.72 },
        },
        shake    = 0.09,
        fireRate = 750,
    },

    [GetHashKey('WEAPON_SPECIALCARBINE')] = {
        hashStr  = 'WEAPON_SPECIALCARBINE',
        name     = 'Special Carbine',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.58, side = 0.19 },
            tpp     = { up = 1.05, side = 0.34 },
            driveby = { up = 1.95, side = 0.75 },
        },
        shake    = 0.09,
        fireRate = 680,
    },

    [GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = {
        hashStr  = 'WEAPON_SPECIALCARBINE_MK2',
        name     = 'Special Carbine Mk II',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.56, side = 0.18 },
            tpp     = { up = 1.02, side = 0.33 },
            driveby = { up = 1.88, side = 0.73 },
        },
        shake    = 0.09,
        fireRate = 690,
    },

    [GetHashKey('WEAPON_BULLPUPRIFLE')] = {
        hashStr  = 'WEAPON_BULLPUPRIFLE',
        name     = 'Bullpup Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.60, side = 0.20 },
            tpp     = { up = 1.10, side = 0.36 },
            driveby = { up = 2.00, side = 0.80 },
        },
        shake    = 0.10,
        fireRate = 660,
    },

    [GetHashKey('WEAPON_HEAVYRIFLE')] = {
        hashStr  = 'WEAPON_HEAVYRIFLE',
        name     = 'Heavy Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.72, side = 0.22 },
            tpp     = { up = 1.32, side = 0.40 },
            driveby = { up = 2.40, side = 0.88 },
        },
        shake    = 0.11,
        fireRate = 540,
    },

    [GetHashKey('WEAPON_MILITARYRIFLE')] = {
        hashStr  = 'WEAPON_MILITARYRIFLE',
        name     = 'Military Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.62, side = 0.20 },
            tpp     = { up = 1.14, side = 0.37 },
            driveby = { up = 2.08, side = 0.80 },
        },
        shake    = 0.10,
        fireRate = 640,
    },

    [GetHashKey('WEAPON_TACTICALRIFLE')] = {
        hashStr  = 'WEAPON_TACTICALRIFLE',
        name     = 'Tactical Rifle',
        class    = 'rifle',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.68, side = 0.24 },
            tpp     = { up = 1.25, side = 0.44 },
            driveby = { up = 2.25, side = 0.90 },
        },
        shake    = 0.10,
        fireRate = 580,
    },

    -- ── SHOTGUNS ──────────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_PUMPSHOTGUN')] = {
        hashStr  = 'WEAPON_PUMPSHOTGUN',
        name     = 'Pump Shotgun',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.60, side = 0.50 },
            tpp     = { up = 3.00, side = 0.90 },
            driveby = { up = 4.50, side = 1.50 },
        },
        shake    = 0.28,
        fireRate = 60,
    },

    [GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = {
        hashStr  = 'WEAPON_PUMPSHOTGUN_MK2',
        name     = 'Pump Shotgun Mk II',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.55, side = 0.48 },
            tpp     = { up = 2.85, side = 0.86 },
            driveby = { up = 4.30, side = 1.45 },
        },
        shake    = 0.27,
        fireRate = 65,
    },

    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = {
        hashStr  = 'WEAPON_SAWNOFFSHOTGUN',
        name     = 'Sawn-off Shotgun',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.80, side = 0.70 },
            tpp     = { up = 3.40, side = 1.20 },
            driveby = { up = 5.00, side = 1.80 },
        },
        shake    = 0.32,
        fireRate = 55,
    },

    [GetHashKey('WEAPON_ASSAULTSHOTGUN')] = {
        hashStr  = 'WEAPON_ASSAULTSHOTGUN',
        name     = 'Assault Shotgun',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.20, side = 0.40 },
            tpp     = { up = 2.20, side = 0.70 },
            driveby = { up = 3.50, side = 1.20 },
        },
        shake    = 0.22,
        fireRate = 180,
    },

    [GetHashKey('WEAPON_BULLPUPSHOTGUN')] = {
        hashStr  = 'WEAPON_BULLPUPSHOTGUN',
        name     = 'Bullpup Shotgun',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.40, side = 0.45 },
            tpp     = { up = 2.60, side = 0.82 },
            driveby = { up = 4.00, side = 1.35 },
        },
        shake    = 0.25,
        fireRate = 150,
    },

    [GetHashKey('WEAPON_HEAVYSHOTGUN')] = {
        hashStr  = 'WEAPON_HEAVYSHOTGUN',
        name     = 'Heavy Shotgun',
        class    = 'shotgun',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.70, side = 0.55 },
            tpp     = { up = 3.20, side = 1.00 },
            driveby = { up = 4.80, side = 1.60 },
        },
        shake    = 0.30,
        fireRate = 80,
    },

    -- ── MACHINE GUNS ──────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_MG')] = {
        hashStr  = 'WEAPON_MG',
        name     = 'MG',
        class    = 'mg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.70, side = 0.35 },
            tpp     = { up = 1.30, side = 0.62 },
            driveby = { up = 2.50, side = 1.10 },
        },
        shake    = 0.12,
        fireRate = 900,
    },

    [GetHashKey('WEAPON_COMBATMG')] = {
        hashStr  = 'WEAPON_COMBATMG',
        name     = 'Combat MG',
        class    = 'mg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.80, side = 0.40 },
            tpp     = { up = 1.50, side = 0.72 },
            driveby = { up = 2.80, side = 1.25 },
        },
        shake    = 0.14,
        fireRate = 850,
    },

    [GetHashKey('WEAPON_COMBATMG_MK2')] = {
        hashStr  = 'WEAPON_COMBATMG_MK2',
        name     = 'Combat MG Mk II',
        class    = 'mg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.78, side = 0.38 },
            tpp     = { up = 1.45, side = 0.70 },
            driveby = { up = 2.70, side = 1.20 },
        },
        shake    = 0.13,
        fireRate = 870,
    },

    [GetHashKey('WEAPON_GUSENBERG')] = {
        hashStr  = 'WEAPON_GUSENBERG',
        name     = 'Gusenberg Sweeper',
        class    = 'mg',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 0.75, side = 0.42 },
            tpp     = { up = 1.40, side = 0.75 },
            driveby = { up = 2.60, side = 1.30 },
        },
        shake    = 0.13,
        fireRate = 700,
    },

    -- ── SNIPERS ───────────────────────────────────────────────────────────────

    [GetHashKey('WEAPON_SNIPERRIFLE')] = {
        hashStr  = 'WEAPON_SNIPERRIFLE',
        name     = 'Sniper Rifle',
        class    = 'sniper',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 2.00, side = 0.12 },
            tpp     = { up = 3.80, side = 0.22 },
            driveby = { up = 6.00, side = 0.50 },
        },
        shake    = 0.22,
        fireRate = 35,
    },

    [GetHashKey('WEAPON_HEAVYSNIPER')] = {
        hashStr  = 'WEAPON_HEAVYSNIPER',
        name     = 'Heavy Sniper',
        class    = 'sniper',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 2.80, side = 0.15 },
            tpp     = { up = 5.20, side = 0.28 },
            driveby = { up = 8.00, side = 0.65 },
        },
        shake    = 0.32,
        fireRate = 25,
    },

    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = {
        hashStr  = 'WEAPON_HEAVYSNIPER_MK2',
        name     = 'Heavy Sniper Mk II',
        class    = 'sniper',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 2.80, side = 0.15 },
            tpp     = { up = 5.20, side = 0.28 },
            driveby = { up = 8.00, side = 0.65 },
        },
        shake    = 0.32,
        fireRate = 25,
    },

    [GetHashKey('WEAPON_MARKSMANRIFLE')] = {
        hashStr  = 'WEAPON_MARKSMANRIFLE',
        name     = 'Marksman Rifle',
        class    = 'sniper',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.30, side = 0.12 },
            tpp     = { up = 2.40, side = 0.22 },
            driveby = { up = 4.00, side = 0.45 },
        },
        shake    = 0.18,
        fireRate = 120,
    },

    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = {
        hashStr  = 'WEAPON_MARKSMANRIFLE_MK2',
        name     = 'Marksman Rifle Mk II',
        class    = 'sniper',
        damage   = 1.0,
        recoil   = {
            fpp     = { up = 1.28, side = 0.12 },
            tpp     = { up = 2.35, side = 0.22 },
            driveby = { up = 3.90, side = 0.44 },
        },
        shake    = 0.17,
        fireRate = 125,
    },
}

--[[
    WEAPON GROUP FALLBACK
    ────────────────────────────────────────────────────────────────────────────
    Used when a weapon hash is not found in config.weapons above.
    The most common case is custom / addon weapons on modded servers.
    Keys are the signed integers returned by GetWeapontypeGroup().
    These group hash values match the popular server's GroupRecoil table.

    To add a custom weapon precisely, copy any entry above, change the key
    to GetHashKey('YOUR_WEAPON_NAME'), and tune values with /tuner.
]]
config.weaponGroups = {
    [416676503]  = { -- GROUP_PISTOL
        name = 'Handgun (group)',
        class = 'pistol',
        damage = 1.0,
        recoil = { fpp = { up = 0.60, side = 0.20 }, tpp = { up = 1.10, side = 0.38 }, driveby = { up = 1.80, side = 0.70 } },
        shake = 0.09,
        fireRate = 400,
    },
    [-957766203] = { -- GROUP_SMG
        name = 'SMG (group)',
        class = 'smg',
        damage = 1.0,
        recoil = { fpp = { up = 0.45, side = 0.24 }, tpp = { up = 0.85, side = 0.44 }, driveby = { up = 1.40, side = 0.78 } },
        shake = 0.08,
        fireRate = 750,
    },
    [860033945]  = { -- GROUP_SHOTGUN
        name = 'Shotgun (group)',
        class = 'shotgun',
        damage = 1.0,
        recoil = { fpp = { up = 1.50, side = 0.50 }, tpp = { up = 2.80, side = 0.90 }, driveby = { up = 4.20, side = 1.50 } },
        shake = 0.26,
        fireRate = 80,
    },
    [970310034]  = { -- GROUP_RIFLE
        name = 'Rifle (group)',
        class = 'rifle',
        damage = 1.0,
        recoil = { fpp = { up = 0.62, side = 0.21 }, tpp = { up = 1.15, side = 0.38 }, driveby = { up = 2.10, side = 0.82 } },
        shake = 0.10,
        fireRate = 620,
    },
    [1159398588] = { -- GROUP_MG
        name = 'MG (group)',
        class = 'mg',
        damage = 1.0,
        recoil = { fpp = { up = 0.74, side = 0.38 }, tpp = { up = 1.38, side = 0.68 }, driveby = { up = 2.60, side = 1.18 } },
        shake = 0.12,
        fireRate = 880,
    },
    [3082541095] = { -- GROUP_SNIPER
        name = 'Sniper (group)',
        class = 'sniper',
        damage = 1.0,
        recoil = { fpp = { up = 2.20, side = 0.14 }, tpp = { up = 4.00, side = 0.26 }, driveby = { up = 6.50, side = 0.58 } },
        shake = 0.24,
        fireRate = 30,
    },
    [2725924767] = { -- GROUP_HEAVY
        name = 'Heavy (group)',
        class = 'mg',
        damage = 1.0,
        recoil = { fpp = { up = 1.00, side = 0.45 }, tpp = { up = 1.85, side = 0.82 }, driveby = { up = 3.20, side = 1.40 } },
        shake = 0.18,
        fireRate = 300,
    },
}

-- Ultimate fallback — only used if the weapon has no group entry either.
config.weaponFallback = {
    hashStr  = 'WEAPON_UNKNOWN',
    name     = 'Unknown Weapon',
    class    = 'unknown',
    damage   = 1.0,
    recoil   = {
        fpp     = { up = 0.65, side = 0.22 },
        tpp     = { up = 1.20, side = 0.40 },
        driveby = { up = 2.10, side = 0.80 },
    },
    shake    = 0.10,
    fireRate = 400,
}

-- Simple lookup used by server-side code (no client natives available there).
function config.getWeapon(hash)
    return config.weapons[hash] or config.weaponFallback
end
