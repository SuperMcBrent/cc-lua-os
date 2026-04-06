local applicationName = "fuel"
local protocol = "fuel"

local fuel_amount = 0
local last_fuel_amount = nil
local fuel_deltas = {}

local GRAPH_X = 5
local GRAPH_Y = 8
local GRAPH_WIDTH = 30
local GRAPH_HEIGHT = 11
local GRAPH_HALF_HEIGHT = math.floor(GRAPH_HEIGHT / 2)
local GRAPH_CENTER_Y = GRAPH_Y + GRAPH_HALF_HEIGHT

local SAMPLE_INTERVAL = 10
local sampleTimer = 0

local function pushDelta(delta)
    table.insert(fuel_deltas, delta)

    while #fuel_deltas > GRAPH_WIDTH do
        table.remove(fuel_deltas, 1)
    end
end

local function getMaxVisibleDelta()
    local maxDelta = 1

    for i = 1, #fuel_deltas do
        local absDelta = math.abs(fuel_deltas[i])
        if absDelta > maxDelta then
            maxDelta = absDelta
        end
    end

    return maxDelta
end

local function drawGraph(ctx, mon)
    local draw = ctx.libs().draw
    local maxDelta = getMaxVisibleDelta()

    draw.DrawLine(GRAPH_X, GRAPH_CENTER_Y, GRAPH_WIDTH, 1, colors.gray, mon)

    local startIndex = math.max(1, #fuel_deltas - GRAPH_WIDTH + 1)
    local visibleCount = #fuel_deltas - startIndex + 1

    for i = 1, visibleCount do
        local delta = fuel_deltas[startIndex + i - 1]
        local x = GRAPH_X + i - 1

        if delta ~= 0 then
            local scaledHeight = math.floor((math.abs(delta) / maxDelta) * GRAPH_HALF_HEIGHT + 0.5)
            if scaledHeight < 1 then
                scaledHeight = 1
            end

            if delta > 0 then
                draw.DrawLine(x, GRAPH_CENTER_Y - scaledHeight, 1, scaledHeight, colors.green, mon)
            else
                draw.DrawLine(x, GRAPH_CENTER_Y + 1, 1, scaledHeight, colors.red, mon)
            end
        end
    end
end

local function mainView(ctx)
    local view = "view_main"

    return {
        init = function()
        end,

        draw = function(mon)
            ctx.libs().draw.drawTitle(5, 2, "Fuel: " .. tostring(fuel_amount) .. " mB", colors.white, colors.black, mon)
            drawGraph(ctx, mon)
        end,

        touch = function(x, y)
        end
    }
end

local views = {
    root = mainView,
}

return {
    id = applicationName,
    name = "Fuel",
    protocol = protocol,

    notifications = function()
        return {}
    end,

    receive = function(ctx, sender, message)
        local newAmount = (message and message[1] and message[1].amount) or 0

        if last_fuel_amount ~= nil then
            local delta = newAmount - last_fuel_amount
            pushDelta(delta)
        end

        fuel_amount = newAmount
        last_fuel_amount = newAmount
    end,

    create = function(ctx)
        sampleTimer = SAMPLE_INTERVAL

        for _, v in pairs(views) do
            local view = v(ctx)
            if view and view.init then
                view.init()
            end
        end
    end,

    destroy = function(ctx) end,
    resume = function(ctx) end,
    suspend = function(ctx) end,

    update = function(ctx, dt)
        sampleTimer = sampleTimer + dt

        if sampleTimer >= SAMPLE_INTERVAL then
            sampleTimer = sampleTimer - SAMPLE_INTERVAL
            ctx.os.transmit("provideFuelCount", protocol)
        end
    end,

    draw = function(ctx, mon, viewId)
        local v = views[viewId]
        if v and v(ctx).draw then
            v(ctx).draw(mon)
        end
    end,

    touch = function(ctx, x, y, viewId)
        local v = views[viewId]
        if v and v(ctx).touch then
            v(ctx).touch(x, y)
        end
    end
}
