local applicationName = "settings"

local function mainView(ctx)
    local rootViewName = "root"

    local rootButtons = {
        { id = "settings_restart",         name = "Restart",     color = colors.red, gridX = 1, gridY = 1 },
        { id = "settings_delete_manifest", name = "rm manifest", color = colors.red, gridX = 2, gridY = 1 }
    }

    local ROOT_BTN_W = 13
    local ROOT_BTN_H = 5
    local ROOT_H_SPACING = 3
    local ROOT_V_SPACING = 2

    local function getRootButtonX(gridX)
        return 2 + (gridX - 1) * (ROOT_BTN_W + ROOT_H_SPACING)
    end

    local function getRootButtonY(gridY)
        return 4 + (gridY - 1) * (ROOT_BTN_H + ROOT_V_SPACING)
    end

    return {
        init = function()
            for _, btn in ipairs(rootButtons) do
                local x = getRootButtonX(btn.gridX)
                local y = getRootButtonY(btn.gridY)
                local textX = x + math.floor((ROOT_BTN_W - string.len(btn.name)) / 2)
                local textY = y + math.floor(ROOT_BTN_H / 2)

                ctx.libs().button.create({
                    app = applicationName,
                    view = rootViewName,
                    name = btn.id,
                    x = x,
                    y = y,
                    w = ROOT_BTN_W,
                    h = ROOT_BTN_H,
                    colorOn = btn.color,
                    state = true,
                    textOn = btn.name,
                    textX = textX,
                    textY = textY
                })
            end
        end,

        draw = function(mon)
            for _, btn in ipairs(rootButtons) do
                ctx.libs().button.draw(btn.id, mon)
            end
        end,

        touch = function(x, y)
            for _, btn in ipairs(rootButtons) do
                if ctx.libs().button.isWithinBoundingBox(x, y, btn.id) then
                    if btn.id == "settings_restart" then
                        ctx.os.navigate("settings", "confirm")
                    end

                    if btn.id == "settings_delete_manifest" then
                        if fs.exists("manifest_local") then
                            fs.delete("manifest_local")
                            print("manifest deleted")
                        end
                    end
                end
            end
        end
    }
end

local function confirmView(ctx)
    local confirmViewName = "confirm"

    local W, H = ctx.os.size()
    local btnYesX = math.floor(W / 2) - 10
    local btnNoX = math.floor(W / 2) + 3
    local btnY = math.floor(H / 2) + 2

    local confirmButtons = {
        { id = "confirm_yes", name = "Yes", colorOn = colors.lime, colorOff = colors.gray, x = btnYesX, y = btnY, w = 8, h = 3 },
        { id = "confirm_no",  name = "No",  colorOn = colors.red,  colorOff = colors.gray, x = btnNoX,  y = btnY, w = 8, h = 3 }
    }

    return {
        init = function()
            for _, btn in ipairs(confirmButtons) do
                ctx.libs().button.create({
                    app = applicationName,
                    view = confirmViewName,
                    name = btn.id,
                    x = btn.x,
                    y = btn.y,
                    w = btn.w,
                    h = btn.h,
                    colorOn = btn.colorOn,
                    colorOff = btn.colorOff,
                    state = true,
                    textOn = btn.name,
                    textX = btn.x + 1,
                    textY = btn.y + 1
                })
            end
        end,

        draw = function(mon)
            local W, H = ctx.os.size()
            ctx.libs().draw.drawTitle(1 + math.floor(W / 2) - 7, math.floor(H / 2) - 2, "Are you sure?", colors.white,
                colors.gray, mon)
            ctx.libs().button.draw("confirm_yes", mon)
            ctx.libs().button.draw("confirm_no", mon)
        end,

        touch = function(x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, "confirm_yes") then
                os.reboot()
            elseif ctx.libs().button.isWithinBoundingBox(x, y, "confirm_no") then
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
