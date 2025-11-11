local keys = {
    { pitch = -1, x = 3,  black = false, playable = false, note = "" },

    -- playable range 0–24 (F# .. F#)
    { pitch = 0,  x = 5,  black = true,  playable = true,  note = "f" }, -- F#
    { pitch = 1,  x = 7,  black = false, playable = true,  note = "G" }, -- G
    { pitch = 2,  x = 9,  black = true,  playable = true,  note = "g" }, -- G#
    { pitch = 3,  x = 11, black = false, playable = true,  note = "A" }, -- A
    { pitch = 4,  x = 13, black = true,  playable = true,  note = "a" }, -- A#
    { pitch = 5,  x = 15, black = false, playable = true,  note = "B" }, -- B
    { pitch = 6,  x = 19, black = false, playable = true,  note = "C" }, -- C
    { pitch = 7,  x = 21, black = true,  playable = true,  note = "c" }, -- C#
    { pitch = 8,  x = 23, black = false, playable = true,  note = "D" }, -- D
    { pitch = 9,  x = 25, black = true,  playable = true,  note = "d" }, -- D#
    { pitch = 10, x = 27, black = false, playable = true,  note = "E" }, -- E
    { pitch = 11, x = 31, black = false, playable = true,  note = "F" }, -- F
    { pitch = 12, x = 33, black = true,  playable = true,  note = "f" }, -- F#
    { pitch = 13, x = 35, black = false, playable = true,  note = "G" }, -- G
    { pitch = 14, x = 37, black = true,  playable = true,  note = "g" }, -- G#
    { pitch = 15, x = 39, black = false, playable = true,  note = "A" }, -- A
    { pitch = 16, x = 41, black = true,  playable = true,  note = "a" }, -- A#
    { pitch = 17, x = 43, black = false, playable = true,  note = "B" }, -- B
    { pitch = 18, x = 47, black = false, playable = true,  note = "C" }, -- C
    { pitch = 19, x = 49, black = true,  playable = true,  note = "c" }, -- C#
    { pitch = 20, x = 51, black = false, playable = true,  note = "D" }, -- D
    { pitch = 21, x = 53, black = true,  playable = true,  note = "d" }, -- D#
    { pitch = 22, x = 55, black = false, playable = true,  note = "E" }, -- E
    { pitch = 23, x = 59, black = false, playable = true,  note = "F" }, -- F
    { pitch = 24, x = 61, black = true,  playable = true,  note = "f" }, -- F#

    { pitch = 25, x = 63, black = false, playable = false, note = "" }
}

local testSong = {
    [0] = { { pitch = 6, instrument = "harp" } },
    [1] = { { pitch = 8, instrument = "harp" } },
    [2] = { { pitch = 10, instrument = "harp" } },
    [3] = { { pitch = 11, instrument = "harp" } },
    [4] = { { pitch = 13, instrument = "harp" } },
    [5] = { { pitch = 15, instrument = "harp" } },
    [6] = { { pitch = 17, instrument = "harp" } },
    [7] = { { pitch = 18, instrument = "harp" } }
}

local tempo = 0.2
local tempos = { 0.2, 0.4, 0.6, 0.8, 1.0 }

local speaker0 = peripheral.wrap("speaker_0")

local WHITE_W, WHITE_H = 3, 6
local BLACK_W, BLACK_H = 3, 3
local START_Y = 5

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

                local textY = START_Y + math.floor(h / 2)
                if not k.black then
                    textY = textY + 1
                end

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
                    textY = textY
                })
            end

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "instrumentsSelectionBtn",
                x = 68,
                y = 4,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Sounds",
                textX = 70,
                textY = 5
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "songSaveBtn",
                x = 68,
                y = 8,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Save",
                textX = 71,
                textY = 9
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "songLoadBtn",
                x = 68,
                y = 12,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Load",
                textX = 71,
                textY = 13
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "songTempoBtn",
                x = 68,
                y = 16,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Spd: " .. tostring(tempo),
                textX = 69,
                textY = 17
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "songChordNextBtn",
                x = 68,
                y = 20,
                w = 5,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Nxt",
                textX = 70,
                textY = 21
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "songChordPrevBtn",
                x = 65,
                y = 20,
                w = 5,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Prv",
                textX = 70,
                textY = 21
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "nothing_5",
                x = 68,
                y = 24,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Nothin",
                textX = 70,
                textY = 25
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "nothing_6",
                x = 68,
                y = 28,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Nothin",
                textX = 70,
                textY = 29
            })

            ctx.libs().button.create({
                app = app,
                view = view,
                name = "nothing_7",
                x = 68,
                y = 32,
                w = 11,
                h = 3,
                colorOn = colors.cyan,
                textOn = "Nothin",
                textX = 70,
                textY = 33
            })
        end,
        draw = function(mon)
            --ctx.libs().draw.drawLine(0, 3, 97, 38, colors.gray, mon)
            ctx.libs().draw.drawLine(2, 4, 65, 31, colors.gray, mon)

            for _, k in ipairs(keys) do
                if not k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end
            for _, k in ipairs(keys) do
                if k.black then ctx.libs().button.draw("key_" .. k.pitch, mon) end
            end

            for i = 0, 9 do
                local offset = (i == 0) and 0 or 2
                local y = 12 + i * 2 + offset

                local color
                if i < 2 then
                    color = colors.white
                else
                    color = ((i - 2) % 2 == 0) and colors.lightGray or colors.white
                end

                local label = string.format("%03d", i)
                ctx.libs().draw.drawLine(3, y, 63, 2, color, mon)
                ctx.libs().draw.drawTitle(3, y, label, colors.black, color, mon)
            end


            ctx.libs().button.draw("instrumentsSelectionBtn", mon)
            ctx.libs().button.draw("songSaveBtn", mon)
            ctx.libs().button.draw("songLoadBtn", mon)
            ctx.libs().button.draw("songTempoBtn", mon)
            ctx.libs().button.draw("songChordNextBtn", mon)
            ctx.libs().button.draw("songChordPrevBtn", mon)
            ctx.libs().button.draw("nothing_5", mon)
            ctx.libs().button.draw("nothing_6", mon)
            ctx.libs().button.draw("nothing_7", mon)
        end,
        touch = function(x, y)
            for _, k in ipairs(keys) do
                if k.black and ctx.libs().button.isWithinBoundingBox(x, y, "key_" .. k.pitch) and k.playable then
                    speaker0.playNote("pling", 3, k.pitch)
                    goto blackWasHit
                end
            end
            for _, k in ipairs(keys) do
                if not k.black and ctx.libs().button.isWithinBoundingBox(x, y, "key_" .. k.pitch) and k.playable then
                    speaker0.playNote("pling", 3, k.pitch)
                    goto blackWasHit
                end
            end
            ::blackWasHit::
            if ctx.libs().button.isWithinBoundingBox(x, y, "songTempoBtn") then
                local newTempo = SwitchTempo()
                ctx.libs().button.update("songTempoBtn", {
                    textOn = "Spd: " .. string.format("%.1f", newTempo)
                })
            end
        end
    }
end

function SwitchTempo()
    for i, t in ipairs(tempos) do
        if tempo == t then
            local nextIndex = (i % #tempos) + 1
            tempo = tempos[nextIndex]
            return tempo
        end
    end
    -- fallback if tempo somehow isn't one of the list
    tempo = tempos[1]
    return tempo
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
