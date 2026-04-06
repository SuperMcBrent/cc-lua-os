local super_tank_side = "right"
local super_tank = peripheral.wrap(super_tank_side)


function HandleRequest(sender, message, protocol)
    print("Handling: " .. tostring(message))
    if message == "provideFuelCount" then
        local fueldata = super_tank.tanks()
        rednet.send(sender, fueldata, protocol)
    end
end

function RequestListener()
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

parallel.waitForAll(
    function()
        while true do
            RequestListener()
        end
    end
)
