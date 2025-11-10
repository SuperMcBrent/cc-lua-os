local WHITE_KEYS = { "C", "D", "E", "F", "G", "A", "B" }
local BLACK_KEYS = {
    { note = "C#", pos = 1 },
    { note = "D#", pos = 2 },
    { note = "F#", pos = 4 },
    { note = "G#", pos = 5 },
    { note = "A#", pos = 6 }
}

local WHITE_W, WHITE_H = 3, 6
local BLACK_W, BLACK_H = 3, 3
local SPACING = 1
local START_X, START_Y = 3, 4

local function mainView(ctx)
    return {
        init = function()
            local app = "music"
            local view = "root"
            local x = START_X
            local y = START_Y

            -- Create white keys
            for _, note in ipairs(WHITE_KEYS) do
                local id = "key_" .. note
                ctx.libs().button.create({
                    app = app,
                    view = view,
                    name = id,
                    x = x,
                    y = y,
                    w = WHITE_W,
                    h = WHITE_H,
                    colorOn = colors.white,
                    colorOff = colors.white,
                    state = false,
                    textOn = note,
                    textX = x + math.floor(WHITE_W / 2),
                    textY = y + math.floor(WHITE_H / 2)
                })
                x = x + WHITE_W + SPACING
            end

            -- Create black keys
            for _, b in ipairs(BLACK_KEYS) do
                local note = b.note
                local pos = b.pos
                local id = "key_" .. note

                local baseX = START_X + (pos - 1) * (WHITE_W + SPACING)
                local x = baseX + math.floor(WHITE_W / 2)
                local y = START_Y

                ctx.libs().button.create({
                    app = app,
                    view = view,
                    name = id,
                    x = x,
                    y = y,
                    w = BLACK_W,
                    h = BLACK_H,
                    colorOn = colors.gray,
                    colorOff = colors.gray,
                    state = false,
                    textOn = note,
                    textX = x + math.floor(BLACK_W / 2),
                    textY = y + 1
                })
            end
        end,

        draw = function(mon)
            local app = "music"
            local view = "root"
            for _, note in ipairs(WHITE_KEYS) do
                ctx.libs().button.draw("key_" .. note, mon)
            end
            for _, b in ipairs(BLACK_KEYS) do
                ctx.libs().button.draw("key_" .. b.note, mon)
            end
        end,

        touch = function(x, y)
            local mon = ctx.os.monitor()

            -- White keys
            for _, note in ipairs(WHITE_KEYS) do
                local id = "key_" .. note
                if ctx.libs().button.isWithinBoundingBox(x, y, id) then
                    ctx.libs().button.update(id, { colorOn = colors.lightGray })
                    ctx.libs().button.draw(id, mon)
                    sleep(0.1)
                    ctx.libs().button.update(id, { colorOn = colors.white })
                    ctx.libs().button.draw(id, mon)
                    return
                end
            end

            -- Black keys
            for _, b in ipairs(BLACK_KEYS) do
                local id = "key_" .. b.note
                if ctx.libs().button.isWithinBoundingBox(x, y, id) then
                    ctx.libs().button.update(id, { colorOn = colors.darkGray })
                    ctx.libs().button.draw(id, mon)
                    sleep(0.1)
                    ctx.libs().button.update(id, { colorOn = colors.gray })
                    ctx.libs().button.draw(id, mon)
                    return
                end
            end
        end
    }
end

local views = { root = mainView }

return {
    id = "music",
    name = "Piano",
    protocol = "music_creator_v1",

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
        if v and v(ctx).draw then v(ctx).draw(mon) end
    end,

    touch = function(ctx, x, y, viewId)
        local v = views[viewId]
        if v and v(ctx).touch then v(ctx).touch(x, y) end
    end
}
