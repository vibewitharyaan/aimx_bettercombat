# better_combat

A weapon recoil and damage system for FiveM servers. It controls how the camera moves when you shoot and how much damage each weapon deals. Works for both RP and PvP servers.

---

## What it does

When a player fires a weapon, the camera kicks upward slightly — just like in real life. The script controls how strong that kick is, how quickly the camera settles back, and how much damage the weapon deals. Everything is fully adjustable without touching any code.

It also separates recoil depending on how you are playing:

- **First-person** — lower kick, because the same movement feels much stronger in first-person
- **Third-person** — standard kick values
- **In a vehicle** — higher kick, because drive-by shooting is harder to control

---

## Features

- Separate recoil values for first-person, third-person, and drive-by — each feels right on its own
- Each shot kicks slightly differently every time — not robotic, feels organic and natural
- Moving or sprinting while shooting increases recoil slightly
- Full preset system — switch between different recoil styles instantly, no server restart needed
- Live in-game tuner — change any value while playing and feel the result immediately
- Works with custom and addon weapons automatically
- No performance impact when no weapon is held

---

## Presets

A preset is a recoil style. Instead of editing weapon values one by one, you switch the whole feel of the server in one command. Damage is never changed by switching a preset — only how the camera behaves when you shoot.

**Presets included out of the box:**

| Preset name       | What it feels like                                             |
| ----------------- | -------------------------------------------------------------- |
| `default`         | Balanced — good starting point for any server                  |
| `rp_mild`         | Very easy to control, forgiving, fights last longer            |
| `rp_standard`     | Moderate recoil for roleplay servers                           |
| `rp_realistic`    | Punishing recoil, requires trigger discipline                  |
| `pvp_competitive` | Low recoil, camera snaps back fast — good for competitive play |
| `pvp_standard`    | Balanced for PvP                                               |
| `pvp_hardcore`    | High recoil, slow recovery — skill-based                       |
| `pvp_no_recoil`   | Zero recoil — useful for aim training or shooting ranges       |

---

## How to set up

Open `config/config.lua`. This is the only file you need to touch to get started.

**Pick your mode:**

```lua
config.mode = 'single'
```

- `'single'` — everyone on the server uses the same preset. Best for RP servers.
- `'multi'` — different players can have different presets. Best for PvP servers with zones or game modes.

**Pick your starting preset:**

```lua
config.defaultPreset = 'default'
```

Change `'default'` to any preset name from the list above.

**Set who can use admin commands:**

```lua
config.tuner = {
    command    = 'tuner',
    permission = 'group.admin',
}
```

Change `'group.admin'` to whatever ace permission your admins have.

---

## Weapon settings explained

Every weapon has its own entry in `config/weapons.lua`. Here is what each value means:

```lua
damage = 1.0
```

How much damage the weapon deals per bullet.

- `1.0` = exactly GTA's default damage
- `0.7` = 30% less damage — fights last longer, good for RP
- `1.4` = 40% more damage — faster kills, good for PvP
- `0.25` = low damage — roughly 4 shots to down on the body, 2 shots to the head

> GTA automatically makes headshots deal more damage (roughly 2.5× more). You do not need to configure this separately — it just works.

---

```lua
recoil = {
    fpp     = { up = 0.65, side = 0.22 },
    tpp     = { up = 1.20, side = 0.40 },
    driveby = { up = 2.20, side = 0.85 },
},
```

These are the base recoil values per perspective.

- `up` — how many degrees the camera kicks upward on each shot. Higher = more kick.
- `side` — how much the camera can drift left or right randomly. Higher = more wobble.
- `fpp` = first-person view
- `tpp` = third-person view
- `driveby` = shooting from inside a vehicle

---

```lua
shake = 0.10
```

The physical camera shake feel when you fire. Does not rotate the camera — just adds a tactile kick. Range is `0.0` to `1.0`.

---

```lua
fireRate = 600
```

How many rounds per minute the weapon fires. This controls how fast recoil kicks are applied on automatic weapons. Match this to the real weapon's fire rate for accurate feel.

