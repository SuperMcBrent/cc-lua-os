local restartBtnId = "settings_restart"
local yesBtnId = "confirm_yes"
local noBtnId = "confirm_no"

local applicationName = "settings"
local rootViewName = "root"
local confirmViewName = "confirm"

local function mainView(ctx)
    return {
        init = function()
            local W, H = ctx.os.size()
            local btnW, btnH = 13, 3
            local x = math.floor((W - btnW) / 2)
            local y = math.floor(H / 2)

            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = restartBtnId,
                x = x,
                y = y,
                w = btnW,
                h = btnH,
                colorOn = colors.red,
                colorOff = colors.gray,
                state = true,
                textOn = "Restart",
                textOff = "",
                textX = x + 3,
                textY = y + 1,
                header = ""
            })
        end,

        draw = function(mon)
            ctx.libs().button.draw(restartBtnId, mon)
        end,

        touch = function(x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, restartBtnId) then
                ctx.os.navigate("settings", "confirm")
            end
        end
    }
end

local function confirmView(ctx)
    return {
        init = function()
            local W, H = ctx.os.size()
            local btnYesX = math.floor(W / 2) - 10
            local btnNoX = math.floor(W / 2) + 3
            local btnY = math.floor(H / 2) + 2

            ctx.libs().button.create({
                app = applicationName,
                view = confirmViewName,
                name = yesBtnId,
                x = btnYesX,
                y = btnY,
                w = 8,
                h = 3,
                colorOn = colors.lime,
                colorOff = colors.gray,
                state = true,
                textOn = "Yes",
                textX = btnYesX + 1,
                textY = btnY + 1
            })

            ctx.libs().button.create({
                app = applicationName,
                view = confirmViewName,
                name = noBtnId,
                x = btnNoX,
                y = btnY,
                w = 8,
                h = 3,
                colorOn = colors.red,
                colorOff = colors.gray,
                state = true,
                textOn = "No",
                textX = btnNoX + 1,
                textY = btnY + 1
            })
        end,

        draw = function(mon)
            local W, H = ctx.os.size()
            ctx.libs().draw.drawTitle(1 + math.floor(W / 2) - 7, math.floor(H / 2) - 2, "Are you sure?", colors.white,
                colors.gray, mon)
            ctx.libs().button.draw(yesBtnId, mon)
            ctx.libs().button.draw(noBtnId, mon)
        end,

        touch = function(x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, yesBtnId) then
                os.reboot()
            elseif ctx.libs().button.isWithinBoundingBox(x, y, noBtnId) then
                ctx.os.back()
            end
        end
    }
end

local views = {
    root = mainView,
    confirm = confirmView
}

return {
    id = "settings",
    name = "Settings",
    protocol = "settings",

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
