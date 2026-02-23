# WEAPON TUNER - COMPLETE USAGE GUIDE

## Overview

The **Weapon Tuner** is a development tool for creating and configuring weapon behavior from scratch. It provides a visual interface to adjust recoil, damage, bone multipliers, and drive-by settings, then exports copy-paste-ready Lua code for your config files.

---

## 🎯 Purpose & Workflow

### The Complete Workflow:

```
1. Enable tuner mode (Config.AntiCheat.enabled = false)
2. Open tuner (/weapontuner)
3. Add or select weapon
4. Adjust values with sliders
5. Test in-game (fire weapon)
6. Fine-tune until perfect
7. Export configuration code
8. Copy to shared/config.lua and shared/presets.lua
9. Enable anti-cheat (Config.AntiCheat.enabled = true)
10. Restart resource
11. ✅ Players use your tuned weapons
```

---

## 🚀 Getting Started

### Step 1: Enable Development Mode

Edit `shared/config.lua`:

```lua
Config.AntiCheat = {
    enabled = false,  -- IMPORTANT: Disable during tuning
    -- ... rest of config
}
```

**Why?** With anti-cheat disabled, you can freely test different values without being flagged or having damage corrected.

### Step 2: Open Tuner

In-game, run:
```
/weapontuner
```

**Requirements:**
- Must have `group.admin` ACE permission
- Config.Tuner.permission must be set correctly

### Step 3: UI Overview

The tuner has 3 main panels:

**LEFT PANEL - Weapon List**
- Search bar for quick finding
- List of all weapons
- "Add New Weapon" button

**CENTER PANEL - Editor**
- Weapon information (name, class, fire rate)
- Recoil sliders
- Damage settings
- Bone multipliers
- Drive-by multipliers

**RIGHT PANEL - Preview & Export**
- Live damage calculations
- Save to preset selector
- Export buttons
- Copy functions

---

## 📝 Detailed Usage

### Adding a New Weapon

1. Click **"Add New Weapon"** in left sidebar
2. Enter weapon hash (e.g., `WEAPON_PISTOL`)
3. Enter weapon name (e.g., `Combat Pistol`)
4. Weapon appears in list with default values

