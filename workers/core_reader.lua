local core = peripheral.wrap("draconic_rf_storage_3")
local inputdetector = peripheral.wrap("energy_detector_4")
local outputdetector = peripheral.wrap("energy_detector_3")
peripheral.find("modem", rednet.open)

local function getCoreTier(max)
    if max < 50000000 then
        return 1
    elseif max < 300000000 then
        return 2
    elseif max < 2000000000 then
        return 3
    elseif max < 10000000000 then
        return 4
    elseif max < 50000000000 then
        return 5
    elseif max < 400000000000 then
        return 6
    elseif max < 3000000000000 then
        return 7
    else
        return 8
    end
end

local function getCoreData()
    local now = core.getEnergyStored()
    local max = core.getMaxEnergyStored()
    local data = {
        now = now,
        max = max,
        rate = core.getTransferPerTick(),
        tier = getCoreTier(max),
        input = inputdetector.getTransferRate(),
        output = outputdetector.getTransferRate()
    }
    return data
end

local function HandleRequest(sender, message, protocol)
    print("Handling: " .. tostring(message))
    if message == "provideCoreData" then
        local data = getCoreData()
        print(os.time() .. ": " .. data.now .. " RF")
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

local function coreMonitor()
    while true do
        sleep(0.5)
    end
end

parallel.waitForAll(coreMonitor, requestListener)
