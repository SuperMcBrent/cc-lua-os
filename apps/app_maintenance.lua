local applicationName = "maintenance"

local BTN_W = 17
local BTN_H = 7
local H_SPACING = 3
local V_SPACING = 2

local alarmTimer = 0
local alarmRed = false

local buttonDefs = {
    { id = "testbutton_1",  name = " Pyrolyse \nBlink Test", color = colors.green, alarm = true,  gridX = 1, gridY = 1 },
    { id = "testbutton_2",  name = "Button 2",               color = colors.green, alarm = false, gridX = 2, gridY = 1 },
    { id = "testbutton_3",  name = "Button 3",               color = colors.green, alarm = false, gridX = 3, gridY = 1 },
    { id = "testbutton_4",  name = "Button 4",               color = colors.green, alarm = false, gridX = 4, gridY = 1 },
    { id = "testbutton_5",  name = "Button 5",               color = colors.green, alarm = false, gridX = 1, gridY = 2 },
    { id = "testbutton_6",  name = "Button 6",               color = colors.green, alarm = false, gridX = 2, gridY = 2 },
    { id = "testbutton_7",  name = "Button 7",               color = colors.green, alarm = false, gridX = 3, gridY = 2 },
    { id = "testbutton_8",  name = "Button 8",               color = colors.green, alarm = false, gridX = 4, gridY = 2 },
    { id = "testbutton_9",  name = "Button 9",               color = colors.green, alarm = false, gridX = 1, gridY = 3 },
    { id = "testbutton_10", name = "Button 10",              color = colors.green, alarm = false, gridX = 2, gridY = 3 },
    { id = "testbutton_11", name = "Button 11",              color = colors.green, alarm = false, gridX = 3, gridY = 3 },
    { id = "testbutton_12", name = "Button 12",              color = colors.green, alarm = false, gridX = 4, gridY = 3 },
    { id = "testbutton_13", name = "Button 13",              color = colors.green, alarm = false, gridX = 1, gridY = 4 },
    { id = "testbutton_14", name = "Button 14",              color = colors.green, alarm = false, gridX = 2, gridY = 4 },
    { id = "testbutton_15", name = "Button 15",              color = colors.green, alarm = false, gridX = 3, gridY = 4 },
    { id = "testbutton_16", name = "Button 16",              color = colors.green, alarm = false, gridX = 4, gridY = 4 }
}

local function getButtonX(gridX)
    return 2 + (gridX - 1) * (BTN_W + H_SPACING)
end

local function getButtonY(gridY)
    return 4 + (gridY - 1) * (BTN_H + V_SPACING)
end

local function updateAlarmButtons(ctx, dt)
    alarmTimer = alarmTimer + dt

    if alarmTimer >= 1 then
        alarmTimer = alarmTimer - 1
        alarmRed = not alarmRed
    end

    for _, btn in ipairs(buttonDefs) do
        local targetColor = colors.green

        if btn.alarm then
            targetColor = alarmRed and colors.red or colors.orange
        end

        ctx.libs().button.update(btn.id, { colorOn = targetColor })
    end
end

local function mainView(ctx)
    local view = "view_main"

    return {
        init = function()
            for _, btn in ipairs(buttonDefs) do
                local x = getButtonX(btn.gridX)
                local y = getButtonY(btn.gridY)
                local textX = x + math.floor((BTN_W - string.len(btn.name)) / 2)
                local textY = y + math.floor(BTN_H / 2)

                ctx.libs().button.create({
                    app = applicationName,
                    view = view,
                    name = btn.id,
                    x = x,
                    y = y,
                    w = BTN_W,
                    h = BTN_H,
                    colorOn = btn.color,
                    textOn = btn.name,
                    textX = textX,
                    textY = textY
                })
            end
        end,

        draw = function(mon)
            for _, btn in ipairs(buttonDefs) do
                ctx.libs().button.draw(btn.id, mon)
            end
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
    update = function(ctx, dt)
        updateAlarmButtons(ctx, dt)
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
