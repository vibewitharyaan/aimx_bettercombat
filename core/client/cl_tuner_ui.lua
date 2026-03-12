-- ============================================================================
-- WEAPON TUNER - CLIENT UI CONTROLLER
-- ============================================================================
-- Handles NUI communication and in-game weapon testing
-- ============================================================================

local TunerUI = {}
local isOpen = false
local testingRecoil = false

-- ============================================================================
-- TUNER OPEN/CLOSE
-- ============================================================================

---Open tuner UI
function TunerUI.Open()
    if isOpen then return end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open'
    })
    
    isOpen = true
    
    if config.debug.enabled then
        _debug('[Tuner UI] Opened')
    end
end

---Close tuner UI
function TunerUI.Close()
    if not isOpen then return end
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
    
    isOpen = false
    testingRecoil = false
    
    if config.debug.enabled then
        _debug('[Tuner UI] Closed')
    end
end

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================

---Get all weapons from config
RegisterNUICallback('getWeapons', function(data, cb)
    local weaponList = {}
    
    for hash, weapon in pairs(config.weapons) do
        weaponList[tostring(hash)] = weapon
    end
    
    cb({ weapons = weaponList })
end)

---Test recoil values in real-time
RegisterNUICallback('testRecoil', function(data, cb)
    testingRecoil = true
    
    local ped = cache.ped
    local weapon = cache.weapon
    
    if not weapon then
        cb({ success = false, message = 'No weapon equipped' })
        return
    end
    
    -- Apply test recoil values
    SetWeaponRecoilShakeAmplitude(weapon, data.baseRecoil or 0.15)
    
    if config.debug.enabled then
        _debug(('[Tuner] Testing recoil: %.3f'):format(data.baseRecoil or 0.15))
    end
    
    -- Send confirmation back to UI
    SendNUIMessage({
        action = 'testRecoilFeedback'
    })
    
    cb({ success = true })
end)

---Save weapon configuration to server
RegisterNUICallback('saveWeapon', function(data, cb)
    if not data.config then
        cb({ success = false, message = 'Invalid configuration' })
        return
    end
    
    -- Send to server for permanent saving
    TriggerServerEvent('weaponFramework:tuner:saveWeapon', data.config, data.preset)
    
    cb({ success = true })
end)

---Close tuner
RegisterNUICallback('close', function(data, cb)
    TunerUI.Close()
    cb({ success = true })
end)

-- ============================================================================
-- SERVER EVENTS
-- ============================================================================

---Server opens tuner for player
RegisterNetEvent('weaponFramework:openTuner', function()
    TunerUI.Open()
end)

---Server sends updated weapon list
RegisterNetEvent('weaponFramework:tuner:updateWeapons', function(weapons)
    SendNUIMessage({
        action = 'loadWeapons',
        weapons = weapons
    })
end)

-- ============================================================================
-- KEYBIND (Optional - for quick access during development)
-- ============================================================================

if config.debug.enabled then
    RegisterCommand('tuneropen', function()
        TunerUI.Open()
    end, false)
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

exports('openTuner', TunerUI.Open)
exports('closeTuner', TunerUI.Close)

return TunerUI