---

## Preset settings explained

Every preset in `config/presets.lua` has these values:

```lua
recoilMult = 1.0
```

Multiplies all weapon recoil values. Think of it as a global volume knob for recoil.

- `0.0` = no recoil at all
- `1.0` = weapon values as configured
- `2.0` = double the recoil

---

```lua
recoveryRate = 55.0
```

How fast the camera drifts back to where you were aiming after you stop shooting. Measured in degrees per second.

- Low number = slow, floaty return
- High number = quick snap back

---

```lua
recoveryDelay = 180
```

How many milliseconds the camera waits before it starts returning after your last shot. Useful for making automatic weapons feel like they hold their position briefly before settling.

- `0` = recovery starts immediately
- `300` = waits 0.3 seconds before returning

---

```lua
maxAccumulation = 14.0
```

The maximum degrees the camera can drift upward during sustained fire. Once this ceiling is hit, further shots only add sideways wobble — the camera stops going higher.

- Low number = more controlled spray
- High number = camera walks far up during long bursts

---

## Adding a new weapon

Open `config/weapons.lua`, copy any existing entry, paste it at the bottom of the list, and change the weapon name and values. Example:

```lua
[GetHashKey('WEAPON_CARBINERIFLE')] = {
    hashStr  = 'WEAPON_CARBINERIFLE',
    name     = 'Carbine Rifle',
    class    = 'rifle',
    damage   = 1.0,
    recoil   = {
        fpp     = { up = 0.60, side = 0.20 },
        tpp     = { up = 1.10, side = 0.36 },
        driveby = { up = 2.00, side = 0.78 },
    },
    shake    = 0.10,
    fireRate = 650,
},
```

Custom or addon weapons that are not listed are handled automatically using their weapon type group. They will not error — they just get a generic fallback.

---

## Adding a new preset

Open `config/presets.lua` and add a new block anywhere inside the list:

```lua
my_custom_preset = {
    label           = 'My Custom Preset',
    recoilMult      = 0.90,
    recoveryRate    = 65.0,
    recoveryDelay   = 150,
    maxAccumulation = 11.0,
},
```

The `label` is what shows in notifications and the tuner menu. The name on the left (`my_custom_preset`) is what you use in commands and exports.

---

## Admin commands

| Command                        | What it does                                                  |
| ------------------------------ | ------------------------------------------------------------- |
| `/tuner`                       | Opens the live tuner for the weapon you are currently holding |
| `/setglobalpreset <name>`      | Switches every player on the server to a preset right now     |
| `/setpreset <playerid> <name>` | Assigns a preset to one specific player                       |
| `/listpresets`                 | Shows all available preset names in your F8 console           |

---

## Live tuner

The tuner lets you adjust every single value while you are in-game and feel the result immediately — no editing files, no restarting anything.

1. Hold the weapon you want to tune
2. Type `/tuner` in chat
3. Click any value in the menu
4. Type a new number and confirm
5. Fire the weapon — the change is already live
6. Repeat until it feels right
7. Click **Export snippet to F8** — a ready-to-paste block of code appears in your F8 console
8. Copy that block into the config file to make it permanent
9. Click **Reset** at any time to undo all changes and go back to the saved config values

---

## Switching presets from your own scripts

If you want to change presets automatically based on zones, events, or game modes:

```lua
-- Give one player a specific preset
exports['better_combat']:setPlayerPreset(source, 'pvp_competitive')

-- Switch every player on the server at once
exports['better_combat']:setGlobalPreset('rp_mild')

-- Check what preset a player currently has
local name = exports['better_combat']:getPlayerPreset(source)
```

---

## Headshot vs body shot damage

The script does not need any special headshot code. GTA already applies roughly 2.5× more damage on headshots automatically. You control how many shots it takes by adjusting the `damage` value per weapon.

If you want roughly 4 body shots and 2 headshots to down someone, set `damage = 0.25` on that weapon. Use the live tuner to test it in real time until it feels right.
