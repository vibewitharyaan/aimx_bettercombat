--[[
    PRESETS  —  recoil multipliers only.
    ────────────────────────────────────────────────────────────────────────────
    Damage is deliberately per-weapon in weapons.lua and is NOT part of a preset.
    Damage values stay consistent. Only recoil feel changes between presets.

    ── recoilMult ───────────────────────────────────────────────────────────────
    Multiplier applied to every weapon's base up/side values at runtime.
        0.0 = no recoil
        1.0 = weapon config values as-is
        2.0 = doubled

    ── recoveryRate ─────────────────────────────────────────────────────────────
    Degrees per second the camera returns toward the aim point after firing.
    Higher = faster snap back.

    ── recoveryDelay ────────────────────────────────────────────────────────────
    Milliseconds after the last shot before recovery begins.
    Gives automatic weapons a brief "hold" before they settle.

    ── maxAccumulation ──────────────────────────────────────────────────────────
    Maximum total upward pitch that can build up during sustained fire.
    Once reached, further shots only add horizontal drift and camera shake.
    0.0 = no cap (only use with very low recoilMult).

    ── SWITCHING PRESETS AT RUNTIME ─────────────────────────────────────────────
    Server-side — all players (single mode):
        exports['better_combat']:setGlobalPreset('pvp_competitive')

    Server-side — one player (multi mode):
        exports['better_combat']:setPlayerPreset(source, 'pvp_competitive')

    Admin command:
        /setglobalpreset pvp_competitive
        /setpreset <playerServerId> pvp_competitive
]]

config.presets = {

    -- Default — good balanced starting point for any server.
    default = {
        label           = 'Default',
        recoilMult      = 1.0,
        recoveryRate    = 55.0,
        recoveryDelay   = 180,
        maxAccumulation = 14.0,
    },

    -- ── RP presets ────────────────────────────────────────────────────────────

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

    -- ── PvP presets ───────────────────────────────────────────────────────────

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
