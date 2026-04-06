local applicationName = "fuel"
local protocol = "fuel"

local fuel_amount = 0
local last_fuel_amount = nil

local SAMPLE_INTERVAL = 5
local sampleTimer = 0
local appTime = 0

local TABLE_X = 5
local TABLE_Y = 5
local TABLE_ROWS = 20

local history = {}

local function pushHistory(delta, total, timestamp)
    table.insert(history, {
        time = timestamp,
        delta = delta,
        total = total
    })

    while #history > TABLE_ROWS do
        table.remove(history, 1)
    end
end

local function padRight(text, width)
    text = tostring(text or "")
    if #text >= width then
        return text:sub(1, width)
    end
    return text .. string.rep(" ", width - #text)
end

-- truncate to 3 decimals (no rounding)
local function trunc3(v)
    local sign = v < 0 and -1 or 1
    v = math.abs(v)
    local truncated = math.floor(v * 1000) / 1000
    return truncated * sign
end

local function formatNumber(v)
    local t = trunc3(v / 1000)
    return tostring(t)
end

local function formatDelta(delta)
    local t = trunc3(delta / 1000)
    if t > 0 then
        return "+" .. tostring(t)
    end
    return tostring(t)
end

local function drawTable(ctx, mon)
    local draw = ctx.libs().draw

    local col1w = 10
    local col2w = 10
    local col3w = 12

    -- header
    draw.drawTitle(
        TABLE_X,
        TABLE_Y,
        padRight("sec ago", col1w) .. padRight("delta", col2w) .. padRight("total", col3w),
        colors.white,
        colors.black,
        mon
    )

    local startRowY = TABLE_Y + 1
    local bottomRowY = startRowY + TABLE_ROWS - 1

    -- clear rows
    for i = 1, TABLE_ROWS do
        draw.drawTitle(
            TABLE_X,
            startRowY + i - 1,
            string.rep(" ", col1w + col2w + col3w),
            colors.white,
            colors.black,
            mon
        )
    end

    local visibleCount = math.min(#history, TABLE_ROWS)

    for i = 1, visibleCount do
        local entry = history[#history - visibleCount + i]
        local rowY = bottomRowY - visibleCount + i
        local secondsAgo = math.floor(appTime - entry.time)

        local col1 = padRight(secondsAgo, col1w)
        local col2 = padRight(formatDelta(entry.delta), col2w)
        local col3 = padRight(formatNumber(entry.total), col3w)

        local colorDelta = colors.white
        if entry.delta > 0 then
            colorDelta = colors.green
        elseif entry.delta < 0 then
            colorDelta = colors.red
        end

        -- draw each column separately
        draw.drawTitle(TABLE_X, rowY, col1, colors.white, colors.black, mon)
        draw.drawTitle(TABLE_X + col1w, rowY, col2, colorDelta, colors.black, mon)
        draw.drawTitle(TABLE_X + col1w + col2w, rowY, col3, colors.white, colors.black, mon)
    end
end

local function mainView(ctx)
    local view = "view_main"

    return {
        init = function()
        end,

        draw = function(mon)
            ctx.libs().draw.drawTitle(
                5,
                2,
                "Fuel: " .. formatNumber(fuel_amount),
                colors.white,
                colors.black,
                mon
            )

            drawTable(ctx, mon)
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
        local delta = 0

        if last_fuel_amount ~= nil then
            delta = newAmount - last_fuel_amount
        end

        fuel_amount = newAmount
        pushHistory(delta, newAmount, appTime)
        last_fuel_amount = newAmount
    end,

    create = function(ctx)
        sampleTimer = SAMPLE_INTERVAL
        appTime = 0
        history = {}
        last_fuel_amount = nil
        fuel_amount = 0

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
        appTime = appTime + dt
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
