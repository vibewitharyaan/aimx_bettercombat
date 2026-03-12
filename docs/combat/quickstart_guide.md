# WEAPON FRAMEWORK - QUICK START GUIDE

## 🚀 5-Minute Deployment

### Step 1: Install Dependencies (2 minutes)

```bash
cd /path/to/your/server/resources
git clone https://github.com/overextended/ox_lib.git
```

### Step 2: Install Framework (1 minute)

```bash
# Copy weapon_framework folder to resources/
# Your folder structure should be:
# resources/
#   ├── ox_lib/
#   └── weapon_framework/
#       ├── fxmanifest.lua
#       ├── shared/
#       ├── client/
#       └── server/
```

### Step 3: Configure Server (1 minute)

Add to `server.cfg`:

```cfg
# Load dependencies
ensure ox_lib
ensure weapon_framework

# Grant admin permissions (replace YOUR_LICENSE)
add_ace group.admin command.weapontuner allow
add_ace group.admin command.setpreset allow
add_ace group.admin command.changeglobalpreset allow
add_ace group.admin command.listpresets allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

### Step 4: Configure Framework (1 minute)

Edit `shared/config.lua`:

```lua
-- Choose your mode
Config.Mode = 'single'  -- or 'multi' for arena/lobby servers

-- Choose default preset
Config.DefaultPreset = 'realistic'  -- Options: realistic, competitive, hardcore, arcade

-- Configure anti-cheat
Config.AntiCheat.enabled = true
Config.AntiCheat.action = 'log'  -- Start with 'log', then 'kick' or 'ban'
```

### Step 5: Start Server

```bash
# Start or restart your server
restart weapon_framework
```

### ✅ Verify Installation

In-game, run:
```
/weaponinfo WEAPON_PISTOL
```

You should see weapon stats. If so, installation is successful!

---

## 📋 Pre-Production Checklist

### Configuration Review

- [ ] **Mode Selected**: `Config.Mode` set to 'single' or 'multi'
- [ ] **Default Preset**: `Config.DefaultPreset` exists in preset registry
- [ ] **Anti-Cheat Enabled**: `Config.AntiCheat.enabled = true`
- [ ] **Action Configured**: Start with 'log', escalate later
- [ ] **Tolerances Set**: Review preset validation settings

### Permission Setup

- [ ] **Admin ACEs**: `add_ace group.admin command.weapontuner allow`
- [ ] **Developer ACEs** (if needed): Same for group.developer
- [ ] **Principal Assignments**: All admins added to group.admin
- [ ] **Test Access**: Verify `/weapontuner` opens for admins only

### Testing Phase

- [ ] **Weapon Tests**: Verify each weapon class behaves correctly
- [ ] **Preset Tests**: Test all presets (realistic, competitive, hardcore, arcade)
- [ ] **Drive-By Tests**: Confirm recoil/damage multipliers in vehicles
- [ ] **Headshot Tests**: Verify bone damage multipliers and caps
- [ ] **Anti-Cheat Tests**: Simulate legitimate and modified damage

### Performance Verification

- [ ] **Client FPS**: Verify < 2% CPU impact
- [ ] **Server Tick**: Confirm < 1ms per event at peak load
- [ ] **Memory Usage**: Check for leaks after 1 hour runtime
- [ ] **Event Handling**: Verify weaponDamageEvent fires consistently

### Documentation

- [ ] **Staff Training**: Admin team knows tuner commands
- [ ] **Player Rules**: Combat rules documented if using anti-cheat
- [ ] **Preset Descriptions**: Players know what preset they're on
- [ ] **Ban Appeal Process**: If using 'ban' action

---

## 🎯 Quick Configuration Templates

### Template 1: Casual RP Server

```lua
Config.Mode = 'single'
Config.DefaultPreset = 'realistic'

Config.AntiCheat.enabled = true
Config.AntiCheat.action = 'log'  -- RP servers often use 'log' + manual review
Config.AntiCheat.minDetections = 10  -- More lenient

-- Use realistic preset with slight modifications
Presets.realistic.validation.damageTolerance = 0.20  -- More forgiving
Presets.realistic.validation.maxHeadshotRate = 0.55  -- Allow higher
```

### Template 2: Hardcore RP Server

```lua
Config.Mode = 'single'
Config.DefaultPreset = 'hardcore'

Config.AntiCheat.enabled = true
Config.AntiCheat.action = 'kick'  -- Auto-kick on multiple detections
Config.AntiCheat.minDetections = 5  -- Stricter

Presets.hardcore.damage.headshotCap = nil  -- No cap, high lethality
Presets.hardcore.validation.damageTolerance = 0.10  -- Very strict
```

### Template 3: Competitive PvP Server

```lua
Config.Mode = 'multi'  -- Different presets per arena
Config.DefaultPreset = 'competitive'

