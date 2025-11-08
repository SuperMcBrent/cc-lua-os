local DEVICE_NAME = "All The Mods 10"
local CONTROLLER_SIDE = "monitor_0"
local APPS_DIR = "apps"
local LIBS_DIR = "libs"
local TICK_SEC = 0.2

local mon = peripheral.wrap(CONTROLLER_SIDE)
if not mon then error("No monitor on " .. CONTROLLER_SIDE) end
mon.setTextScale(0.5)

local W, H = mon.getSize()
local apps = {}
local libs = {}
local order = {}
local history = {}
local needRedraw = true
local jobQueue = {}
local requestQueue = {}
local designLines = false

local ctx = {
    controller = mon,
    width = W,
    height = H,
    os = {
        submitJob = function(jobFunc, callback) submitJob(jobFunc, callback) end,
        navigate = function(id, view) gotoView(id, view) end,
        replace = function(id, view) replaceView(id, view) end,
        home = function() goHome() end,
        back = function() goBack() end,
        list = function() return order end,
        get = function(id) return apps[id] end,
        redraw = function() needRedraw = true end,
        size = function() return W, H end,
        transmit = function(message, protocol) rednetTransmit(message, protocol) end,
        peripherals = function() return getCustomPeripherals() end
    },
    libs = function() return libs end,
    deviceName = DEVICE_NAME,
}

function getCustomPeripherals()
    local mon2 = peripheral.wrap("monitor_1")
    local me_bridge = peripheral.wrap("me_bridge_0")
    return { monitor_2 = mon2, me_bridge = me_bridge }
end

local function setSize()
    W, H = mon.getSize()
    ctx.width, ctx.height = W, H
    needRedraw = true
end

local function push(entry) table.insert(history, entry) end
local function pop()
    local n = #history
    if n > 0 then
        local e = history[n]
        history[n] = nil
        return e
    end
