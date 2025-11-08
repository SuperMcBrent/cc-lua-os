local protocol = "energystorage"
local active = false;

local PADDING_X, PADDING_Y = 3, 4

local lastMessage = nil

local function rootView(ctx)
    return {
        draw = function(ctx, mon)
            local x, y = PADDING_X, PADDING_Y
            local W, H = ctx.os.size()

            if not lastMessage then
                return
            end

            local percent = math.floor((lastMessage.now / lastMessage.max * 100) + 0.5)

            ctx.libs().draw.drawCircle(x + 2, y + 2, 32, colors.purple, true, mon)
            ctx.libs().draw.drawCircle(x + 2, y + 2, 32, ctx.libs().draw.rainbow(0.75), false, mon)
            ctx.libs().draw.drawNumber(x + 8 + (#tostring(percent) - 1) * 3, y + 10, percent, colors.white, 1, false, mon)

            ctx.libs().draw.drawTitle(x + 40, y + 2, "Draconic Energy Core Stats", colors.white, colors.black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 3, string.rep("-", 26), colors.white, colors.black, mon)

            ctx.libs().draw.drawTitle(x + 40, y + 5,
                "Now: (" .. formatNumber(lastMessage.now) .. ") " .. lastMessage.now .. " RF", colors.white, colors
                .black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 7,
                "Max: (" .. formatNumber(lastMessage.max) .. ") " .. lastMessage.max .. " RF", colors.white, colors
                .black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 9,
                "Change: (" .. formatNumber(lastMessage.rate) .. ") " .. lastMessage.rate .. " RF/t", colors.white,
                colors.black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 11, "Tier: " .. lastMessage.tier, colors.white, colors.black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 13,
                "Input: (" .. formatNumber(lastMessage.input) .. ") " .. lastMessage.input .. " RF/t", colors.white,
                colors.black, mon)
            ctx.libs().draw.drawTitle(x + 40, y + 15,
                "Output: (" .. formatNumber(lastMessage.output) .. ") " .. lastMessage.output .. " RF/t", colors.white,
                colors.black, mon)

            ctx.libs().draw.drawTitle(1, H - 6, string.rep("-", W), colors.white, colors.black, mon)

            ctx.libs().draw.drawTitle(2, H - 5, "0%", colors.white, colors.black, mon)
            ctx.libs().draw.drawTitle(W - 4, H - 5, "100%", colors.white, colors.black, mon)
            ctx.libs().draw.drawProg(2, H - 4, W - 2, 4, lastMessage.now, lastMessage.max, colors.lime, colors.gray, mon)
        end,
        touch = function(ctx, x, y) end
    }
end

--- TODO move to a better location
function formatNumber(n)
    local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
    local i = 1
    while n >= 1000 and i < #suffixes do
        n = n / 1000
        i = i + 1
    end
    if n >= 100 then
        return string.format("%.0f%s", n, suffixes[i])
    elseif n >= 10 then
        return string.format("%.1f%s", n, suffixes[i])
    else
        return string.format("%.2f%s", n, suffixes[i])
    end
end

local views = {
    root = rootView
}

return {
    id = "energystorage",
    name = "Core",
    protocol = protocol,
    receive = function(ctx, sender, message)
        ---print(textutils.serializeJSON(message))
        lastMessage = message
    end,
    create = function(ctx) end,
    destroy = function(ctx) end,
    resume = function(ctx)
        active = true;
    end,
    suspend = function(ctx)
        active = false;
    end,
    update = function(ctx, dt)
        if active then ctx.os.transmit("provideCoreData", protocol) end
    end,
    draw = function(ctx, mon, viewId)
        local v = views[viewId]
        if v and v(ctx).draw then v(ctx).draw(ctx, mon) end
    end,
    touch = function(ctx, x, y, viewId)
        local v = views[viewId]
        if v and v(ctx).touch then v(ctx).touch(ctx, x, y) end
    end
}
