config = {}

-- UI Settings
config.theme = "custom" -- Which ui theme to use? (blue, red, green, purple, orange, pink, custom)

-- Debug Settings
config.debug = {
    code = true, -- Want to see code debug messages in console?
    zone = true  -- Want to see zone debug messages (areas & targets)?
}

----------------------------------------------------
--- WARNING: DO NOT MODIFY ANYTHING BELOW THIS LINE
----------------------------------------------------
lib.locale()

local function formatMsg(color, logType, ...)
    local showSource = true
    local args = { ... }

    local sourcePrefix = ""
    if showSource and (logType == "debug" or logType == "error") then
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
    end

    if #args > 1 and type(args[1]) == "string" and args[1]:find("%%") then
        local fmt = args[1]
        for i = 2, #args do
            local val = type(args[i]) == "table" and json.encode(args[i], { indent = true }) or tostring(args[i])
            val = val:gsub("%%", "%%%%")
            fmt = fmt:gsub("(%%[%-%d%.]*[sdifuoxXeEgGcqa])", "^" .. color .. val .. "^7", 1)
        end
        return sourcePrefix .. fmt
    end

    local message = {}
    for _, v in ipairs(args) do
        message[#message + 1] = type(v) == "table" and json.encode(v, { indent = true }) or tostring(v)
    end
    return sourcePrefix .. table.concat(message, " ")
end

local function logPrint(enabled, color, label, logType, ...)
    if not enabled then
        return
    end
    local message = formatMsg(color, logType, ...)
    print(string.format("^%s[%s]^7 %s^7", color, label, message))
end

_debug = function(...)
    logPrint(config.debug.code, "2", "DEBUG", "debug", ...)
end

_error = function(...)
    logPrint(true, "1", "ERROR", "error", ...)
end

_warn = function(...)
    logPrint(true, "3", "WARN", "warn", ...)
end

_info = function(...)
    logPrint(true, "6", "INFO", "info", ...)
end

local isServer = IsDuplicityVersion()

pname = function(src)
    if isServer then
        local name = GetPlayerName(src) or "unknown"
        return name .. " [" .. src .. "]"
    else
        return GetPlayerName(cache.playerId) or "unknown"
    end
end

resName = GetCurrentResourceName()