Config.AntiCheat.enabled = true
Config.AntiCheat.action = 'ban'  -- Zero tolerance
Config.AntiCheat.minDetections = 3  -- Fast action

Presets.competitive.validation.damageTolerance = 0.08  -- Tournament-grade
Presets.competitive.validation.maxHeadshotRate = 0.70  -- Skilled players
```

### Template 4: Arcade/Casual Server

```lua
Config.Mode = 'single'
Config.DefaultPreset = 'arcade'

Config.AntiCheat.enabled = false  -- Disable for maximum casual fun

Presets.arcade.recoil.globalMultiplier = 0.2  -- Very easy
Presets.arcade.damage.globalMultiplier = 0.7  -- Longer TTK
```

---

## 🔧 Common Configuration Patterns

### Pattern 1: Per-Weapon Balancing

Want to nerf a specific gun in your preset?

```lua
-- In your preset definition
Presets.myPreset = {
    recoil = {
        weaponMultipliers = {
            [`WEAPON_HEAVYSNIPER`] = 1.5,  -- +50% recoil
        }
    },
    damage = {
        weaponMultipliers = {
            [`WEAPON_HEAVYSNIPER`] = 0.6,  -- -40% damage
        }
    }
}
```

### Pattern 2: Zone-Based Presets (Multi-Preset Mode)

Different combat rules in different areas:

```lua
-- Server-side
AddEventHandler('playerEnteredZone', function(zone)
    local source = source
    local presets = {
        safezone = 'arcade',      -- Low recoil, low damage
        pvp_arena = 'competitive', -- Balanced PvP
        warzone = 'hardcore'      -- High lethality
    }
    
    local preset = presets[zone] or Config.DefaultPreset
    exports['weapon_framework']:assignPreset(source, preset, 'zone_system')
end)
```

### Pattern 3: Skill-Based Preset Assignment

Adjust difficulty based on player level:

```lua
-- Server-side
RegisterNetEvent('player:levelUp', function(level)
    local source = source
    local preset
    
    if level < 10 then
        preset = 'arcade'      -- Easy for beginners
    elseif level < 30 then
        preset = 'realistic'   -- Normal difficulty
    else
        preset = 'hardcore'    -- Challenge for veterans
    end
    
    exports['weapon_framework']:assignPreset(source, preset, 'level_system')
end)
```

---

## 🔍 Monitoring & Maintenance

### Daily Checks

```bash
# Check for detections
/detectionlog 50

# Review player with high headshot rate
/playerstats <suspicious_player_id>

# Verify preset distribution
/presetstats
```

### Weekly Tasks

1. **Review Detection Log**: Look for patterns
   ```lua
   local log = exports['weapon_framework']:getDetectionLog()
   -- Export to CSV for analysis
   ```

2. **Adjust Tolerances**: If false positives occur
   ```lua
   preset.validation.damageTolerance = 0.20  -- Increase
   /reloadpresets
   ```

3. **Update Weapon Balance**: Based on player feedback
   ```lua
   -- Edit shared/config.lua
   Config.Weapons[`WEAPON_PISTOL`].baseDamage = 22  -- Was 25
   /reloadpresets
   ```

### Monthly Review

- [ ] Check anti-cheat false positive rate
- [ ] Review ban appeals (if applicable)
- [ ] Analyze preset usage statistics
- [ ] Update weapon balance based on meta
- [ ] Test new GTA V updates for compatibility

---

## 🐛 Troubleshooting Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| "Preset not found" | Verify preset name in `/listpresets` |
| No recoil effect | Check if preset assigned: `/presetstats` |
| False positive bans | Increase `damageTolerance` to 0.20+ |
| Permission denied | Add ACE in server.cfg: `add_ace group.admin command.weapontuner allow` |
| Damage feels wrong | Use `/weaponinfo WEAPON_NAME realistic` to see calcs |
| High server load | Disable database logging, increase detection window |

---

## 📞 Support Commands Reference

### For Admins

```bash
# View all presets
/listpresets

# View current preset distribution
/presetstats

# Change entire server preset
/changeglobalpreset competitive

# Assign preset to specific player
/setpreset 1 hardcore

# View player combat stats
/playerstats 1

# Reset false positive
/resetstats 1

# View recent detections
/detectionlog 20

# Get weapon info
/weaponinfo WEAPON_PISTOL realistic

# Reload after config changes
/reloadpresets