**Pro Tip:** Use [FiveM Weapon Hashes](https://wiki.rage.mp/index.php?title=Weapons) for reference

### Configuring Weapon Information

**Fields:**
- **Weapon Hash:** Identifier (e.g., WEAPON_PISTOL) - Read-only once created
- **Weapon Name:** Display name shown to players
- **Weapon Class:** pistol, smg, rifle, sniper, shotgun, mg
- **Fire Rate:** Rounds per minute (30-1200)

**Example Values:**
```
Pistol: 300-500 RPM
SMG: 700-1000 RPM
Rifle: 500-800 RPM
Sniper: 30-100 RPM
```

### Adjusting Recoil

**Three Components:**

1. **Base Recoil** (0.00 - 1.00)
   - Overall recoil intensity
   - Higher = more camera shake
   - Recommended: 0.10-0.30 for most weapons

2. **Vertical Recoil** (0.00 - 1.00)
   - Upward kick per shot
   - Usually 80% of base recoil
   - Recommended: Slightly less than base

3. **Horizontal Recoil** (0.00 - 1.00)
   - Side-to-side drift
   - Usually 50-60% of base recoil
   - Recommended: Half of vertical

**Testing Recoil:**
1. Adjust sliders
2. Click **"Test Recoil Now"**
3. Fire your equipped weapon
4. Feel the recoil instantly
5. Adjust and test again

**Pro Tips:**
- Start with base=0.15, vertical=0.12, horizontal=0.08
- High ROF weapons need lower recoil (SMGs)
- Low ROF weapons can have higher recoil (Snipers)
- Pistols: 0.10-0.20
- Rifles: 0.15-0.25
- Snipers: 0.40-0.80

### Configuring Damage

**Base Damage Slider** (1 - 200)
- Raw damage per bullet before multipliers
- Preview shows calculated damage per bone

**Typical Values:**
```
Pistols: 20-35
SMGs: 18-25
Rifles: 28-35
Snipers: 80-150
Shotguns: 70-90
```

### Bone Multipliers

**Default Bone Groups:**
- **Head:** Usually 2.0-3.5x damage
- **Torso:** Base damage (1.0x)
- **Legs:** Usually 0.6-0.8x damage
- **Arms:** Usually 0.7-0.9x damage

**Adding Custom Bone Groups:**
1. Click **"Add Bone Group"**
2. Enter bone name (e.g., `neck`, `hands`)
3. Set multiplier value
4. Must map bones in `shared/bone_map.lua` for server-side validation

**Example Configurations:**

**Realistic (RP):**
```
head: 2.5x
torso: 1.0x
legs: 0.7x
arms: 0.8x
```

**Competitive (PvP):**
```
head: 3.0x
torso: 1.0x
legs: 0.6x
arms: 0.7x
```

**Arcade (Fun):**
```
head: 1.5x
torso: 1.0x
legs: 0.9x
arms: 0.95x
```

### Drive-By Multipliers

Controls weapon behavior when shooting from vehicles:

**Recoil Multiplier** (0.5 - 5.0)
- How much MORE recoil in vehicles
- 1.0 = same as on foot
- 1.5 = 50% more recoil
- Recommended: 1.5-2.5

**Damage Multiplier** (0.1 - 2.0)
- Damage scaling in vehicles
- 1.0 = same as on foot
- 0.8 = 20% less damage
- Recommended: 0.6-0.9 (nerf drive-bys)

**Balance Tip:** Make drive-bys harder (higher recoil) and less effective (lower damage) to encourage ground combat.

---

## 💾 Exporting Configuration

### Export Options

**1. Weapon Config** (Primary)
- Generates code for `shared/config.lua`
- Adds weapon to `Config.Weapons` table
- Contains all base stats

**2. Preset Modifier** (Optional)
- Generates code for `shared/presets.lua`
- Adds weapon-specific multipliers to chosen preset
- Useful for per-preset weapon balance

**3. JSON Export** (Backup)
- Full configuration as JSON
- Can be version-controlled
- Useful for sharing with team

### Export Workflow

**Standard Export:**

1. Finish tuning weapon
2. Select preset from dropdown (realistic, competitive, hardcore, arcade)
3. Click **"Export Configuration"**
4. Modal opens with 3 tabs
5. Copy code from "Weapon Config" tab
6. Paste into `shared/config.lua` inside `Config.Weapons = { }`
7. Restart resource

**Example Export:**

```lua
-- Generated code (copy this):
[`WEAPON_PISTOL`] = {
    name = 'Combat Pistol',
    class = 'pistol',
    baseDamage = 25,
    baseRecoil = 0.150,
    verticalRecoil = 0.120,
    horizontalRecoil = 0.080,
    fireRate = 400,
},
```

**Where to paste:**

```lua
-- shared/config.lua
Config.Weapons = {
    -- Paste your exported code here
    [`WEAPON_PISTOL`] = {
        name = 'Combat Pistol',
        class = 'pistol',
        baseDamage = 25,
        baseRecoil = 0.150,
        verticalRecoil = 0.120,
        horizontalRecoil = 0.080,
        fireRate = 400,
    },
    
    -- Add more weapons...
}
```

### Quick Copy Buttons

**Bottom right panel buttons:**

- **Copy Weapon Config** - Instant clipboard copy of weapon code
- **Copy Preset Modifier** - Instant clipboard copy of preset adjustments
- **Export as JSON** - Copy full JSON configuration

---

## 🎨 Preset Configuration

### Choosing Your Preset

When exporting, you select which preset this weapon belongs to:

**Realistic** - Balanced RP combat
- Moderate recoil
- Realistic damage
- Headshots significant but not instant-kill

**Competitive** - Fast-paced PvP
- Low recoil (skill-based)
- Higher damage (fast TTK)
- Headshots critical

**Hardcore** - Realistic sim
- High recoil
- High lethality
- One-shot headshots possible

**Arcade** - Casual fun
- Very low recoil
- Lower damage (longer fights)
- Forgiving hitboxes

**Custom Preset**
- Select "Custom Preset..." from dropdown
- Enter your preset name
- Creates new preset configuration

### Preset Workflow

**Scenario: Creating "swat_preset" for your SWAT job**

1. Configure weapon in tuner
2. Select "Custom Preset..." from dropdown
3. Enter `swat_preset`
4. Export configuration
5. Copy "Preset Modifier" tab code
6. Create `Presets.swat_preset` in `shared/presets.lua`:

```lua
Presets.swat_preset = {
    name = 'swat_preset',
    description = 'SWAT Team loadout',
    
    recoil = {
        globalMultiplier = 0.8,  -- Less recoil for trained officers
        weaponMultipliers = {
            -- Paste weapon-specific multipliers here
        },
        driveByMultiplier = 1.0,
        recoveryDelay = 150,
        recoveryRate = 0.002,
    },
    
    damage = {
        globalMultiplier = 1.2,  -- More damage for tactical weapons
        weaponMultipliers = {},
        boneMultipliers = {
            head = 3.0,
            torso = 1.0,
            legs = 0.7,
            arms = 0.8,
        },
        headshotCap = nil,
        driveByMultiplier = 1.0,
    },
    
    validation = {
        damageTolerance = 0.15,
        recoilTolerance = 0.20,
        maxHeadshotRate = 0.60,
        minShotsForHeadshotCalc = 20,
    },
}

-- Register it
presetRegistry.swat_preset = Presets.swat_preset
```

---

## 🔧 Advanced Features

### Live Preview

**Right panel shows real-time calculations:**
- Headshot Damage: base × head multiplier
- Torso Damage: base × torso multiplier
- Leg Damage: base × leg multiplier
- Arm Damage: base × arm multiplier

**Example:**
```
Base Damage: 30
Head Multiplier: 2.5x
Preview Shows: 75.0
```

This is exactly what players will take in-game (before global/preset multipliers).

### Save to Server

**"Save to Server" button:**
- Sends configuration to server
- Server logs it
- Useful for team collaboration
- Primary export method is still copy/paste code

### Reset Weapon

**"Reset" button in header:**
- Reverts weapon to default values
- Useful if you mess up
- Clears all custom settings

---

## 🏗️ Building Complete Weapon Sets

### Recommended Workflow

**1. Plan Your Weapon Classes**
```
Pistols: Low recoil, moderate damage, fast fire
SMGs: Medium recoil, low damage, very fast fire
Rifles: Medium recoil, high damage, moderate fire
Snipers: High recoil, very high damage, slow fire
```

**2. Configure Base Weapon**
- Start with one weapon per class
- Get the "feel" right
- This becomes your template

**3. Clone Settings**
- Configure similar weapons with slight variations
- Pistol50 = Pistol but +50% recoil, +60% damage
- CarbineRifle = AssaultRifle but -10% recoil, -5% damage

**4. Test Everything**
- Spawn NPCs
- Test each weapon
- Check damage values
- Feel recoil patterns

**5. Balance Pass**
- Compare weapon performance
- Adjust outliers
- Ensure variety but balance

**6. Export All**
- Export each weapon
- Combine into one config file
- Version control recommended

---

## 📊 Example Configuration Session

**Goal:** Configure WEAPON_PISTOL for realistic RP server

### Step-by-Step:

1. **Open Tuner** (`/weapontuner`)

2. **Add Weapon**
   - Click "Add New Weapon"
   - Hash: `WEAPON_PISTOL`
   - Name: `Combat Pistol`

3. **Set Basic Info**
   - Class: pistol
   - Fire Rate: 400

4. **Configure Recoil**
   - Base: 0.15 (moderate)
   - Vertical: 0.12 (slightly less)
   - Horizontal: 0.08 (minimal drift)
   - Test: Click "Test Recoil Now", fire weapon, feels good ✅

5. **Configure Damage**
   - Base: 25 (takes 4 torso shots to down 100HP player)
   - Head: 2.5x = 62.5 damage (2 headshots or 1 headshot + 2 body)
   - Torso: 1.0x = 25 damage
   - Legs: 0.7x = 17.5 damage (6 shots)
   - Arms: 0.8x = 20 damage (5 shots)

6. **Drive-By Settings**
   - Recoil: 1.5x (harder to control)
   - Damage: 0.8x (20 per shot from car)

7. **Export**
   - Select "realistic" preset
   - Click "Export Configuration"
   - Copy "Weapon Config" code
   - Paste in `shared/config.lua`

8. **Done!**
   - Restart resource
   - Enable anti-cheat (`Config.AntiCheat.enabled = true`)
   - Test in production

---

## ⚠️ Important Notes

### Security Considerations

**During Tuning:**
- `Config.AntiCheat.enabled = false` - Anti-cheat OFF
- Anyone can test without validation
- Development/staging server only

**After Tuning:**
- `Config.AntiCheat.enabled = true` - Anti-cheat ON
- Values locked and validated
- Production-ready

### Common Mistakes

❌ **Forgetting to export** - You lose your work!  
✅ Copy code immediately after tuning

❌ **Extreme values** - recoil=1.0, damage=200  
✅ Use recommended ranges

❌ **Testing without weapon equipped**  
✅ Equip weapon before clicking "Test Recoil"

❌ **Not restarting resource after paste**  
✅ Always `restart weapon_framework`

❌ **Leaving anti-cheat disabled in production**  
✅ Enable after tuning complete

### Performance Tips

- Close tuner when not actively using
- Test on local/dev server first
- Don't configure 100 weapons in one session
- Save/export frequently

---

## 🎓 Best Practices

### Configuration Standards

**Naming Convention:**
```lua
-- Good
[`WEAPON_PISTOL`] = { name = 'Combat Pistol', ... }

-- Bad
[`WEAPON_PISTOL`] = { name = 'gun', ... }
```

**Readable Values:**
```lua
-- Good
baseDamage = 25,
baseRecoil = 0.150,

-- Bad (too precise)
baseDamage = 25.3847,
baseRecoil = 0.1529384,
```

**Comments:**
```lua
[`WEAPON_HEAVYSNIPER`] = {
    name = 'Heavy Sniper',
    baseDamage = 150,  -- Balanced for 1-shot down with headshot
    baseRecoil = 0.800,  -- Heavy kick, slow follow-up
    -- ...
}
```

### Version Control

**Recommended Structure:**
```
configs/
  ├── v1.0_realistic.lua    (Initial balance)
  ├── v1.1_realistic.lua    (After feedback)
  ├── v1.0_competitive.lua  (PvP variant)
  └── current.lua           (Active config)
```

### Team Workflow

**Solo Developer:**
1. Tune locally
2. Export & paste
3. Commit to repo
4. Deploy

**Team of Developers:**
1. Dev A tunes pistols → exports JSON
2. Dev B tunes rifles → exports JSON
3. Combine JSON files
4. Generate final Lua config
5. Review together
6. Deploy

---

## 🆘 Troubleshooting

### Tuner Won't Open

**Problem:** `/weapontuner` does nothing

**Solutions:**
1. Check ACE permission in server.cfg
2. Verify `Config.Tuner.permission = 'group.admin'`
3. Ensure you're in admin group
4. Check F8 console for errors
5. Restart resource

### Values Don't Apply

**Problem:** Changes in tuner don't affect game

**Solutions:**
1. Click "Test Recoil Now" for recoil changes
2. Damage only applies after export + restart
3. Check anti-cheat isn't overriding (`enabled = false`)
4. Verify weapon is equipped

### Export Code Doesn't Work

**Problem:** Pasted code causes errors

**Solutions:**
1. Check for syntax errors (missing commas)
2. Ensure pasted inside correct table
3. Verify hash format: `` [`WEAPON_NAME`] ``
4. Check for duplicate entries
5. Restart resource after paste

---

## 📚 Reference

### Keyboard Shortcuts

- **ESC** - Close tuner
- **Ctrl+C** - Copy (when export modal open)

### Config File Locations

```
weapon_framework/
  ├── shared/
  │   ├── config.lua     ← Paste weapon configs here
  │   └── presets.lua    ← Paste preset modifiers here
```

### Useful Commands

```bash
/weapontuner          # Open tuner
/weaponinfo WEAPON_X  # View weapon stats
/reloadpresets        # Reload after changes
```

---

## 🎯 Quick Reference Card

```
┌─────────────────────────────────────────┐
│         WEAPON TUNER CHEAT SHEET        │
├─────────────────────────────────────────┤
│ RECOIL VALUES:                          │
│   Low:    0.05 - 0.15                   │
│   Medium: 0.15 - 0.30                   │
│   High:   0.30 - 0.60                   │
│   Extreme: 0.60 - 1.00                  │
│                                         │
│ DAMAGE VALUES:                          │
│   Pistol:  20-35                        │
│   SMG:     18-25                        │
│   Rifle:   28-35                        │
│   Sniper:  80-150                       │
│                                         │
│ BONE MULTIPLIERS:                       │
│   Head:  2.0 - 3.5x                     │
│   Torso: 1.0x (base)                    │
│   Legs:  0.6 - 0.8x                     │
│   Arms:  0.7 - 0.9x                     │
│                                         │
│ WORKFLOW:                               │
│   1. Disable anti-cheat                 │
│   2. Open tuner                         │
│   3. Configure weapon                   │
│   4. Test with "Test Recoil Now"        │
│   5. Export code                        │
│   6. Paste in config                    │
│   7. Enable anti-cheat                  │
│   8. Restart resource                   │
└─────────────────────────────────────────┘
```

---

**Version:** 1.0.0  
**Last Updated:** December 28, 2025  
**Support:** See DOCUMENTATION.md for full framework details
