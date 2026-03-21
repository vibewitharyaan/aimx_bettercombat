config.presets = {

    default = {
        label           = 'Default',
        recoilMult      = 1.0,
        recoveryRate    = 55.0,
        recoveryDelay   = 180,
        maxAccumulation = 14.0,
    },

    -- RP

    rp_mild = {
        label           = 'RP — Mild',
        recoilMult      = 0.60,
        recoveryRate    = 80.0,
        recoveryDelay   = 110,
        maxAccumulation = 9.0,
    },

    rp_standard = {
        label           = 'RP — Standard',
        recoilMult      = 0.85,
        recoveryRate    = 60.0,
        recoveryDelay   = 160,
        maxAccumulation = 12.0,
    },

    rp_realistic = {
        label           = 'RP — Realistic',
        recoilMult      = 1.30,
        recoveryRate    = 38.0,
        recoveryDelay   = 280,
        maxAccumulation = 18.0,
    },

    -- PvP

    pvp_competitive = {
        label           = 'PvP — Competitive',
        recoilMult      = 0.75,
        recoveryRate    = 85.0,
        recoveryDelay   = 90,
        maxAccumulation = 9.0,
    },

    pvp_standard = {
        label           = 'PvP — Standard',
        recoilMult      = 1.0,
        recoveryRate    = 55.0,
        recoveryDelay   = 150,
        maxAccumulation = 13.0,
    },

    pvp_hardcore = {
        label           = 'PvP — Hardcore',
        recoilMult      = 1.80,
        recoveryRate    = 28.0,
        recoveryDelay   = 380,
        maxAccumulation = 24.0,
    },

    pvp_no_recoil = {
        label           = 'PvP — No Recoil',
        recoilMult      = 0.0,
        recoveryRate    = 999.0,
        recoveryDelay   = 0,
        maxAccumulation = 0.0,
    },
}
