-- Live recoil and damage tuner. Opened via /tuner (server validates ACE first).
local MENU_ID = 'better_combat_tuner'

-- Shallow-clones weapon data so config tables are never mutated
local function cloneWeapon(wd)
    return {
        hashStr  = wd.hashStr,
        name     = wd.name,
        class    = wd.class,
        damage   = wd.damage,
        recoil   = {
            fpp     = { up = wd.recoil.fpp.up, side = wd.recoil.fpp.side },
            tpp     = { up = wd.recoil.tpp.up, side = wd.recoil.tpp.side },
            driveby = { up = wd.recoil.driveby.up, side = wd.recoil.driveby.side },
        },
        shake    = wd.shake,
        fireRate = wd.fireRate,
    }
end

-- Shallow-clones preset data so config tables are never mutated
local function clonePreset(p)
    return {
        label           = p.label,
        recoilMult      = p.recoilMult,
        recoveryRate    = p.recoveryRate,
        recoveryDelay   = p.recoveryDelay,
        maxAccumulation = p.maxAccumulation,
    }
end

-- Creates override tables on first edit if they don't exist yet
local function ensureOverrides()
    if combatState.weaponData and not combatState.weaponOverride then
        combatState.weaponOverride = cloneWeapon(combatState.weaponData)
    end
    if combatState.preset and not combatState.presetOverride then
        combatState.presetOverride = clonePreset(combatState.preset)
    end
end

-- Writes a single tuned field into the override tables
local function writeField(field, value)
    ensureOverrides()
    local wo = combatState.weaponOverride
    local po = combatState.presetOverride
    if field == 'fpp.up' and wo then
        wo.recoil.fpp.up = value
    elseif field == 'fpp.side' and wo then
        wo.recoil.fpp.side = value
    elseif field == 'tpp.up' and wo then
        wo.recoil.tpp.up = value
    elseif field == 'tpp.side' and wo then
        wo.recoil.tpp.side = value
    elseif field == 'driveby.up' and wo then
        wo.recoil.driveby.up = value
    elseif field == 'driveby.side' and wo then
        wo.recoil.driveby.side = value
    elseif field == 'shake' and wo then
        wo.shake = value
    elseif field == 'fireRate' and wo then
        wo.fireRate = value
    elseif field == 'damage' and wo then
        wo.damage = value
        if combatState.weaponHash then SetWeaponDamageModifier(combatState.weaponHash, value) end
    elseif field == 'p.recoilMult' and po then
        po.recoilMult = value
    elseif field == 'p.recoveryRate' and po then
        po.recoveryRate = value
    elseif field == 'p.recoveryDelay' and po then
        po.recoveryDelay = value
    elseif field == 'p.maxAccumulation' and po then
        po.maxAccumulation = value
    end
end

