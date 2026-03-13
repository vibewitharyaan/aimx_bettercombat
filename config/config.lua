config = {}

-- UI Settings
config.theme = "custom" -- UI theme: blue, red, green, purple, orange, pink, custom

-- Debug Settings
config.debug = {
    code = true,             -- Show logic debug messages in console
    zone = true,             -- Show zone/area debug messages
    visualizeRecoil = false, -- Draw a recoil percentage bar on screen
    printDamage = false,     -- Print damage values to console
    showBoneHits = false,    -- Print which bone was hit
}

-- Framework Mode
config.mode = 'single' -- 'single' (global preset) or 'multi' (lobby/player specific)
config.defaultPreset = 'realistic'

-- Performance Settings
config.recoilUpdateInterval = 0 -- 0 = every frame (Wait(0))
config.recoilRecoveryWindow = 150
config.recoilDecayRate = 0.002

-- Anti-Cheat Configuration
config.antiCheat = {
    enabled = false,               -- Set to true for production
    logLevel = 'suspicious',       -- 'none', 'suspicious', 'all'
    allowKick = false,
    allowBan = false,
    minDetections = 5,
    detectionWindow = 300,
    useDatabase = false,
    databaseExport = nil,
}

-- Weapon Definitions (Pistols & SMGs Only)
config.weapons = {
    -- Pistols
    [`WEAPON_PISTOL`] = {
        name = 'Pistol',
        class = 'pistol',
        baseDamage = 25,
        baseRecoil = 0.15,
        verticalRecoil = 0.12,
        horizontalRecoil = 0.08,
        fireRate = 400,
    },
    [`WEAPON_COMBATPISTOL`] = {
        name = 'Combat Pistol',
        class = 'pistol',
        baseDamage = 27,
        baseRecoil = 0.14,
        verticalRecoil = 0.11,
        horizontalRecoil = 0.07,
        fireRate = 450,
    },
    [`WEAPON_HEAVYPISTOL`] = {
        name = 'Heavy Pistol',
        class = 'pistol',
        baseDamage = 35,
        baseRecoil = 0.25,
        verticalRecoil = 0.20,
        horizontalRecoil = 0.10,
        fireRate = 350,
    },
    [`WEAPON_APPISTOL`] = {
        name = 'AP Pistol',
        class = 'pistol',
        baseDamage = 22,
        baseRecoil = 0.10,
        verticalRecoil = 0.08,
        horizontalRecoil = 0.06,
        fireRate = 800,
    },

    -- SMGs
    [`WEAPON_MICROSMG`] = {
        name = 'Micro SMG',
        class = 'smg',
        baseDamage = 18,
        baseRecoil = 0.12,
        verticalRecoil = 0.10,
        horizontalRecoil = 0.08,
        fireRate = 900,
    },
    [`WEAPON_ASSAULTSMG`] = {
        name = 'Assault SMG',
        class = 'smg',
        baseDamage = 22,
        baseRecoil = 0.14,
        verticalRecoil = 0.12,
        horizontalRecoil = 0.09,
        fireRate = 800,
    },
}

-- Drive-By Multipliers (Class-based)
config.driveByMultipliers = {
    pistol = { recoil = 1.5, damage = 0.8 },
    smg = { recoil = 1.8, damage = 0.7 },
}

-- Tuner Settings
config.tuner = {
    permission = 'group.admin',
    command = 'weapontuner',
    livePreview = true,
    exportFormat = 'both',
}

-- Utility Functions
function config.getWeapon(weaponHash)
    if type(weaponHash) == 'string' then
        weaponHash = tonumber(weaponHash) or GetHashKey(weaponHash)
    end
    return config.weapons[weaponHash]
end

function config.getWeaponClass(weaponHash)
    local weapon = config.getWeapon(weaponHash)
    return weapon and weapon.class or nil
end

function config.getDriveByMultiplier(weaponHash)
    local class = config.getWeaponClass(weaponHash)
    return class and config.driveByMultipliers[class] or { recoil = 1.0, damage = 1.0 }
end

----------------------------------------------------
--- DONT TOUCH ANYTHING BELOW THIS!! 
----------------------------------------------------
lib.locale()

local function formatMsg(color, logType, ...)
    local args = { ... }
    local sourcePrefix = ""

    -- Find caller info for better debugging
    local configFile = debug.getinfo(1, "S").short_src
    local level = 4
    local info = debug.getinfo(level, "Sl")

    while info and info.short_src == configFile do
        level = level + 1
        info = debug.getinfo(level, "Sl")
    end

    if info and info.short_src then
        local fileName = info.short_src:match("([^/\\]+)$") or info.short_src
        fileName = fileName:gsub("%.lua$", "")
        sourcePrefix = string.format("[%s:%d] ", fileName, info.currentline)
    end

    -- Format string if pattern detected
    if #args > 1 and type(args[1]) == "string" and args[1]:find("%%") then
        local fmt = args[1]
        for i = 2, #args do
            local val = type(args[i]) == "table" and json.encode(args[i], { indent = true }) or tostring(args[i])
            val = val:gsub("%%", "%%%%")
            fmt = fmt:gsub("(%%[%-%d%.]*[sdifuoxXeEgGcqa])", "^" .. color .. val .. "^7", 1)
        end
        return sourcePrefix .. fmt
    end

    -- Basic concatenation
    local message = {}
    for _, v in ipairs(args) do
        message[#message + 1] = type(v) == "table" and json.encode(v, { indent = true }) or tostring(v)
    end
    return sourcePrefix .. table.concat(message, " ")
end

local function logPrint(enabled, color, label, logType, ...)
    if not enabled then return end
    local message = formatMsg(color, logType, ...)
    print(string.format("^%s[%s]^7 %s^7", color, label, message))
end

-- Global Logging Handlers
_debug = function(...) logPrint(config.debug.code, "2", "DEBUG", "debug", ...) end
_error = function(...) logPrint(true, "1", "ERROR", "error", ...) end
_warn  = function(...) logPrint(true, "3", "WARN", "warn", ...) end
_info  = function(...) logPrint(true, "6", "INFO", "info", ...) end


resName, isServer = GetCurrentResourceName(), IsDuplicityVersion()

pname             = function(src)
    if isServer then
        return (GetPlayerName(src) or "unknown") .. " [" .. src .. "]"
    else
        return GetPlayerName(cache.playerId) or "unknown"
    end
end
