--[[
    cl_recoil.lua — per-shot camera kick and recovery.

    ── HOW RECOIL WORKS IN FIVEM LUA ────────────────────────────────────────────
    SetGameplayCamRelativePitch(degrees, 1.0)
        Pitch relative to the ped's horizontal plane.
        Subtracting = camera tilts upward.
    SetGameplayCamRelativeHeading(degrees)
        Heading relative to ped's facing. Left = negative, right = positive.

    ── SMOOTH KICK ───────────────────────────────────────────────────────────────
    Each shot's kick is queued into pendingKick and drained at KICK_SPEED
    deg/sec per frame. This produces the gradual punchy feel of the popular
    server's repeat-loop approach without blocking the thread.

    ── PER-SHOT RANDOM VARIANCE ──────────────────────────────────────────────────
    Each bullet kicks between 50% and 95% of the base value, biased upward
    when moving. Mirrors the popular server's random(50, 75+speed)/100 formula.
    This single change is what makes recoil feel organic instead of mechanical.

    ── RARE HORIZONTAL DRIFT ────────────────────────────────────────────────────
    Drift fires on ~20% of shots (roll 1 or 3 out of 10).
    Mirrors the popular server's approach exactly. Most shots go straight up;
    occasional side-pulls reward trigger discipline over spray-and-pray.

    ── MOVEMENT SPEED VARIANCE ──────────────────────────────────────────────────
    GetEntitySpeed() adds up to +25% kick at a full sprint.

    ── WEAPON SWITCH DETECTION ──────────────────────────────────────────────────
    CombatState.weaponHash is compared against a local copy each frame.
    This avoids a second lib.onCache('weapon') registration which would
    silently conflict with the one in cl_main.lua.

    ── FIRE RATE THROTTLE ────────────────────────────────────────────────────────
    One kick per bullet interval (60000 / RPM ms), minimum 50ms.
    Prevents one kick per frame on fully-automatic weapons.
]]

-- Speed at which the queued kick drains into actual camera rotation (deg/sec).
-- 8 deg/sec means a 1.2° kick completes in ~7 frames at 60fps — matches
-- the feel of the popular server's 0.1/frame step loop.
local KICK_SPEED  = 8.0

local pendingKick = 0.0 -- queued degrees not yet applied to camera
local pitchAccum  = 0.0 -- degrees applied, waiting to recover
local lastShotAt  = 0   -- GetGameTimer() of last gated shot
local lastWeapon  = nil -- local weapon copy for change detection

-- ── View mode ─────────────────────────────────────────────────────────────────

local function viewMode()
    if cache.vehicle and cache.vehicle ~= false then return 'driveby' end
    if GetFollowPedCamViewMode() == 4 then return 'fpp' end
    return 'tpp'
end

-- ── Main loop ─────────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(0)

        -- Weapon change: reset kick and accumulation.
        if CombatState.weaponHash ~= lastWeapon then
            lastWeapon  = CombatState.weaponHash
            pendingKick = 0.0
            pitchAccum  = 0.0
        end

        local preset = CombatState.presetOverride or CombatState.preset
        local wd     = CombatState.weaponOverride or CombatState.weaponData

        if not preset or not wd then goto continue end

        local dt       = GetFrameTime()
        local now      = GetGameTimer()
        local shooting = IsPedShooting(cache.ped)

        -- 1. Drain pending kick smoothly this frame.
        if pendingKick > 0.001 then
            local step = math.min(KICK_SPEED * dt, pendingKick)
            SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() - step, 1.0)
            pitchAccum  = pitchAccum + step
            pendingKick = pendingKick - step
        end

        -- 2. New shot.
        if shooting then
            local interval = math.max(50, math.floor(60000 / (wd.fireRate or 400)))

            if now - lastShotAt >= interval then
                local mode     = viewMode()
                local r        = wd.recoil[mode]
                local mult     = preset.recoilMult

                -- Movement speed variance: +2% per m/s, capped at +25%.
                local speed    = GetEntitySpeed(cache.ped)
                local speedMod = math.min(1.25, 1.0 + speed * 0.02)

                -- Per-shot random variance: 50–95% of base, wider at speed.
                local hiRange  = math.min(95, 75 + math.floor(speed * 1.5))
                local shotRand = math.random(50, hiRange) / 100.0

                local upAmt    = r.up * mult * speedMod * shotRand
                local side     = r.side * mult * speedMod * shotRand

                -- Vertical cap.
                local cap      = preset.maxAccumulation
                if cap > 0 then
                    local total = pitchAccum + pendingKick
                    if total >= cap then
                        upAmt = 0.0
                    else
                        upAmt = math.min(upAmt, cap - total)
                    end
                end

                pendingKick = pendingKick + upAmt

                -- Horizontal drift on ~20% of shots (rolls 1 or 3 out of 10).
                if side > 0.001 and (math.random(1, 10) <= 2) then
                    local drift = (math.random() * 2.0 - 1.0) * side
                    SetGameplayCamRelativeHeading(
                        math.max(-179.0, math.min(179.0,
                            GetGameplayCamRelativeHeading() + drift)))
                end

                -- Camera shake: tactile feel only, no rotation.
                local shakeAmt = (wd.shake or 0.0) * math.max(0.2, mult)
                if shakeAmt > 0.001 then
                    ShakeGameplayCam('HAND_SHAKE', shakeAmt)
                end

                lastShotAt = now

                if configdebug then
                    print(('[Recoil] %s | %s | up=%.2f side=%.2f spd=%.1f rnd=%.2f accum=%.2f'):format(
                        wd.name, mode, upAmt, side, speed, shotRand,
                        pitchAccum + pendingKick))
                end
            end

            -- 3. Recovery — frame-rate independent via GetFrameTime().
        elseif pitchAccum > 0.001 and pendingKick < 0.001 then
            if (now - lastShotAt) >= (preset.recoveryDelay or 0) then
                local decay = math.min((preset.recoveryRate or 55.0) * dt, pitchAccum)
                SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() + decay, 1.0)
                pitchAccum = pitchAccum - decay
                if pitchAccum < 0.001 then pitchAccum = 0.0 end
            end
        end

        ::continue::
    end
end)

-- ── Debug overlay ─────────────────────────────────────────────────────────────

if configdebug then
    CreateThread(function()
        while true do
            Wait(0)
            local p = CombatState.presetOverride or CombatState.preset
            if p and p.maxAccumulation > 0 and (pitchAccum + pendingKick) > 0.001 then
                local total = pitchAccum + pendingKick
                local pct   = math.min(100, total / p.maxAccumulation * 100)
                SetTextFont(4)
                SetTextScale(0.28, 0.28)
                SetTextColour(255, 200, 50, 210)
                SetTextOutline()
                SetTextEntry('STRING')
                AddTextComponentString(('Recoil %.0f%%  (%.2f° / %.1f°)'):format(
                    pct, total, p.maxAccumulation))
                DrawText(0.01, 0.95)
            end
        end
    end)
end

-- ── Export ────────────────────────────────────────────────────────────────────

exports('getRecoilAccum', function()
    return pitchAccum + pendingKick
end)