-- Prints current override values as paste-ready Lua to the F8 console
local function exportSnippet()
    local wd = combatState.weaponOverride or combatState.weaponData
    local pv = combatState.presetOverride or combatState.preset
    if not wd then return end
    local r     = wd.recoil
    local lines = {
        '',
        '-- Weapon (config/weapons.lua)',
        ("[GetHashKey('%s')] = {"):format(wd.hashStr or 'WEAPON_UNKNOWN'),
        ("    hashStr  = '%s',"):format(wd.hashStr or 'WEAPON_UNKNOWN'),
        ("    name     = '%s',"):format(wd.name),
        ("    class    = '%s',"):format(wd.class),
        ("    damage   = %.2f,"):format(wd.damage),
        '    recoil   = {',
        ("        fpp     = { up = %.2f, side = %.2f },"):format(r.fpp.up, r.fpp.side),
        ("        tpp     = { up = %.2f, side = %.2f },"):format(r.tpp.up, r.tpp.side),
        ("        driveby = { up = %.2f, side = %.2f },"):format(r.driveby.up, r.driveby.side),
        '    },',
        ("    shake    = %.2f,"):format(wd.shake),
        ("    fireRate = %d,"):format(wd.fireRate),
        '},',
    }
    if pv then
        lines[#lines + 1] = ''
        lines[#lines + 1] = '-- Preset (config/presets.lua)'
        lines[#lines + 1] = ("    recoilMult      = %.2f,"):format(pv.recoilMult)
        lines[#lines + 1] = ("    recoveryRate    = %.1f,"):format(pv.recoveryRate)
        lines[#lines + 1] = ("    recoveryDelay   = %d,"):format(pv.recoveryDelay)
        lines[#lines + 1] = ("    maxAccumulation = %.1f,"):format(pv.maxAccumulation)
        lines[#lines + 1] = ''
    end
    print(table.concat(lines, '\n'))
    lib.notify({ title = 'Tuner', description = 'Snippet printed to F8', type = 'success', duration = 3000 })
end

-- Builds the option list for the current weapon and preset state
local function buildOptions()
    local wd = combatState.weaponOverride or combatState.weaponData
    local pv = combatState.presetOverride or combatState.preset

    if not combatState.weaponHash or not wd then
        return { { label = '^8No weapon equipped^7', description = 'Equip a weapon then run /tuner again.', disabled = true } }
    end

    local r = wd.recoil
    local function row(label, field, val, min, max, fmt)
        fmt = fmt or '%.2f'
        return {
            label       = (label .. '  ^5' .. fmt .. '^7'):format(val),
            description = ('min %s  →  max %s'):format(tostring(min), tostring(max)),
            args        = { field = field, current = val, minV = min, maxV = max, label = label },
        }
    end

    local opts = {
        { label = ('^3%s^7   preset: ^5%s^7'):format(wd.name, pv and pv.label or '—'), disabled = true },
        { label = '^4── Recoil ──────────────────────────────────^7', disabled = true },
    }

    opts[#opts + 1] = row('FPP    Vertical', 'fpp.up', r.fpp.up, 0.0, 10.0)
    opts[#opts + 1] = row('FPP    Horizontal', 'fpp.side', r.fpp.side, 0.0, 5.0)
    opts[#opts + 1] = row('TPP    Vertical', 'tpp.up', r.tpp.up, 0.0, 10.0)
    opts[#opts + 1] = row('TPP    Horizontal', 'tpp.side', r.tpp.side, 0.0, 5.0)
    opts[#opts + 1] = row('Driveby Vertical', 'driveby.up', r.driveby.up, 0.0, 15.0)
    opts[#opts + 1] = row('Driveby Horizontal', 'driveby.side', r.driveby.side, 0.0, 6.0)
    opts[#opts + 1] = row('Camera Shake', 'shake', wd.shake, 0.0, 1.0)
    opts[#opts + 1] = row('Fire Rate (RPM)', 'fireRate', wd.fireRate, 10, 2000, '%d')

    opts[#opts + 1] = { label = '^4── Damage ──────────────────────────────────^7', disabled = true }
    opts[#opts + 1] = row('Damage Modifier', 'damage', wd.damage, 0.05, 5.0)

    opts[#opts + 1] = { label = '^4── Active Preset ───────────────────────────^7', disabled = true }

    if pv then
        opts[#opts + 1] = row('Recoil Scale', 'p.recoilMult', pv.recoilMult, 0.0, 5.0)
        opts[#opts + 1] = row('Recovery Rate  °/s', 'p.recoveryRate', pv.recoveryRate, 1.0, 300.0, '%.1f')
        opts[#opts + 1] = row('Recovery Delay  ms', 'p.recoveryDelay', pv.recoveryDelay, 0, 2000, '%d')
        opts[#opts + 1] = row('Max Accum  °', 'p.maxAccumulation', pv.maxAccumulation, 0.0, 60.0, '%.1f')
    else
        opts[#opts + 1] = { label = '^8No preset active^7', disabled = true }
    end

    opts[#opts + 1] = { label = '^4── Actions ─────────────────────────────────^7', disabled = true }
    opts[#opts + 1] = { label = 'Reset to config values', args = { action = 'reset' } }
    opts[#opts + 1] = { label = 'Export snippet to F8', args = { action = 'export' } }

    return opts
end

-- Registers and opens the tuner menu, re-registering refreshes the values
local function openTuner()
    lib.registerMenu({
        id       = MENU_ID,
        title    = 'Weapon Tuner',
        position = 'top-right',
        options  = buildOptions(),
    }, function(_, _, args)
        if not args then return end

        if args.action == 'reset' then
            combatState.weaponOverride = nil
            combatState.presetOverride = nil
            if combatState.weaponHash and combatState.weaponData then
                SetWeaponDamageModifier(combatState.weaponHash, combatState.weaponData.damage)
            end
            lib.notify({ title = 'Tuner', description = 'Overrides cleared', type = 'inform', duration = 2500 })
            openTuner()
            return
        end

        if args.action == 'export' then
            exportSnippet()
            lib.showMenu(MENU_ID)
            return
        end

        if not args.field then return end

        local result = lib.inputDialog('Edit: ' .. args.label, {
            {
                type = 'number',
                label = ('Current: %s  |  min %s  max %s'):format(
                    tostring(args.current), tostring(args.minV), tostring(args.maxV)),
                default = args.current,
                min = args.minV,
                max = args.maxV
            },
        })

        if result and result[1] ~= nil then
            local v = tonumber(result[1])
            if v then writeField(args.field, v) end
        end

        openTuner()
    end)

    lib.showMenu(MENU_ID)
end

-- Toggles tuner open/closed. Server fires this after ACE is validated.
RegisterNetEvent(resName .. ':openTuner', function()
    if lib.getOpenMenu() == MENU_ID then
        lib.hideMenu()
        return
    end
    openTuner()
end)
