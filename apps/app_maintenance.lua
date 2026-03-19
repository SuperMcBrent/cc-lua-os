local APPID = "maintenance"

local function mainView(ctx)
    local view = "view_main"
    return {
        init = function()
            ctx.libs().button.create({
                app = APPID,
                view = view,
                name = "testbutton_1",
                x = 2,
                y = 4,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Pyrolyse",
                textX = 3,
                textY = 5
            })
        end,

        draw = function(mon)
            ctx.libs().button.draw("testbutton_1", mon)
        end,

        touch = function(x, y)

        end
    }
end

local views = {
    root = mainView,
}

return {
    id = APPID,
    name = "Maintenance",
    protocol = "maintenance",

    receive = function(ctx, sender, message) end,

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
    update = function(ctx, dt) end,

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
