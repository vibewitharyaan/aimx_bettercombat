local Config = {
    RepoURL   = "https://raw.githubusercontent.com/3RRORCodes/versionCheck/master/resources.json",
    UpdateURL = "https://portal.cfx.re/assets/granted-assets",
    Discord   = "discord.gg/Eux7CJEQN2",

    Text = {
        Outdated = "An update is available. Updating is recommended for stability and fixes.",
        Latest   = nil,
        Dev      = "You are running a developer version ahead of the public release. Unexpected behaviour may occur.",
        Footer   = "^5Support & enquiries → ^3%s^7"
    }
}

local function parseVersion(version)
    local t = {}
    for n in tostring(version):gmatch("%d+") do
        t[#t + 1] = tonumber(n)
    end
    return t
end

local function compareVersions(localV, remoteV)
    for i = 1, math.max(#localV, #remoteV) do
        local l = localV[i] or 0
        local r = remoteV[i] or 0
        if l < r then return 1 end
        if l > r then return 2 end
    end
    return 0
end

local function printBlock(resource, current, latest, status, message, notes)
    print("^4──────────────────────────────────────────────^7")
    print(string.format("^3[%s]^7  Version Check", resource))
    print("^4──────────────────────────────────────────────^7")

    local statusColor = status == "OUTDATED" and "^1"
        or status == "UP TO DATE" and "^2"
        or "^3"

    print(string.format(
        "^7Current : %s%s^7   |   ^7Latest : ^2%s^7   |   Status : %s%s^7",
        statusColor, current, latest, statusColor, status
    ))

    if message then
        print("\n^7" .. message)
    end

    if notes then
        print("^7Notes: " .. notes)
    end

    print("\n" .. string.format(Config.Text.Footer, Config.Discord))
    print("^4──────────────────────────────────────────────^7")
end

local resourceName = GetResourceMetadata(GetCurrentResourceName(), "name", 0)
    or GetCurrentResourceName()

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
if not currentVersion then return end

PerformHttpRequest(Config.RepoURL .. "?t=" .. os.time(), function(code, body)
    if code ~= 200 or not body then return end

    local ok, data = pcall(json.decode, body)
    if not ok or not data or not data[resourceName] then
        print("^1[ERROR]^7 Version check failed for " .. resourceName)
        return
    end

    local remoteVersion = data[resourceName].version
    local notes         = data[resourceName].notes

    local state = compareVersions(
        parseVersion(currentVersion),
        parseVersion(remoteVersion)
    )

    if state == 1 then
        printBlock(
            resourceName,
            currentVersion,
            remoteVersion,
            "OUTDATED",
            Config.Text.Outdated .. "\nDownload → ^4" .. Config.UpdateURL .. "^7",
            notes
        )
    elseif state == 2 then
        printBlock(
            resourceName,
            currentVersion,
            remoteVersion,
            "DEVELOPER BUILD",
            Config.Text.Dev,
            nil
        )
    else
        printBlock(
            resourceName,
            currentVersion,
            remoteVersion,
            "UP TO DATE",
            nil,
            nil
        )
    end
end, "GET")
