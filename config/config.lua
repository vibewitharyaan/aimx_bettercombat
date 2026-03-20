config = {}

config.debug = {
    code = false,
}

config.mode          = 'single'
config.defaultPreset = 'default'

config.tuner = {
    command    = 'tuner',
    permission = 'group.admin',
}

----------------------------------------------------
--- WARNING: DO NOT MODIFY ANYTHING BELOW THIS LINE
----------------------------------------------------
lib.locale()

local function getSource(level)
    local info = debug.getinfo(level, 'Sl')
    if not info or not info.short_src then return '' end
    local parts = {}
    for part in info.short_src:gmatch('[^/\\]+') do parts[#parts + 1] = part end
    local display = #parts > 1
        and parts[#parts - 1] .. '/' .. parts[#parts]:gsub('%.lua$', '')
        or  parts[1]:gsub('%.lua$', '')
    return ('[%s:%d] '):format(display, info.currentline)
end

local showSource = false

local function log(enabled, color, label, ...)
    if not enabled then return end
    local args = { ... }
    local message
    if #args > 1 and type(args[1]) == 'string' then
        message = string.format(args[1], table.unpack(args, 2))
    else
        local parts = {}
        for i = 1, #args do
            local v = args[i]
            parts[i] = type(v) == 'table' and json.encode(v) or tostring(v)
        end
        message = table.concat(parts, ' ')
    end
    print(('^%s[%s]^7 %s%s^7'):format(color, label, showSource and getSource(4) or '', message))
end

function _debug(...) log(config.debug.code, '2', 'DEBUG', ...) end
function _error(...) log(true, '1', 'ERROR', ...) end
function _warn(...)  log(true, '3', 'WARN',  ...) end
function _info(...)  log(true, '6', 'INFO',  ...) end

function pname(src)
    if IsDuplicityVersion() then
        return (GetPlayerName(src) or 'unknown') .. ' (' .. src .. ')'
    end
    return GetPlayerName(cache.playerId) or 'unknown'
end

resName = GetCurrentResourceName()