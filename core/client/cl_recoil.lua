recoil = {}

local KICK_SPEED  = 8.0  -- degrees per second the queued kick drains into camera rotation

local active      = false
local pendingKick = 0.0
local pitchAccum  = 0.0
local lastShotAt  = 0

-- Returns current view mode based on vehicle and camera state
local function viewMode()
    if cache.vehicle and cache.vehicle ~= false then return 'driveby' end
    if GetFollowPedCamViewMode() == 4 then return 'fpp' end
    return 'tpp'
end

-- Calculates and applies one shot's camera kick, drift, and shake
local function applyShot(wd, preset)
    local mode     = viewMode()
    local r        = wd.recoil[mode]
    local mult     = preset.recoilMult
    local speed    = GetEntitySpeed(cache.ped)
    local speedMod = math.min(1.25, 1.0 + speed * 0.02)
    local shotRand = math.random(50, math.min(95, 75 + math.floor(speed * 1.5))) / 100.0
    local upAmt    = r.up   * mult * speedMod * shotRand
    local side     = r.side * mult * speedMod * shotRand
    local cap      = preset.maxAccumulation

    if cap > 0 then
        local total = pitchAccum + pendingKick
        upAmt = total >= cap and 0.0 or math.min(upAmt, cap - total)
    end

    pendingKick = pendingKick + upAmt

    -- Horizontal drift fires on ~20% of shots — mirrors the popular server pattern
    if side > 0.001 and math.random(10) <= 2 then
        SetGameplayCamRelativeHeading(
            math.max(-179.0, math.min(179.0, GetGameplayCamRelativeHeading() + (math.random() * 2.0 - 1.0) * side)))
    end

    local shakeAmt = (wd.shake or 0.0) * math.max(0.2, mult)
    if shakeAmt > 0.001 then ShakeGameplayCam('HAND_SHAKE', shakeAmt) end

    _debug('Shot %s | %s | up=%.2f spd=%.1f rnd=%.2f accum=%.2f',
        wd.name, mode, upAmt, speed, shotRand, pitchAccum + pendingKick)
end

-- Starts the recoil loop. No-op if already running.
function recoil.start()
    if active then return end
    active      = true
    pendingKick = 0.0
    pitchAccum  = 0.0
    lastShotAt  = 0

    CreateThread(function()
        while active do
            local wd     = combatState.weaponOverride or combatState.weaponData
            local preset = combatState.presetOverride or combatState.preset

            if not wd or not preset then
                Wait(100)
            elseif pendingKick > 0.001 then
                -- Drain queued kick smoothly into camera rotation
                local dt   = GetFrameTime()
                local step = math.min(KICK_SPEED * dt, pendingKick)
                SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() - step, 1.0)
                pitchAccum  = pitchAccum + step
                pendingKick = pendingKick - step
                Wait(0)
            elseif IsPedShooting(cache.ped) then
                -- Gate kicks to one per bullet interval based on fire rate
                local now      = GetGameTimer()
                local interval = math.max(50, math.floor(60000 / (wd.fireRate or 400)))
                if now - lastShotAt >= interval then
                    applyShot(wd, preset)
                    lastShotAt = now
                end
                Wait(0)
            elseif pitchAccum > 0.001 then
                -- Recover camera smoothly after firing stops
                local now = GetGameTimer()
                if (now - lastShotAt) >= (preset.recoveryDelay or 0) then
                    local dt    = GetFrameTime()
                    local decay = math.min((preset.recoveryRate or 55.0) * dt, pitchAccum)
                    SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() + decay, 1.0)
                    pitchAccum  = pitchAccum - decay
                    if pitchAccum < 0.001 then pitchAccum = 0.0 end
                end
                Wait(0)
            else
                -- Weapon held but idle — check infrequently
                Wait(50)
            end
        end
    end)
end

-- Stops the recoil loop and resets state
function recoil.stop()
    active      = false
    pendingKick = 0.0
    pitchAccum  = 0.0
end

-- Debug overlay — permanent only in debug mode, never runs in production
if config.debug.code then
    CreateThread(function()
        while true do
            Wait(0)
            local p = combatState.presetOverride or combatState.preset
            if p and p.maxAccumulation > 0 and (pitchAccum + pendingKick) > 0.001 then
                local total = pitchAccum + pendingKick
                SetTextFont(4)
                SetTextScale(0.28, 0.28)
                SetTextColour(255, 200, 50, 210)
                SetTextOutline()
                SetTextEntry('STRING')
                AddTextComponentString(('Recoil %.0f%%  (%.2f° / %.1f°)'):format(
                    math.min(100, total / p.maxAccumulation * 100), total, p.maxAccumulation))
                DrawText(0.01, 0.95)
            end
        end
    end)
end

exports('getRecoilAccum', function()
    return pitchAccum + pendingKick
end)