end
local function peek() return history[#history] end

local function drawSystemTray()
    libs.draw.drawLine(1, 1, W, 2, colors.gray, mon)

    libs.button.draw("homeButton", mon)
    libs.button.draw("backButton", mon)
    libs.button.draw("designUtilityButton", mon)

    libs.draw.putTime(math.floor(W / 2) - 1, 1, mon, true, colors.gray)
    local cur = peek()
    if cur then
        local app = apps[cur.app]
        if app and app.name then
            local x = math.floor((W - #app.name) / 2)
            libs.draw.drawTitle(1 + x, 2, app.name, colors.white, colors.gray, mon)
        end
    end
end

local function handleSystemTrayTouch(x, y)
    if libs.button.isWithinBoundingBox(x, y, "homeButton") then
        ctx.os.home()
        return true
    end

    if libs.button.isWithinBoundingBox(x, y, "backButton") then
        ctx.os.back()
        return true
    end

    if libs.button.isWithinBoundingBox(x, y, "designUtilityButton") then
        designLines = not designLines
        return true
    end

    return false
end

local function drawLines()
    local w, h = ctx.width, ctx.height
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.gray)

    for k = 1, h do
        for l = 1, w do
            if l % 5 == 0 and k % 5 == 0 then
                mon.setCursorPos(l, k)
                mon.write("+")
            elseif l % 5 == 0 then
                mon.setCursorPos(l, k)
                mon.write("|")
            elseif k % 5 == 0 then
                mon.setCursorPos(l, k)
                mon.write("-")
            end
        end
    end

    mon.setTextColor(colors.white)
    for l = 5, w, 5 do
        mon.setCursorPos(l, 1)
        mon.write(tostring(l))
    end
    for k = 5, h, 5 do
        mon.setCursorPos(1, k)
        mon.write(tostring(k))
    end
end

local function loadSystem()
    libs.button.create({
        app = "main",
        view = "home",
        name = "homeButton1",
        x = 1,
        y = 1,
        w = 5,
        h = 1,
        colorOn = colors.lime,
        textOn = "/^\\",
        textX = 2,
        textY = 1,
        composite = "homeButton"
    })

    libs.button.create({
        app = "main",
        view = "home",
        name = "homeButton2",
        x = 1,
        y = 2,
        w = 5,
        h = 1,
        colorOn = colors.lime,
        textOn = "|#|",
        textX = 2,
        textY = 2,
        composite = "homeButton"
    })

    libs.button.create({
        app = "main",
        view = "home",
        name = "backButton1",
        x = W - 4,
        y = 1,
        w = 5,
        h = 1,
        colorOn = colors.red,
        colorOff = colors.lightGray,
        state = true,
        textOn = "/__",
        textOff = "",
        textX = W - 3,
        textY = 1,
        composite = "backButton"
    })

    libs.button.create({
        app = "main",
        view = "home",
        name = "backButton2",
        x = W - 4,
        y = 2,
        w = 5,
        h = 1,
        colorOn = colors.red,
        colorOff = colors.lightGray,
        state = true,
        textOn = "\\  ",
        textOff = "",
        textX = W - 3,
        textY = 2,
        composite = "backButton"
    })

    libs.button.create({
        app = "main",
        view = "home",
        name = "designUtilityButton",
        x = 6,
        y = 1,
        w = 5,
        h = 1,
        colorOn = colors.cyan,
        textOn = "Lines",
        textX = 6,
        textY = 1
    })
end

local function loadApps()
    if not fs.exists(APPS_DIR) then fs.makeDir(APPS_DIR) end
    local list = fs.list(APPS_DIR)

    for _, f in ipairs(list) do
        if f:find("^app_") then
            local path = fs.combine(APPS_DIR, f)
            local chunk, err = loadfile(path)
            if chunk then
                local ok, mod = pcall(chunk)
                if ok and type(mod) == "table" and mod.id then
                    print("Load success:", mod.id)
                    apps[mod.id] = mod
                    table.insert(order, mod.id)
                else
                    print("Load fail:", path, mod)
                end
            else
                print("Compile fail:", path, err)
            end
        end
    end

    for _, id in ipairs(order) do
        local app = apps[id]
        if app.create then
            local ok, res = pcall(app.create, ctx)
            if not ok then
                print("Create error:", res)
            end
        end
    end
end

local function loadLibs()
    if not fs.exists(LIBS_DIR) then fs.makeDir(LIBS_DIR) end
    local list = fs.list(LIBS_DIR)
    libs = {}

    for _, f in ipairs(list) do
        if f:find("^lib_") then
            local path = fs.combine(LIBS_DIR, f)
            local chunk, err = loadfile(path)
            if not chunk then
                print("Lib compile fail:", path, err)
                goto continue
            end
            local ok, mod = pcall(chunk)
            if ok and type(mod) == "table" and mod.alias then
                libs[mod.alias] = mod
                print("Lib load success:", mod.alias)
            else
                print("Lib load fail:", path, mod)
            end
        end
        ::continue::
    end

    local function required_aliases(lib)
        local list = {}
        if type(lib.dependencies) == "table" then
            local i = 1
            while lib.dependencies[i] do
                list[#list + 1] = lib.dependencies[i]
                i = i + 1
            end
            for k, v in pairs(lib.dependencies) do
                if type(k) == "string" and v then
                    list[#list + 1] = k
                end
            end
        end
        return list
    end

    local resolving, resolved = {}, {}
    local function resolve(lib, stack)
        if resolved[lib.alias] then return end
        stack = stack or {}
        if resolving[lib.alias] then
            stack[#stack + 1] = lib.alias
            error("Circular dependency: " .. table.concat(stack, " -> "))
        end
        resolving[lib.alias] = true
        stack[#stack + 1] = lib.alias

        local depRefs = {}
        for _, depAlias in ipairs(required_aliases(lib)) do
            local dep = libs[depAlias]
            if not dep then
                error("Missing dependency '" .. depAlias .. "' required by '" .. lib.alias .. "'")
            end
            resolve(dep, stack)
            depRefs[depAlias] = dep
        end

        if next(depRefs) ~= nil then
            if type(lib.init) == "function" then
                lib.init(depRefs)
            else
                error("Library '" .. lib.alias .. "' declares dependencies but has no init()")
            end
        end

        resolving[lib.alias] = nil
        stack[#stack] = nil
        resolved[lib.alias] = true
    end

    for _, lib in pairs(libs) do resolve(lib) end
end

local function appTransition(prevEntry, nextEntry)
    local prevId = prevEntry and prevEntry.app or nil
    local nextId = nextEntry and nextEntry.app or nil
    if prevId == nextId then return end

    if prevId and apps[prevId] and apps[prevId].suspend then
        print("Suspending app:", prevId)
        local ok, res = pcall(apps[prevId].suspend, ctx)
        if not ok then
            print("Suspend error:", res)
        end
    end

    if nextId and apps[nextId] and apps[nextId].resume then
        print("Resuming app:", nextId)
        local ok, res = pcall(apps[nextId].resume, ctx)
        if not ok then
            print("Resume error:", res)
        end
    end
end

function gotoView(appId, viewId)
    if not apps[appId] then error("App not found: " .. tostring(appId)) end
    local prev = peek()
    local newEntry = { app = appId, view = viewId or "root" }
    push(newEntry)
    appTransition(prev, newEntry)

    mon.setBackgroundColor(colors.black)
    mon.clear()
    setSize()
    needRedraw = true
end

function replaceView(appId, viewId)
    if not apps[appId] then error("App not found: " .. tostring(appId)) end
    local prev = peek()
    local newEntry = { app = appId, view = viewId or "root" }
    history[#history] = newEntry
    appTransition(prev, newEntry)

    mon.setBackgroundColor(colors.black)
    mon.clear()
    setSize()
    needRedraw = true
end

function goHome()
    -- fucks with transitions, don't use history here
    -- local prev = peek()
    -- history = {}
    -- if prev then
    --     history[1] = prev
    -- end
    gotoView("home", "root")
end

function goBack()
    local oldTop = pop()
    local newTop = peek()
    if not newTop then
        -- home push {home,root}
        ctx.os.home()
        return
    end

    appTransition(oldTop, newTop)

    mon.setBackgroundColor(colors.black)
    mon.clear()
    setSize()
    needRedraw = true
end

local function drawFrame()
    drawSystemTray()
    local cur = peek()
    if cur and apps[cur.app] and apps[cur.app].draw then
        local ok, res = pcall(apps[cur.app].draw, ctx, mon, cur.view)
        if not ok then
            print("Draw error:", res)
        end
    end
    if designLines then
        drawLines()
    end
    needRedraw = false
end

local function waitTouch()
    local ev, side, x, y = os.pullEvent("monitor_touch")
    if side == CONTROLLER_SIDE then
        if not handleSystemTrayTouch(x, y) then
            local cur = peek()
            if cur and apps[cur.app] and apps[cur.app].touch then
                local ok, res = pcall(apps[cur.app].touch, ctx, x, y, cur.view)
                if not ok then
                    print("Touch error:", res)
                end
            end
        end
    end
end

local function waitTick()
    local t = os.startTimer(TICK_SEC)
    while true do
        local ev, id = os.pullEvent()
        if ev == "monitor_resize" then
            setSize()
            needRedraw = true
            return
        elseif ev == "timer" and id == t then
            for _, app in pairs(apps) do
                if app.update then
                    local ok, res = pcall(app.update, ctx, TICK_SEC)
                    if not ok then
                        print("Update error:", res)
                    end
                end
            end
            return
        end
    end
end

local function rednetLoop()
    while true do
        local sender, message, protocol = rednet.receive()

        if protocol == "system" then
            goto continue
        end

        for _, app in pairs(apps) do
            if app.protocol == protocol and app.receive then
                local ok, res = pcall(app.receive, ctx, sender, message)
                if not ok then
                    print("Receive error:", res)
                end
            end
        end

        ::continue::
    end
end

function rednetTransmit(message, protocol)
    if not message or not protocol then
        error("Invalid rednet transmit parameters")
    end
    table.insert(requestQueue, { message = message, protocol = protocol })
    print(os.time() .. ": Queued M: " .. message .. ", P: " .. protocol)
end

function transmitRequests()
    if #requestQueue == 0 then
        return
    end

    rednet.broadcast(requestQueue, "batchedRequests")
    print(os.time() .. ": Broadcasted " .. #requestQueue .. " requests")

    requestQueue = {}
end

function submitJob(jobFunc, callback)
    table.insert(jobQueue, { job = jobFunc, callback = callback })
end

local function processingLoop()
    while true do
        if #jobQueue > 0 then
            local task = table.remove(jobQueue, 1)

            local ok, err = pcall(task.job, function(...)
                if task.callback then
                    local ok2, err2 = pcall(task.callback, ...)
                    if not ok2 then
                        print("Job callback error:", err2)
                    end
                end
            end)

            if not ok then
                print("Job execution error:", err)
            end
        else
            os.sleep(0.05)
        end
    end
end

peripheral.find("modem", rednet.open)
loadLibs()
loadSystem()
loadApps()
if not apps["home"] then error("Missing home app with id='home'") end
ctx.os.home()

local function mainLoop()
    while true do
        if needRedraw then
            mon.clear()
            drawFrame()
        end
        transmitRequests();
        parallel.waitForAny(waitTouch, waitTick)
        needRedraw = true
    end
end

parallel.waitForAll(mainLoop, rednetLoop, processingLoop)

-- todos
-- dynamic peripherals
-- widgets
-- persistent state
-- preferred app order
