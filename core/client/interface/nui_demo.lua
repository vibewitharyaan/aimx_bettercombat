ui.registerCb("demo:start", function(_)
    ui.focus(false)
    ui.sendMsg("demo:toggle", {
        show = false
    })
end)

local isVisble = false
RegisterCommand("demoui", function()
    isVisble = not isVisble

    ui.sendMsg("demo:toggle", {
        show = isVisble
    })

    ui.focus(isVisble)

    if isVisble then
        ui.sendMsg("demo:update_card", {
            brandName = "ERROR HUB",
            developerName = "3RROR",
        })
    end
end, false)
