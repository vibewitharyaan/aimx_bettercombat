-- Shared client state. Read directly by cl_recoil and cl_tuner.
combatState = {
    preset         = nil,
    presetName     = nil,
    weaponHash     = nil,
    weaponData     = nil,
    weaponOverride = nil,
    presetOverride = nil,
}

-- Resolves weapon data with group fallback for addon weapons
local function resolveWeapon(hash)
    if not hash or hash == false or hash == 0 then return nil end
    if config.weapons[hash] then return config.weapons[hash] end
    local group = GetWeapontypeGroup(hash)
    if group and config.weaponGroups[group] then return config.weaponGroups[group] end
    return config.weaponFallback
end

-- Applies SetWeaponDamageModifier using active override or config value
local function applyDamageModifier(hash)
    if not hash then return end
    local wd = combatState.weaponOverride or resolveWeapon(hash)
    SetWeaponDamageModifier(hash, wd and wd.damage or 1.0)
    _debug('DamageModifier %s → %.2f', wd and wd.name or tostring(hash), wd and wd.damage or 1.0)
end

-- Fires when the held weapon changes — single registration, cl_recoil watches combatState
lib.onCache('weapon', function(hash)
    local h                    = (hash and hash ~= false and hash ~= 0) and hash or nil
    combatState.weaponHash     = h
    combatState.weaponData     = resolveWeapon(h)
    combatState.weaponOverride = nil
    if h then
        applyDamageModifier(h)
        recoil.start()
    else
        recoil.stop()
    end
end)

-- Applies a preset pushed from the server
RegisterNetEvent(resName .. ':applyPreset', function(name)
    local preset = config.presets[name]
    if not preset then return _warn('applyPreset: unknown preset "%s"', name) end
    combatState.preset         = preset
    combatState.presetName     = name
    combatState.presetOverride = nil
    if combatState.weaponHash then applyDamageModifier(combatState.weaponHash) end
    _debug('Preset → %s', name)
end)

-- Requests the assigned preset from the server on first spawn via lib.callback
CreateThread(function()
    while not cache.ped do Wait(100) end
    lib.callback(resName .. ':getPreset', false, function(name)
        local preset = config.presets[name]
        if not preset then return _warn('getPreset: unknown preset "%s"', name) end
        combatState.preset     = preset
        combatState.presetName = name
        _debug('Preset received → %s', name)
    end)
end)

-- Called by cl_tuner after a live damage value change
exports('reapplyDamageModifier', function()
    if combatState.weaponHash then applyDamageModifier(combatState.weaponHash) end
end)