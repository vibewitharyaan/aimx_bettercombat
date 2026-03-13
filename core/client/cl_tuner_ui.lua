local tunerUi = {}
local isOpen = false
local testingRecoil = false

-- Open tuner UI
function tunerUi.open()
    if isOpen then return end

    ui.focus(true, true)
    ui.sendMsg('open')

    isOpen = true

    if config.debug.enabled then
        _debug('[Tuner UI] Opened')
    end
end

-- Close tuner UI
function tunerUi.close()
    if not isOpen then return end

    ui.focus(false, false)
    ui.sendMsg('close')

    isOpen = false
    testingRecoil = false

    if config.debug.enabled then
        _debug('[Tuner UI] Closed')
    end
end

-- Get all weapons from config
ui.registerCb('getWeapons', function(data)
    local weaponList = {}

    for hash, weapon in pairs(config.weapons) do
        weaponList[tostring(hash)] = weapon
    end

    return { weapons = weaponList }
end)

-- Test recoil values in real-time
ui.registerCb('testRecoil', function(data)
    testingRecoil = true

    local ped = cache.ped
    local weapon = cache.weapon

    if not weapon then
        return { success = false, message = 'No weapon equipped' }
    end

    -- Apply test recoil values
    SetWeaponRecoilShakeAmplitude(weapon, data.baseRecoil or 0.15)

    if config.debug.enabled then
        _debug(('[Tuner] Testing recoil: %.3f'):format(data.baseRecoil or 0.15))
    end

    ui.sendMsg('testRecoilFeedback')

    return { success = true }
end)

-- Save weapon configuration to server
ui.registerCb('saveWeapon', function(data)
    if not data.config then
        return { success = false, message = 'Invalid configuration' }
    end

    TriggerServerEvent('weaponFramework:tuner:saveWeapon', data.config, data.preset)
    return { success = true }
end)

-- Close tuner via UI
ui.registerCb('close', function(data)
    tunerUi.close()
    return { success = true }
end)

-- Server opens tuner for player
RegisterNetEvent('weaponFramework:openTuner', function()
    tunerUi.open()
end)

-- Server sends updated weapon list
RegisterNetEvent('weaponFramework:tuner:updateWeapons', function(weapons)
    ui.sendMsg('loadWeapons', { weapons = weapons })
end)

if config.debug.enabled then
    RegisterCommand('tuneropen', function()
        tunerUi.open()
    end, false)
end

exports('openTuner', tunerUi.open)
exports('closeTuner', tunerUi.close)

return tunerUi
