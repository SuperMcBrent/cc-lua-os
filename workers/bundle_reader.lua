peripheral.find("modem", rednet.open)

local BUNDLED_SIDE = "back"

local bundledColors = {
    colors.white,     -- 1
    colors.orange,    -- 2
    colors.magenta,   -- 4
    colors.lightBlue, -- 8
    colors.yellow,    -- 16
    colors.lime,      -- 32
    colors.pink,      -- 64
    colors.gray,      -- 128
    colors.lightGray, -- 256
    colors.cyan,      -- 512
    colors.purple,    -- 1024
    colors.blue,      -- 2048
    colors.brown,     -- 4096
    colors.green,     -- 8192
    colors.red,       -- 16384
    colors.black      -- 32768
}

local function getRedstoneSignalData()
    local channels = {}

    for _, color in ipairs(bundledColors) do
        channels[color] = rs.testBundledInput(BUNDLED_SIDE, color)
    end

    return { channels = channels }
end

local function HandleRequest(sender, message, protocol)
    print("Handling: " .. tostring(message))
    if message == "provideBundleSignals" then
        local data = getRedstoneSignalData()
        rednet.send(sender, data, protocol)
    end
end

local function requestListener()
    while true do
        local sender, message, protocol = rednet.receive()
        if type(message) == "table" and protocol == "batchedRequests" then
            print("Received batch of " .. #message .. " requests")
            for _, req in ipairs(message) do
                HandleRequest(sender, req.message, req.protocol)
            end
        else
            HandleRequest(sender, message, protocol)
        end
    end
end

local function bundleMonitor()
    while true do
        sleep(0.5)
    end
end

parallel.waitForAll(bundleMonitor, requestListener)
