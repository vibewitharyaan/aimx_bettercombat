# better_combat

A clean weapon recoil and damage system for FiveM. Works on both RP and PvP servers.

---

## What it does

- Controls how much the camera kicks when you fire a weapon
- Controls how much damage each weapon deals
- Separates recoil for first-person, third-person, and drive-by shooting so each feels right
- Lets you switch recoil styles (presets) live without restarting the server
- Includes an in-game tuner menu so you can adjust values on the fly and save them

---

## Features

- **Separate FPP / TPP / Drive-by recoil** — each perspective has its own values so none of them feel broken
- **Organic recoil** — each shot kicks slightly differently, just like on popular servers
- **Movement penalty** — sprinting while shooting makes recoil slightly worse
- **Preset system** — switch between recoil styles (mild, competitive, hardcore, etc.) instantly
- **Live tuner** — adjust any value in-game with a menu, no file editing needed while testing
- **Addon weapon support** — custom / modded weapons automatically get a sensible fallback
- **Zero complexity** — no event interception, no bone detection, no server lag on shots

---

## Installation

1. Drop the `better_combat` folder into your server's `resources` directory
2. Add this line to your `server.cfg`:
   ```
   ensure better_combat
   ```
3. Open `config/config.lua` and set your mode and default preset (explained below)
4. Start your server — done

---

## Configuration

### `config/config.lua` — the main settings file

This is the only file most server owners need to touch.

```lua
config.mode          = 'single'   -- see below
config.defaultPreset = 'default'  -- which preset everyone starts with
```

**Mode options:**

| Mode       | Use it when                                                                  |
| ---------- | ---------------------------------------------------------------------------- |
| `'single'` | Everyone on the server uses the same recoil preset. Good for RP servers.     |
| `'multi'`  | Different players or zones can have different presets. Good for PvP servers. |

**Tuner settings:**

```lua
config.tuner = {
    command    = 'tuner',        -- the chat command to open the tuner menu
    permission = 'group.admin',  -- who is allowed to use it
}
```

**Debug mode:**

```lua
config.debug = false  -- set to true to see recoil values in F8 while testing
```

---

### `config/weapons.lua` — weapon damage and recoil values

Each weapon has its own entry. Here is what each field means:

```lua
[GetHashKey('WEAPON_ASSAULTRIFLE')] = {
    hashStr  = 'WEAPON_ASSAULTRIFLE',  -- the weapon name, used when exporting from the tuner
    name     = 'Assault Rifle',        -- display name, shown in the tuner menu
    class    = 'rifle',                -- weapon category (pistol, smg, rifle, shotgun, mg, sniper)
    damage   = 1.0,                    -- damage multiplier (explained below)
    recoil   = {
        fpp     = { up = 0.65, side = 0.22 },   -- first-person recoil
        tpp     = { up = 1.20, side = 0.40 },   -- third-person recoil
        driveby = { up = 2.20, side = 0.85 },   -- in-vehicle recoil
    },
    shake    = 0.10,   -- camera shake feel (0.0 = none, 1.0 = maximum)
    fireRate = 600,    -- rounds per minute, controls how fast recoil kicks apply
},
```

**Damage values explained:**

| Value  | What it means                                                                                             |
| ------ | --------------------------------------------------------------------------------------------------------- |
| `1.0`  | Default GTA damage — unchanged                                                                            |
| `0.7`  | 30% less damage — fights last longer (good for RP)                                                        |
| `1.4`  | 40% more damage — faster kills (good for PvP)                                                             |
| `0.25` | Low damage — roughly 4 body shots to down, 2 headshots (GTA applies its own headshot bonus automatically) |

**Recoil values explained:**

- `up` — how many degrees the camera kicks upward each shot. Higher = more kick.
- `side` — maximum random sideways drift each shot. Higher = more random wobble.
- FPP values are always lower than TPP because the same movement feels more intense in first-person.

**How to add a new weapon:**

Copy any existing entry, paste it below, and change the weapon name and values:

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

> **Addon / custom weapons** — if a weapon isn't listed here, the script automatically falls back to its weapon group (pistol group, rifle group, etc.) using the values in `config.weaponGroups` at the bottom of the file. You don't need to do anything for this to work.

---

### `config/presets.lua` — recoil styles

Presets control how recoil feels globally. They don't change damage — only the recoil behaviour.

