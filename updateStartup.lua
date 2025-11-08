local GITHUB_USER = "SuperMcBrent"
local GITHUB_REPO = "cc-lua-os"
local GITHUB_BRANCH = "main"
local BASE_URL = "https://raw.githubusercontent.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH
local STARTUP_URL = BASE_URL .. "/startup.lua"
local STARTUP_FILE = "startup.lua"
local BACKUP_FILE = STARTUP_FILE .. ".bak"

print("Fetching latest startup.lua...")

local function httpGetNoCache(url)
    local full = url .. "?t=" .. os.epoch("utc")
    local ok, res = pcall(http.get, full)
    if not ok or not res then return nil end
    local data = res.readAll()
    res.close()
    return data
end

local data = httpGetNoCache(STARTUP_URL)
if not data or #data == 0 then
    print("Failed to download startup.lua (empty or unreachable).")
    return
end

if fs.exists(BACKUP_FILE) then
    fs.delete(BACKUP_FILE)
end

if fs.exists(STARTUP_FILE) then
    fs.move(STARTUP_FILE, BACKUP_FILE)
    print("Old startup.lua backed up as startup.lua.bak")
end

local f = fs.open(STARTUP_FILE, "w")
f.write(data)
f.close()

print("startup.lua updated successfully!")
print("Rebooting in 2 seconds...")
sleep(2)
os.reboot()