# Open tuner UI
/weapontuner
```

### For Debugging

Enable debug mode in `shared/config.lua`:

```lua
Config.Debug = {
    enabled = true,
    visualizeRecoil = true,  -- Shows recoil meter on screen
    printDamage = true,      -- Logs damage calculations to console
    showBoneHits = true,     -- Shows which bone was hit
}
```

Then watch console for detailed logs.

---

## 🚨 Emergency Procedures

### If Anti-Cheat Causes Mass False Positives

1. **Immediate:**
   ```lua
   -- In server console
   sv_execute "set Config.AntiCheat.enabled false"
   restart weapon_framework
   ```

2. **Investigate:** Check detection log for pattern
   ```bash
   /detectionlog 100
   ```

3. **Adjust:** Increase tolerance in `shared/presets.lua`
   ```lua
   validation.damageTolerance = 0.25  -- Very lenient
   ```

4. **Reset:** Clear all player stats
   ```lua
   -- Server console
   for source in pairs(GetPlayers()) do
       exports['weapon_framework']:resetPlayerStats(source)
   end
   ```

5. **Re-enable:** After fix confirmed
   ```lua
   Config.AntiCheat.enabled = true
   /reloadpresets
   ```

### If Damage Feels Wrong

1. **Test Calculation:**
   ```bash
   /weaponinfo WEAPON_PISTOL realistic
   ```

2. **Check Active Preset:**
   ```bash
   /presetstats
   ```

3. **Force Reassignment:**
   ```bash
   /changeglobalpreset realistic
   ```

4. **Verify Weapon Config:**
   ```lua
   -- Check shared/config.lua
   Config.Weapons[`WEAPON_PISTOL`] = { ... }
   ```

---

## 📊 Success Metrics

After 1 week of production:

- [ ] **Zero False Positives**: No legitimate players flagged
- [ ] **Consistent Performance**: FPS and tick time stable
- [ ] **Detection Working**: Suspicious activity logged (if any)
- [ ] **Player Satisfaction**: Combat feels balanced
- [ ] **Admin Workload**: Minimal manual intervention needed

---

## 🎓 Training Resources

### For New Admins

1. **Read:** DOCUMENTATION.md (30 minutes)
2. **Practice:** Use `/weapontuner` on test server (15 minutes)
3. **Test:** Run through test scenarios (15 minutes)
4. **Review:** Watch detection log patterns (ongoing)

### For Developers

1. **Read:** ARCHITECTURE.md (full system understanding)
2. **Review:** All source files (2 hours)
3. **Test:** Run unit tests in `tests/` folder
4. **Extend:** Try adding custom bone group or preset

---

## 🔄 Update Process

When new weapons or GTA updates are released:

1. **Add Weapon Definition:**
   ```lua
   -- shared/config.lua
   Config.Weapons[`WEAPON_NEW`] = {
       name = 'New Weapon',
       class = 'rifle',
       baseDamage = 30,
       baseRecoil = 0.18,
       verticalRecoil = 0.15,
       horizontalRecoil = 0.10,
       fireRate = 600,
   }
   ```

2. **Test In-Game:**
   ```bash
   /weaponinfo WEAPON_NEW realistic
   ```

3. **Adjust Balance:**
   ```lua
   Presets.realistic.damage.weaponMultipliers[`WEAPON_NEW`] = 0.8
   ```

4. **Reload:**
   ```bash
   /reloadpresets
   ```

---

## ✅ Final Pre-Launch Checklist

### Technical

- [ ] ox_lib installed and working
- [ ] weapon_framework in resources folder
- [ ] server.cfg configured with ACE permissions
- [ ] Config.Mode and Config.DefaultPreset set
- [ ] All presets tested in-game
- [ ] Anti-cheat tested with legitimate play
- [ ] Performance verified (FPS and tick time)
- [ ] Debug mode disabled for production

### Administrative

- [ ] Admin team trained on commands
- [ ] Detection review process established
- [ ] Player rules communicated (if strict anti-cheat)
- [ ] Backup plan for false positives documented
- [ ] Monitoring schedule established

### Player-Facing

- [ ] Combat rules posted (if applicable)
- [ ] Preset descriptions available (if multi-preset)
- [ ] Support channels ready for questions
- [ ] Announcement prepared for go-live

### Rollback Plan

- [ ] Previous weapon system backed up
- [ ] Rollback procedure documented
- [ ] Test rollback on staging server

---

## 🎉 You're Ready!

If all checklist items are complete, you're ready for production deployment.

**Remember:**
- Start with lenient anti-cheat (`action = 'log'`)
- Monitor detection log daily for first week
- Adjust tolerances based on false positive rate
- Communicate changes to players

**Support:**
- Enable debug mode for troubleshooting
- Review DOCUMENTATION.md for detailed explanations
- Check ARCHITECTURE.md for system understanding

**Good luck!** 🚀
