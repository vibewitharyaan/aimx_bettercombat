api.recoilSystem = {}

local state = {
    activePreset = nil,
    currentWeapon = nil,
    inVehicle = false,
    effectiveRecoil = 0,
    effectiveVertical = 0,
    effectiveHorizontal = 0,
    recoilAccumulation = 0,
    lastShotTime = 0,
    isShooting = false,
    shotCount = 0,
}

-- Weapon change listener
lib.onCache('weapon', function(weaponHash, oldWeapon)
    state.currentWeapon = weaponHash

    if weaponHash then
        api.recoilSystem.recalculateRecoil()

        if config.debug.code then
            local weapon = config.getWeapon(weaponHash)
            _debug(('[Recoil] Weapon changed: %s'):format(weapon and weapon.name or 'Unknown'))
        end
    else
        state.effectiveRecoil = 0
        state.recoilAccumulation = 0
        state.isShooting = false
    end
end)

-- Vehicle state listener
lib.onCache('vehicle', function(vehicle, oldVehicle)
    state.inVehicle = vehicle ~= false

    if state.currentWeapon then
        api.recoilSystem.recalculateRecoil()
    end

    if config.debug.code then
        _debug(('[Recoil] Vehicle state: %s'):format(state.inVehicle and 'in vehicle' or 'on foot'))
    end
end)

-- Recalculate effective recoil based on current state
function api.recoilSystem.recalculateRecoil()
    if not state.activePreset or not state.currentWeapon then
        state.effectiveRecoil = 0
        state.effectiveVertical = 0
        state.effectiveHorizontal = 0
        return
    end

    local weapon = config.getWeapon(state.currentWeapon)
    if not weapon then return end

    state.effectiveRecoil = api.presets.calculateRecoil(
        state.currentWeapon,
        state.activePreset,
        state.inVehicle
    )

    local preset = state.activePreset
    local vertMult = preset.recoil.globalMultiplier
    local horzMult = preset.recoil.globalMultiplier

    if state.inVehicle then
        local driveByMult = config.getDriveByMultiplier(state.currentWeapon).recoil
        vertMult = vertMult * driveByMult * preset.recoil.driveByMultiplier
        horzMult = horzMult * driveByMult * preset.recoil.driveByMultiplier
    end

    state.effectiveVertical = weapon.verticalRecoil * vertMult
    state.effectiveHorizontal = weapon.horizontalRecoil * horzMult

    SetWeaponRecoilShakeAmplitude(state.currentWeapon, state.effectiveRecoil)

    if config.debug.code then
        _debug(('[Recoil] Calculated - Base: %.3f, Vert: %.3f, Horz: %.3f'):format(
            state.effectiveRecoil,
            state.effectiveVertical,
            state.effectiveHorizontal
        ))
    end
end

-- Main recoil loop
CreateThread(function()
    while true do
        local ped = cache.ped

        if ped and state.currentWeapon and state.effectiveRecoil > 0 then
            local isShooting = IsPedShooting(ped)

            if isShooting then
                if not state.isShooting then
                    state.isShooting = true
                    state.shotCount = 0
                end

                local currentTime = GetGameTimer()
                local timeSinceShot = currentTime - state.lastShotTime

                if timeSinceShot < state.activePreset.recoil.recoveryDelay then
                    state.recoilAccumulation = math.min(
                        state.recoilAccumulation + state.effectiveRecoil,
                        state.effectiveRecoil * 5.0
                    )
                end

                state.lastShotTime = currentTime
                state.shotCount = state.shotCount + 1

                local accuracyPenalty = state.recoilAccumulation / state.effectiveRecoil
                SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
            else
                if state.isShooting then
                    state.isShooting = false
                end

                local currentTime = GetGameTimer()
                local timeSinceShot = currentTime - state.lastShotTime

                if timeSinceShot > state.activePreset.recoil.recoveryDelay then
                    local decay = state.activePreset.recoil.recoveryRate * timeSinceShot
                    state.recoilAccumulation = math.max(0, state.recoilAccumulation - decay)
                end
            end
        end

        Wait(config.recoilUpdateInterval)
    end
end)

-- Set active preset
function api.recoilSystem.setPreset(presetName)
    local preset = api.presets.get(presetName)

    if not preset then
        _error(('[Recoil] Invalid preset: %s'):format(presetName))
        return
    end

    state.activePreset = preset

    if state.currentWeapon then
        api.recoilSystem.recalculateRecoil()
    end

    if config.debug.code then
        _debug(('[Recoil] Preset activated: %s'):format(presetName))
    end

    lib.notify({
        title = 'Combat Preset',
        description = ('Active: %s'):format(preset.description),
        type = 'info',
        duration = 3000
    })
end

-- Get current preset
function api.recoilSystem.getPreset()
    return state.activePreset
end

-- Server assigns preset to client
RegisterNetEvent('weaponFramework:setPreset', function(presetName)
    api.recoilSystem.setPreset(presetName)
end)

-- Server forces recoil recalculation
RegisterNetEvent('weaponFramework:reloadRecoil', function()
    if state.currentWeapon then
        api.recoilSystem.recalculateRecoil()
    end
end)

-- Recoil visualization debug tool
if config.debug.visualizeRecoil then
    CreateThread(function()
        while true do
            if state.isShooting and state.recoilAccumulation > 0 then
                local accum = state.recoilAccumulation
                local maxAccum = state.effectiveRecoil * 5.0
                local percentage = (accum / maxAccum) * 100

                SetTextFont(4)
                SetTextScale(0.4, 0.4)
                SetTextColour(255, 255, 255, 255)
                SetTextOutline()
                SetTextEntry('STRING')
                AddTextComponentString(('Recoil: %.1f%%'):format(percentage))
                DrawText(0.85, 0.90)
            end

            Wait(0)
        end
    end)
end

-- System initialization
CreateThread(function()
    while not cache.ped do
        Wait(100)
    end

    if config.mode == 'single' then
        TriggerServerEvent('weaponFramework:requestDefaultPreset')
    end

    if config.debug.code then
        _debug('[Recoil] System initialized')
    end
end)

exports('getRecoilState', function()
    return state
end)

exports('getEffectiveRecoil', function()
    return state.effectiveRecoil
end)

exports('setPreset', function(presetName)
    api.recoilSystem.setPreset(presetName)
end)

return api.recoilSystem
