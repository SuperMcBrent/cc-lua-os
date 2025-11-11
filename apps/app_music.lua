local keys = {
    { pitch = -1, x = 2,  black = false, playable = false, note = "" },

    -- playable range 0–24 (F# .. F#)
    { pitch = 0,  x = 4,  black = true,  playable = true,  note = "f" }, -- F#
    { pitch = 1,  x = 6,  black = false, playable = true,  note = "G" }, -- G
    { pitch = 2,  x = 8,  black = true,  playable = true,  note = "g" }, -- G#
    { pitch = 3,  x = 10, black = false, playable = true,  note = "A" }, -- A
    { pitch = 4,  x = 12, black = true,  playable = true,  note = "a" }, -- A#
    { pitch = 5,  x = 14, black = false, playable = true,  note = "B" }, -- B
    { pitch = 6,  x = 18, black = false, playable = true,  note = "C" }, -- C
    { pitch = 7,  x = 20, black = true,  playable = true,  note = "c" }, -- C#
    { pitch = 8,  x = 22, black = false, playable = true,  note = "D" }, -- D
    { pitch = 9,  x = 24, black = true,  playable = true,  note = "d" }, -- D#
    { pitch = 10, x = 26, black = false, playable = true,  note = "E" }, -- E
    { pitch = 11, x = 30, black = false, playable = true,  note = "F" }, -- F
    { pitch = 12, x = 32, black = true,  playable = true,  note = "f" }, -- F#
    { pitch = 13, x = 34, black = false, playable = true,  note = "G" }, -- G
    { pitch = 14, x = 36, black = true,  playable = true,  note = "g" }, -- G#
    { pitch = 15, x = 38, black = false, playable = true,  note = "A" }, -- A
    { pitch = 16, x = 40, black = true,  playable = true,  note = "a" }, -- A#
    { pitch = 17, x = 42, black = false, playable = true,  note = "B" }, -- B
    { pitch = 18, x = 46, black = false, playable = true,  note = "C" }, -- C
    { pitch = 19, x = 48, black = true,  playable = true,  note = "c" }, -- C#
    { pitch = 20, x = 50, black = false, playable = true,  note = "D" }, -- D
    { pitch = 21, x = 52, black = true,  playable = true,  note = "d" }, -- D#
    { pitch = 22, x = 54, black = false, playable = true,  note = "E" }, -- E
    { pitch = 23, x = 58, black = false, playable = true,  note = "F" }, -- F
    { pitch = 24, x = 60, black = true,  playable = true,  note = "f" }, -- F#

    { pitch = 25, x = 62, black = false, playable = false, note = "" }
}



local WHITE_W, WHITE_H = 3, 6
local BLACK_W, BLACK_H = 3, 3
local START_Y = 4

local function mainView(ctx)
    return {
        init = function()
            local app, view = "music", "root"

            for _, k in ipairs(keys) do
                local w = k.black and BLACK_W or WHITE_W
                local h = k.black and BLACK_H or WHITE_H
                local color =
                    (not k.playable and colors.lightgray)
                    or (k.black and colors.black)
                    or colors.white
                local textColor =
                    (not k.playable and colors.black)
                    or (k.black and colors.white)
                    or colors.black

                ctx.libs().button.create({
                    app = app,
                    view = view,
                    name = "key_" .. k.pitch,
                    x = k.x,
                    y = START_Y,
                    w = w,
                    h = h,
                    colorOn = color,
                    colorOff = color,
                    state = false,
                    textOn = k.note,
                    textColor = textColor,
                    textX = k.x + math.floor(w / 2),
                    textY = START_Y + math.floor(h / 2)
                })
            end
        end,
        draw = function(mon)
            --ctx.libs().draw.drawLine(0, 3, 97, 38, colors.gray, mon)
            ctx.libs().draw.drawLine(2, 4, 64, 10, colors.gray, mon)

            for _, k in ipairs(keys) do
                if not k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end
            for _, k in ipairs(keys) do
                if k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end

            for i = 0, 9 do
                local color = (i % 2 == 0) and colors.lightGray or colors.white
                ctx.libs().draw.drawLine(2, 11 + i * 2, 63, 2, color, mon)
            end
        end,
        touch = function(x, y)
            for _, k in ipairs(keys) do
                if k.black and ctx.libs().button.isWithinBoundingBox(x, y, "key_" .. k.pitch) and k.playable then
                    goto blackWasHit
                end
            end
            for _, k in ipairs(keys) do
                if not k.black and ctx.libs().button.isWithinBoundingBox(x, y, "key_" .. k.pitch) and k.playable then
                    goto blackWasHit
                end
            end
            ::blackWasHit::
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
        for _, v in pairs(views) do
            local view = v(ctx)
            if view and view.init then view.init() end
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
