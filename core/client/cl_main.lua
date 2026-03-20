--[[
    cl_main.lua — shared client state, weapon cache, damage modifier.
    Loaded first. CombatState is read directly by cl_recoil and cl_tuner
    since all client scripts share the same Lua environment in FiveM.

    DAMAGE
    ────────────────────────────────────────────────────────────────────────────
    SetWeaponDamageModifier(hash, value) is called once when the player equips
    a weapon and again whenever the active preset changes. This is the standard
    approach used by QBCore, ESX, and every major production framework.
    GTA's engine applies the multiplier to every outgoing bullet automatically.
    GTA's own headshot advantage remains in effect at all times.
]]

CombatState = {
    preset         = nil, -- active preset table (from config.presets)
    presetName     = nil, -- active preset key string
    weaponHash     = nil, -- current weapon hash (number) or nil when unarmed
    weaponData     = nil, -- resolved weapon data table for current weapon
    weaponOverride = nil, -- tuner live weapon overrides (nil when not active)
    presetOverride = nil, -- tuner live preset overrides (nil when not active)
}

-- ── Weapon data resolution ────────────────────────────────────────────────────
-- Client-side only — can use GetWeapontypeGroup() for addon weapon fallback.

local function resolveWeapon(hash)
    if not hash or hash == false or hash == 0 then return nil end
    if config.weapons[hash] then return config.weapons[hash] end
    local group = GetWeapontypeGroup(hash)
    if group and config.weaponGroups[group] then
        return config.weaponGroups[group]
    end
    return config.weaponFallback
end

-- ── Damage modifier ───────────────────────────────────────────────────────────

local function applyDamageModifier(hash)
    if not hash then return end
    local wd   = CombatState.weaponOverride or resolveWeapon(hash)
    local mult = wd and wd.damage or 1.0
    SetWeaponDamageModifier(hash, mult)

    local name = wd and wd.name or tostring(hash)
    _debug('[Combat] DamageModifier  %s → %.2f', name, mult)
end

-- ── Weapon cache ──────────────────────────────────────────────────────────────
-- lib.onCache('weapon') fires when the held weapon hash changes.
-- Registered exactly once here. cl_recoil detects changes via local comparison.

lib.onCache('weapon', function(hash)
    local h                    = (hash and hash ~= false and hash ~= 0) and hash or nil
    CombatState.weaponHash     = h
    CombatState.weaponData     = resolveWeapon(h)
    CombatState.weaponOverride = nil
    if h then applyDamageModifier(h) end
end)

-- ── Preset event ──────────────────────────────────────────────────────────────

RegisterNetEvent(resName .. ':applyPreset', function(name)
    local preset = config.presets[name]
    if not preset then
        print(('[Combat] applyPreset: unknown preset "%s"'):format(tostring(name)))
        return
    end
    CombatState.preset         = preset
    CombatState.presetName     = name
    CombatState.presetOverride = nil
    if CombatState.weaponHash then applyDamageModifier(CombatState.weaponHash) end
    _debug('[Combat] Preset → %s (%s)', name, preset.label) 
end)

-- ── Request preset on spawn ───────────────────────────────────────────────────

CreateThread(function()
    while not cache.ped do Wait(100) end
    TriggerServerEvent(resName .. ':requestPreset')
end)

-- ── Export used by cl_tuner ───────────────────────────────────────────────────

exports('reapplyDamageModifier', function()
    if CombatState.weaponHash then applyDamageModifier(CombatState.weaponHash) end
end)
