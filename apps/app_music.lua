local keys = {
    { pitch = -1, x = 2,  black = false, playable = false },

    -- playable range 0–24 (F# .. F#)
    { pitch = 0,  x = 4,  black = true,  playable = true }, -- F#
    { pitch = 1,  x = 6,  black = false, playable = true }, -- G
    { pitch = 2,  x = 8,  black = true,  playable = true }, -- G#
    { pitch = 3,  x = 10, black = false, playable = true }, -- A
    { pitch = 4,  x = 12, black = true,  playable = true }, -- A#
    { pitch = 5,  x = 14, black = false, playable = true }, -- B
    { pitch = 6,  x = 18, black = false, playable = true }, -- C
    { pitch = 7,  x = 20, black = true,  playable = true }, -- C#
    { pitch = 8,  x = 22, black = false, playable = true }, -- D
    { pitch = 9,  x = 24, black = true,  playable = true }, -- D#
    { pitch = 10, x = 26, black = false, playable = true }, -- E
    { pitch = 11, x = 30, black = false, playable = true }, -- F
    { pitch = 12, x = 32, black = true,  playable = true }, -- F#
    { pitch = 13, x = 34, black = false, playable = true }, -- G
    { pitch = 14, x = 36, black = true,  playable = true }, -- G#
    { pitch = 15, x = 38, black = false, playable = true }, -- A
    { pitch = 16, x = 40, black = true,  playable = true }, -- A#
    { pitch = 17, x = 42, black = false, playable = true }, -- B
    { pitch = 18, x = 46, black = false, playable = true }, -- C
    { pitch = 19, x = 48, black = true,  playable = true }, -- C#
    { pitch = 20, x = 50, black = false, playable = true }, -- D
    { pitch = 21, x = 52, black = true,  playable = true }, -- D#
    { pitch = 22, x = 54, black = false, playable = true }, -- E
    { pitch = 23, x = 58, black = false, playable = true }, -- F
    { pitch = 24, x = 60, black = true,  playable = true }, -- F#

    { pitch = 25, x = 62, black = false, playable = false }
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
                    (not k.playable and colors.gray)
                    or (k.black and colors.gray)
                    or colors.lightGray

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
                    textOn = tostring(k.pitch),
                    textX = k.x + math.floor(w / 2),
                    textY = START_Y + math.floor(h / 2)
                })
            end
        end,
        draw = function(mon)
            for _, k in ipairs(keys) do
                if not k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end
            for _, k in ipairs(keys) do
                if k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end

            for i = 0, 14 do
                local color = (i % 2 == 0) and colors.lightGray or colors.gray
                ctx.libs().draw.DrawLine(3, 11 + i * 2, 2, 64, color, mon)
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
