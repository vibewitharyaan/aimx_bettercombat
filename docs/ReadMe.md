# AimX BetterCombat

AimX BetterCombat is a professional-grade weapon overhaul and security system for FiveM that replaces default GTA combat with server-authoritative shooting mechanics. It provides a highly customizable recoil system and a robust anti-cheat layer to ensure fair, skill-based gunplay.

### Core Features

#### 1. Professional Recoil & Bloom System
Completely replaces the "floaty" default GTA shooting with a modern recoil engine.
*   **Dynamic Spray Control:** Weapons pull upwards and sideways during sustained fire, requiring players to actively control their aim.
*   **Accuracy Decay (Bloom):** Rapidly spamming shots increases bullet spread, while controlled "tap-firing" maintains high precision.
*   **Movement Penalties:** Accuracy and recoil are dynamically affected by player actions, such as running or shooting from a moving vehicle.

#### 2. Server-Authoritative Anti-Cheat (Damage Validator)
Eliminates common combat cheats by moving the "source of truth" to the server.
*   **Damage Correction:** The server intercepts every hit and calculates the correct damage based on the weapon used and body part hit, instantly canceling "one-shot" or "damage multiplier" hacks.
*   **No-Recoil Detection:** Automatically monitors and flags players who show inhumanly perfect recoil control over long periods.
*   **Headshot Analytics:** Tracks hit ratios to detect suspicious aimbots or "magic bullet" cheats.

#### 3. Advanced Bone Mapping (Hit Detection)
Provides precise, localized damage based on exactly where a player was hit.
*   **Localized Damage:** Body parts are grouped into Head, Torso, Limbs, and Feet, each with its own damage multipliers.
*   **Consistency:** Ensures that every player on the server experiences identical hit registration and damage logic.

#### 4. Live Weapon Tuner (Admin Dashboard)
A visual, in-game menu that allows staff to balance weapons in real-time.
*   **Real-Time Adjustments:** Change damage, recoil, and fire rates while in-game and see the results instantly without restarting the server.
*   **Code Exporter:** Once a weapon is perfectly tuned, the UI generates the exact code needed to save those settings into the permanent configuration.

#### 5. Combat Presets & Styles
Create different "feels" for different scenarios or areas of your server.
*   **Custom Presets:** Easily switch between "Realistic" (high recoil), "Arcade" (casual), or "Competitive" (balanced) combat styles.
*   **Lobby Support:** Assign specific combat styles to different players or map zones (e.g., a training arena vs. the open world).

#### 6. Drive-By & Vehicle Balancing
Specifically balances the "vehicle meta" to keep combat fair.
*   **Vehicle Multipliers:** Automatically applies increased recoil and reduced damage when shooting from inside a car window, preventing players from being overpowered while in vehicles.
