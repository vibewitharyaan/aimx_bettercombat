-- [UI MODULE] --

ui = {}
ui.loaded = false


-- [NUI COMMUNICATION] --

local NUI_DEBUG = { init = true, uiLoaded = true }

---@diagnostic disable-next-line: duplicate-set-field
function ui.sendMsg(action, data)
    local msg = { action = action }
    if data then msg.data = data end
    SendNUIMessage(msg)

    if not NUI_DEBUG[action] then
        _debug("[NUI-MSG] Action: %s | Data: %s", action, json.encode(data))
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function ui.focus(focus, cursor)
    SetNuiFocus(focus, cursor == nil and focus or cursor)
end

---@diagnostic disable-next-line: duplicate-set-field
function ui.registerCb(name, handler)
    RegisterNUICallback(name, function(data, cb)
        local ok, result = pcall(handler, data)
        if not ok then
            _error("[NUI-CB] Failed: %s | Error: %s", name, tostring(result))
            cb({ ok = false, error = "Internal error" })
            return
        end

        if not NUI_DEBUG[name] then
            local msg = "[NUI-CB] " .. name
            if data then msg = msg .. " | Data: " .. json.encode(data) end
            if result then msg = msg .. " | Result: " .. json.encode(result) end
            _debug(msg)
        end

        cb({ ok = true, data = result })
    end)
end

-- [UI STATE] --

local function initLocales(cb)
    local locales = lib.getLocales()
    local uiLocales = {}

    for key, value in pairs(locales) do
        local uiKey = key:match("^ui%.(.+)$")

        if uiKey then
            local keys = {}

            for part in uiKey:gmatch("[^%.]+") do
                table.insert(keys, part)
            end

            local node = uiLocales
            for idx = 1, #keys - 1 do
                node[keys[idx]] = node[keys[idx]] or {}
                node = node[keys[idx]]
            end
            node[keys[#keys]] = value
        end
    end

    cb(uiLocales)
end

ui.registerCb("uiLoaded", function()
    ui.loaded = true

    initLocales(function(locales)
        local initData = {
            locale = locales,
            theme = config.theme,
        }

        TriggerEvent(resName .. ":client:onUiLoaded")
        ui.sendMsg("init", initData)
        _info("Ui has been loaded!")
    end)
end)


-- [CLEANUP] --

AddEventHandler("onResourceStop", function(resource)
    if resource == resName then ui.focus(false, false) end
end)
