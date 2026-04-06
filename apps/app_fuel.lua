local applicationName = "fuel"
local protocol = "fuel"

local fuel_amount = 0

local function mainView(ctx)
    local view = "view_main"

    return {
        init = function()

        end,

        draw = function(mon)
            ctx.libs().draw.drawTitle(5, 5, fuel_amount, colors.white, colors.black, mon)
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
        local notifications = {}
        return notifications
    end,

    receive = function(ctx, sender, message)
        fuel_amount = (message and message[1] and message[1].amount) or 0
    end,

    create = function(ctx)
        for k, v in pairs(views) do
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
        ctx.os.transmit("provideFuelCount", protocol)
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
