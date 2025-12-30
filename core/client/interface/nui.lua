ui = {}

local NUI_SEND_DEBUG_FILTER = {
    ["init"] = true,
}

local NUI_DEBUG_FILTER = {
    ["uiLoaded"] = true,
}

function ui.sendMsg(action, data)
    local message = { action = action }

    if data ~= nil then
        message.data = data
    end

    SendNUIMessage(message)

    if not NUI_SEND_DEBUG_FILTER[tostring(action)] then
        _debug("[NUI Message] Action: %s | Data: %s", action, json.encode(data))
    end
end

function ui.focus(focus, cursor)
    cursor = cursor == nil and focus or cursor
    SetNuiFocus(focus, cursor)
end

function ui.registerCb(name, handler)
    RegisterNUICallback(name, function(data, cb)
        local ok, result = pcall(handler, data)
        if not ok then
            _error("[NUI Callback] Failed: %s | Error: %s", name, tostring(result))
            cb({ ok = false, error = "Internal error" })
            return
        end

        if not NUI_DEBUG_FILTER[tostring(name)] then
            if result ~= nil then
                _debug("[NUI Callback] %s | Data: %s | Result: %s", name, json.encode(data), json.encode(result))
            else
                _debug("[NUI Callback] %s | Data: %s", name, json.encode(data))
            end
        end

        cb({ ok = true, data = result })
    end)
end

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

CreateThread(function()
    Wait(1000)
    ui.sendMsg("app:boot", {})
end)

AddEventHandler("onResourceStop", function(currentResource)
    if currentResource ~= resName then
        return
    end
    ui.focus(false, false)
end)