```lua
default = {
    label           = 'Default',   -- display name shown in commands and notifications
    recoilMult      = 1.0,         -- multiplies all weapon recoil values (0.0 = no recoil, 2.0 = double)
    recoveryRate    = 55.0,        -- how fast the camera returns after firing (degrees per second)
    recoveryDelay   = 180,         -- milliseconds before recovery starts after last shot
    maxAccumulation = 14.0,        -- maximum degrees the camera can drift up during sustained fire
},
```

**Quick reference:**

| Field             | Lower value                 | Higher value                  |
| ----------------- | --------------------------- | ----------------------------- |
| `recoilMult`      | Less kick                   | More kick                     |
| `recoveryRate`    | Camera returns slowly       | Camera snaps back fast        |
| `recoveryDelay`   | Recovery starts immediately | Camera holds before returning |
| `maxAccumulation` | Spray is more controlled    | Spray walks further up        |

**How to add a new preset:**

```lua
my_custom_preset = {
    label           = 'My Custom Preset',
    recoilMult      = 0.90,
    recoveryRate    = 65.0,
    recoveryDelay   = 150,
    maxAccumulation = 11.0,
},
```

Then set it as default or assign it to players using the commands below.

---

## Admin commands

All commands require the permission set in `config.tuner.permission` (default: `group.admin`).

| Command                        | What it does                                              |
| ------------------------------ | --------------------------------------------------------- |
| `/tuner`                       | Opens the live tuner menu for your weapon                 |
| `/setglobalpreset <name>`      | Switches every player on the server to a preset instantly |
| `/setpreset <playerid> <name>` | Assigns a preset to one specific player                   |
| `/listpresets`                 | Prints all available preset names to your F8 console      |

**Example:**

```
/setglobalpreset pvp_competitive
/setpreset 5 rp_mild
```

---

## Live tuner

The tuner lets you adjust recoil and damage values in real time without touching any files.

1. Equip the weapon you want to tune
2. Run `/tuner` in chat
3. Click any value in the menu to change it — the change applies instantly
4. Fire the weapon to feel the result
5. When happy, click **Export snippet to F8** — this prints the final values to your F8 console
6. Copy those values into the correct config file to make them permanent
7. Click **Reset** at any time to go back to the original config values

---

## Switching presets from another resource

If you want to assign presets based on zones, game modes, or other logic, use these exports from your own resource:

```lua
-- Assign a preset to one player (use their server ID)
exports['better_combat']:setPlayerPreset(source, 'pvp_competitive')

-- Switch every player to a preset at once
exports['better_combat']:setGlobalPreset('rp_mild')

-- Get the current preset name for a player
local name = exports['better_combat']:getPlayerPreset(source)
```

---

## Included presets

| Preset name       | Description                                 |
| ----------------- | ------------------------------------------- |
| `default`         | Balanced starting point                     |
| `rp_mild`         | Easy recoil, forgiving, long fights         |
| `rp_standard`     | Moderate recoil for RP                      |
| `rp_realistic`    | Punishing recoil, requires discipline       |
| `pvp_competitive` | Low recoil, fast recovery, competitive feel |
| `pvp_standard`    | Balanced PvP recoil                         |
| `pvp_hardcore`    | High recoil, slow recovery, skill-based     |
| `pvp_no_recoil`   | Zero recoil, useful for aim training ranges |

---

## Headshot vs body shot damage

The script does not need any special headshot detection code. GTA's engine already applies a headshot damage bonus automatically (roughly ×2.5). You control the ratio by tuning the `damage` value per weapon.

**Example — 4 body shots / 2 headshots:**
Set `damage = 0.25` on the weapon. Body shots deal ~25 HP each. GTA's headshot bonus brings that to ~62 HP, which downs in 2 shots.

Tune this live using `/tuner` so you can feel the result immediately.

---

## File structure

```
better_combat/
├── fxmanifest.lua              — resource manifest, do not edit
├── config/
│   ├── config.lua              — main settings (mode, preset, tuner permission)
│   ├── weapons.lua             — per-weapon damage and recoil values
│   └── presets.lua             — recoil style presets
└── core/
    ├── client/
    │   ├── cl_main.lua         — weapon detection and damage modifier
    │   ├── cl_recoil.lua       — recoil loop
    │   └── cl_tuner.lua        — in-game tuner menu
    └── server/
        └── sv_main.lua         — preset management and admin commands
```

The only files you ever need to edit are the three inside `config/`.
