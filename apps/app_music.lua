local keys = {
    -- left unplayable padding
    { pitch = -1, x = 3,  black = false, playable = false },

    -- playable range 0–24 (F# .. F#)
    { pitch = 0,  x = 5,  black = true,  playable = true }, -- F#
    { pitch = 1,  x = 7,  black = false, playable = true }, -- G
    { pitch = 2,  x = 9,  black = true,  playable = true }, -- G#
    { pitch = 3,  x = 11, black = false, playable = true }, -- A
    { pitch = 4,  x = 13, black = true,  playable = true }, -- A#
    { pitch = 5,  x = 15, black = false, playable = true }, -- B
    { pitch = 6,  x = 19, black = false, playable = true }, -- C
    { pitch = 7,  x = 21, black = true,  playable = true }, -- C#
    { pitch = 8,  x = 23, black = false, playable = true }, -- D
    { pitch = 9,  x = 25, black = true,  playable = true }, -- D#
    { pitch = 10, x = 27, black = false, playable = true }, -- E
    { pitch = 11, x = 31, black = false, playable = true }, -- F
    { pitch = 12, x = 33, black = true,  playable = true }, -- F#
    { pitch = 13, x = 35, black = false, playable = true }, -- G
    { pitch = 14, x = 37, black = true,  playable = true }, -- G#
    { pitch = 15, x = 39, black = false, playable = true }, -- A
    { pitch = 16, x = 41, black = true,  playable = true }, -- A#
    { pitch = 17, x = 43, black = false, playable = true }, -- B
    { pitch = 18, x = 47, black = false, playable = true }, -- C
    { pitch = 19, x = 49, black = true,  playable = true }, -- C#
    { pitch = 20, x = 51, black = false, playable = true }, -- D
    { pitch = 21, x = 53, black = true,  playable = true }, -- D#
    { pitch = 22, x = 55, black = false, playable = true }, -- E
    { pitch = 23, x = 59, black = false, playable = true }, -- F
    { pitch = 24, x = 61, black = true,  playable = true }, -- F#

    -- right unplayable padding
    { pitch = 25, x = 63, black = false, playable = false }
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
                    (not k.playable and colors.lightGray)
                    or (k.black and colors.gray)
                    or colors.white

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
