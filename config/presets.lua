config.presets = {
    realistic = {
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
    },

    competitive = {
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
    },

    hardcore = {
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
    },

    arcade = {
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
    },
}
