local restartBtnId = "settings_restart"
local manifestBtnId = "settings_delete_manifest"
local yesBtnId = "confirm_yes"
local noBtnId = "confirm_no"

local applicationName = "settings"
local rootViewName = "root"
local confirmViewName = "confirm"

local function mainView(ctx)
    return {
        init = function()
            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = restartBtnId,
                x = 2,
                y = 4,
                w = 13,
                h = 5,
                colorOn = colors.red,
                state = true,
                textOn = "Restart",
                textX = 4,
                textY = 6
            })

            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = manifestBtnId,
                x = 17,
                y = 4,
                w = 13,
                h = 5,
                colorOn = colors.red,
                state = true,
                textOn = "rm manifest",
                textX = 18,
                textY = 6
            })
        end,

        draw = function(mon)
            ctx.libs().button.draw(restartBtnId, mon)
            ctx.libs().button.draw(manifestBtnId, mon)
        end,

        touch = function(x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, restartBtnId) then
                ctx.os.navigate("settings", "confirm")
            end

            if ctx.libs().button.isWithinBoundingBox(x, y, manifestBtnId) then
                if fs.exists("manifest_local.lua") then
                    fs.delete("manifest_local.lua")
                    print("manifest deleted")
                end
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
