local GITHUB_USER = "SuperMcBrent"
local GITHUB_REPO = "cc-lua-os"
local GITHUB_BRANCH = "main"
local BASE_URL = "https://raw.githubusercontent.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH
local MANIFEST_URL = BASE_URL .. "/manifest.lua"
local LOCAL_MANIFEST_FILE = "manifest_local"

local function DrawLine(x, y, len, size, color_bar, mon)
    for yy = y, y + size - 1 do
        mon.setBackgroundColor(color_bar); mon.setCursorPos(x, yy); mon.write(string.rep(" ", len))
    end
    mon.setBackgroundColor(colors.black)
end
local function DrawProg(x, y, len, size, minVal, maxVal, color_bar, color_bg, mon)
    DrawLine(x, y, len, size, color_bg, mon)
    local barSize = math.floor((minVal / maxVal) * len)
    DrawLine(x, y, barSize, size, color_bar, mon)
end
local function Empty(mon)
    mon.setBackgroundColor(colors.black); mon.clear(); mon.setCursorPos(1, 1)
end

local mon = peripheral.wrap("monitor_0") or term
mon.setTextScale(0.5)
local W, H = mon.getSize()
Empty(mon)
local footerTextY = H - 3
local progressBarY = H - 1
local progressBarX = 2
local progressBarW = W - 2

local logY = 1
local function log(msg, color)
    color = color or colors.white
    mon.setTextColor(color)
    mon.setCursorPos(2, logY)
    mon.write(msg)
    logY = logY + 1
    if logY >= footerTextY - 1 then
        mon.scroll(1); logY = footerTextY - 2
    end
    sleep(0.15)
end
local function drawFooter(progress, total)
    mon.setTextColor(colors.white)
    mon.setCursorPos(math.max(2, math.floor(W / 2 - 10)), footerTextY)
    mon.write("Loading... Please wait")
    DrawProg(progressBarX, progressBarY, progressBarW, 1, progress, total, colors.white, colors.gray, mon)
end

local function httpGet(url)
    local full = url .. "?t=" .. os.epoch("utc")
    local ok, res = pcall(http.get, full)
    if not ok or not res then return nil end
    local d = res.readAll(); res.close(); return d
end

local function loadRemoteManifest()
    log("Fetching manifest...")
    local data = httpGet(MANIFEST_URL)
    if not data then
        log("FAILED to fetch manifest", colors.red)
        return nil
    end
    local chunk = load(data, "manifest", "t", {})
    local ok, manifest = pcall(chunk)
    if not ok then
        log("Manifest parse error", colors.red)
        return nil
    end
    log("Manifest loaded", colors.green)
    return manifest
end

local function loadLocalManifest()
    if not fs.exists(LOCAL_MANIFEST_FILE) then return {} end
    local f = fs.open(LOCAL_MANIFEST_FILE, "r")
    local t = textutils.unserialize(f.readAll())
    f.close()
    return t or {}
end
local function saveLocalManifest(tbl)
    local f = fs.open(LOCAL_MANIFEST_FILE, "w")
    f.write(textutils.serialize(tbl))
    f.close()
end

local function ensureDir(path)
    local parts = {}; for part in string.gmatch(path, "[^/]+") do table.insert(parts, part) end
    table.remove(parts, #parts)
    local dir = ""
    for _, p in ipairs(parts) do
        dir = dir .. p .. "/"; if not fs.exists(dir) then fs.makeDir(dir) end
    end
end
local function shortUrl(url) return url:match("/([^/]+/[^/]+)$") or url end
local function expandManifest(remote)
    local out = {}
    for key, val in pairs(remote) do
        if type(val) == "table" and val.version then
            table.insert(out, { dir = nil, name = key, entry = val })
        elseif type(val) == "table" then
            for name, entry in pairs(val) do
                table.insert(out, { dir = key, name = name, entry = entry })
            end
        end
    end
    return out
end

local function syncFiles(remote, local_)
    local success = true
    local files = expandManifest(remote)
    local total = #files
    local count = 0

    for _, fdata in ipairs(files) do
        count = count + 1
        local dir, name, entry = fdata.dir, fdata.name, fdata.entry
        local version = tostring(entry.version or "0")
        local enabled = entry._enabled ~= false
        local path = (dir and dir .. "/" .. name .. ".lua") or (name .. ".lua")

        if enabled then
            local_[dir or "_root"] = local_[dir or "_root"] or {}
            local localVersion = local_[dir or "_root"][name]
            if type(localVersion) == "table" then localVersion = "0" end
            localVersion = tostring(localVersion or "0")
            local exists = fs.exists(path)

            if localVersion ~= version then
                ensureDir(path)
                local url = BASE_URL .. "/" .. path
                log("Updating " .. path .. " (v" .. localVersion .. " > " .. version .. ")", colors.white)
                local data = httpGet(url)
                if not data then
                    log("  FAILED (" .. shortUrl(url) .. ")", colors.red)
                    success = false
                else
                    local f = fs.open(path, "w"); f.write(data); f.close()
                    local_[dir or "_root"][name] = version
                    log("  Downloaded new version (" .. version .. ")", colors.green)
                end
            else
                if exists then
                    log("Already present: " .. path .. " (v" .. version .. ")", colors.gray)
                else
                    log("Missing locally: " .. path .. " -> restoring", colors.yellow)
                    ensureDir(path)
                    local url = BASE_URL .. "/" .. path
                    local data = httpGet(url)
                    if data then
                        local f = fs.open(path, "w"); f.write(data); f.close()
                        local_[dir or "_root"][name] = version
                        log("  Restored existing version (" .. version .. ")", colors.green)
                    else
                        log("  FAILED (" .. shortUrl(url) .. ")", colors.red)
                        success = false
                    end
                end
            end
        else
            log("Skipping " .. path .. " (disabled)", colors.gray)
        end
        drawFooter(count, total)
        sleep(0.15)
    end
    return success
end

local ok = true
local remote = loadRemoteManifest(); if not remote then ok = false end
local local_ = loadLocalManifest()
if ok then ok = syncFiles(remote, local_) end
if ok then saveLocalManifest(local_) end

if ok then
    log("All files up to date.", colors.green)
    sleep(3)
    Empty(mon)
    shell.run("main")
else
    log(""); log("One or more downloads failed.", colors.red); log("Startup halted.", colors.red)
    sleep(4)
end
