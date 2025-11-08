local buttons = {}

local BTN_W, BTN_H = 13, 5
local PADDING_X, PADDING_Y = 2, 4
local GAP_X, GAP_Y = 3, 2

local function mainView(ctx)
    return {
        init = function()
            buttons = {}
            local W, H = ctx.os.size()
            local x, y = PADDING_X, PADDING_Y

            for _, id in ipairs(ctx.os.list()) do
                if id ~= "home" then
                    local app = ctx.os.get(id)
                    local label = app.name or id
                    local btnId = "home_btn_" .. id

                    ctx.libs().button.create({
                        name = btnId,
                        app = "home",
                        view = "page",
                        x = x,
                        y = y,
                        w = BTN_W,
                        h = BTN_H,
                        colorOn = colors.cyan,
                        textOn = label,
                        textX = x + math.floor(BTN_W / 2) - math.floor(#label / 2),
                        textY = y + 2,
                    })

                    table.insert(buttons, { id = id, btnId = btnId })

                    x = x + BTN_W + GAP_X
                    if x + BTN_W > W then
                        x = PADDING_X
                        y = y + BTN_H + GAP_Y
                    end
                end
            end
        end,

        draw = function(mon)
            for _, b in ipairs(buttons) do
                ctx.libs().button.draw(b.btnId, mon)
            end
        end,

        touch = function(x, y)
            for _, b in ipairs(buttons) do
                if ctx.libs().button.isWithinBoundingBox(x, y, b.btnId) then
                    ctx.os.navigate(b.id)
                    return
                end
            end
        end
    }
end

local views = {
    root = mainView
}

return {
    id = "home",
    name = "Home",
    protocol = "home",
    receive = function(ctx, sender, message) end,
    views = views,
    create = function(ctx)
        for k, v in pairs(views) do
            local view = v(ctx)
            if view and view.init then
                view.init()
            end
        end
    end,
    resume = function(ctx) end,
    suspend = function(ctx) end,
    destroy = function(ctx) end,
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
