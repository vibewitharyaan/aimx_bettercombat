-- ============================================================================
-- WEAPON FRAMEWORK - CLIENT RECOIL SYSTEM
-- ============================================================================
-- Cache-driven, event-based recoil application
-- Performance-optimized using ox_lib cache
-- ============================================================================

local RecoilSystem = {}

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local state = {
    activePreset = nil,          -- Current preset assigned by server
    currentWeapon = nil,         -- Cached weapon hash
    inVehicle = false,           -- Cached vehicle state
    effectiveRecoil = 0,         -- Current calculated recoil values
    effectiveVertical = 0,
    effectiveHorizontal = 0,
    
    -- Runtime recoil accumulation
    recoilAccumulation = 0,
    lastShotTime = 0,
    isShooting = false,
    shotCount = 0,
}

-- ============================================================================
-- CACHE LISTENERS (PERFORMANCE CRITICAL)
-- ============================================================================
-- React to state changes instead of polling every frame
-- ============================================================================

---Weapon change listener
lib.onCache('weapon', function(weaponHash, oldWeapon)
    state.currentWeapon = weaponHash
    
    if weaponHash then
        RecoilSystem.RecalculateRecoil()
        
        if Config.Debug.enabled then
            local weapon = Config.GetWeapon(weaponHash)
            print(('[Recoil] Weapon changed: %s'):format(weapon and weapon.name or 'Unknown'))
        end
    else
        -- Weapon holstered
        state.effectiveRecoil = 0
        state.recoilAccumulation = 0
        state.isShooting = false
    end
end)

---Vehicle state listener
lib.onCache('vehicle', function(vehicle, oldVehicle)
    state.inVehicle = vehicle ~= false
    
    -- Recalculate recoil with drive-by multipliers
    if state.currentWeapon then
        RecoilSystem.RecalculateRecoil()
    end
    
    if Config.Debug.enabled then
        print(('[Recoil] Vehicle state: %s'):format(state.inVehicle and 'in vehicle' or 'on foot'))
    end
end)

-- ============================================================================
-- RECOIL CALCULATION
-- ============================================================================

---Recalculate effective recoil based on current state
---Called ONLY when weapon/vehicle/preset changes (not per-frame)
function RecoilSystem.RecalculateRecoil()
    if not state.activePreset or not state.currentWeapon then
        state.effectiveRecoil = 0
        state.effectiveVertical = 0
        state.effectiveHorizontal = 0
        return
    end
    
    local weapon = Config.GetWeapon(state.currentWeapon)
    if not weapon then return end
    
    -- Calculate base recoil with preset
    state.effectiveRecoil = Presets.CalculateRecoil(
        state.currentWeapon,
        state.activePreset,
        state.inVehicle
    )
    
    -- Calculate component recoils
    local preset = state.activePreset
    local vertMult = preset.recoil.globalMultiplier
    local horzMult = preset.recoil.globalMultiplier
    
    if state.inVehicle then
        local driveByMult = Config.GetDriveByMultiplier(state.currentWeapon).recoil
        vertMult = vertMult * driveByMult * preset.recoil.driveByMultiplier
        horzMult = horzMult * driveByMult * preset.recoil.driveByMultiplier
    end
    
    state.effectiveVertical = weapon.verticalRecoil * vertMult
    state.effectiveHorizontal = weapon.horizontalRecoil * horzMult
    
    -- Apply recoil shake to weapon
    SetWeaponRecoilShakeAmplitude(state.currentWeapon, state.effectiveRecoil)
    
    if Config.Debug.enabled then
        print(('[Recoil] Calculated - Base: %.3f, Vert: %.3f, Horz: %.3f'):format(
            state.effectiveRecoil,
            state.effectiveVertical,
            state.effectiveHorizontal
        ))
    end
end

-- ============================================================================
-- RECOIL ACCUMULATION & RECOVERY
-- ============================================================================

---Main recoil loop (runs only while shooting)
CreateThread(function()
    while true do
        local ped = cache.ped
        
        if ped and state.currentWeapon and state.effectiveRecoil > 0 then
            local isShooting = IsPedShooting(ped)
            
            if isShooting then
                if not state.isShooting then
                    -- First shot
                    state.isShooting = true
                    state.shotCount = 0
                end
                
                local currentTime = GetGameTimer()
                local timeSinceShot = currentTime - state.lastShotTime
                
                -- Accumulate recoil on continuous fire
                if timeSinceShot < state.activePreset.recoil.recoveryDelay then
                    state.recoilAccumulation = math.min(
                        state.recoilAccumulation + state.effectiveRecoil,
                        state.effectiveRecoil * 5.0  -- Cap at 5x base recoil
                    )
                end
                
                state.lastShotTime = currentTime
                state.shotCount = state.shotCount + 1
                
                -- Apply accumulated recoil via accuracy modifier
                local accuracyPenalty = state.recoilAccumulation / state.effectiveRecoil
                SetPlayerWeaponDamageModifier(PlayerId(), 1.0)  -- Reset damage
                
                -- Reduce accuracy based on recoil accumulation
                -- Note: We can't directly set accuracy, but we can simulate through spread
                -- This is a visual/feel mechanism; server validates actual damage
                
            else
                -- Recoil recovery
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
        
        Wait(Config.RecoilUpdateInterval)
    end
end)

-- ============================================================================
-- PRESET MANAGEMENT
-- ============================================================================

---Set active preset (called by server)
---@param presetName string
function RecoilSystem.SetPreset(presetName)
    local preset = Presets.Get(presetName)
    
    if not preset then
        error(('[Recoil] Invalid preset: %s'):format(presetName))
    end
    
    state.activePreset = preset
    
    -- Recalculate all recoil values
    if state.currentWeapon then
        RecoilSystem.RecalculateRecoil()
    end
    
    if Config.Debug.enabled then
        print(('[Recoil] Preset activated: %s'):format(presetName))
    end
    
    -- Visual notification (optional)
    lib.notify({
        title = 'Combat Preset',
        description = ('Active: %s'):format(preset.description),
        type = 'info',
        duration = 3000
    })
end

---Get current preset
---@return table|nil
function RecoilSystem.GetPreset()
    return state.activePreset
end

-- ============================================================================
-- SERVER EVENTS
-- ============================================================================

---Server assigns preset to client
RegisterNetEvent('weaponFramework:setPreset', function(presetName)
    RecoilSystem.SetPreset(presetName)
end)

---Server forces recoil recalculation (e.g., after tuner changes)
RegisterNetEvent('weaponFramework:reloadRecoil', function()
    if state.currentWeapon then
        RecoilSystem.RecalculateRecoil()
    end
end)

-- ============================================================================
-- DEBUG VISUALIZATION
-- ============================================================================

if Config.Debug.visualizeRecoil then
    CreateThread(function()
        while true do
            if state.isShooting and state.recoilAccumulation > 0 then
                local accum = state.recoilAccumulation
                local maxAccum = state.effectiveRecoil * 5.0
                local percentage = (accum / maxAccum) * 100
                
                -- Draw recoil meter
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

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    -- Wait for ox_lib cache to initialize
    while not cache.ped do
        Wait(100)
    end
    
    -- Request default preset from server
    if Config.Mode == 'single' then
        TriggerServerEvent('weaponFramework:requestDefaultPreset')
    end
    
    if Config.Debug.enabled then
        print('[Recoil] System initialized')
    end
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('getRecoilState', function()
    return state
end)

exports('getEffectiveRecoil', function()
    return state.effectiveRecoil
end)

exports('setPreset', function(presetName)
    RecoilSystem.SetPreset(presetName)
end)

return RecoilSystem
