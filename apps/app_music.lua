local NOTES = {
    "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F",
    "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#"
}

local WHITE_W, WHITE_H = 3, 6
local BLACK_W, BLACK_H = 4, 3
local SPACING = 2
local START_X, START_Y = 3, 4

local function isSharp(note) return string.find(note, "#") end

local function mainView(ctx)
    return {
        init = function()
            local app, view = "music", "root"
            local x, y = START_X, START_Y
            local whiteKeyPositions = {}

            for i, note in ipairs(NOTES) do
                if not isSharp(note) then
                    local id = "key_" .. i .. "_" .. note
                    ctx.libs().button.create({
                        app = app,
                        view = view,
                        name = id,
                        x = x,
                        y = y,
                        w = WHITE_W,
                        h = WHITE_H,
                        colorOn = colors.cyan,
                        colorOff = colors.white,
                        state = false,
                        textOn = note,
                        textX = x + math.floor(WHITE_W / 2),
                        textY = y + math.floor(WHITE_H / 2)
                    })
                    whiteKeyPositions[#whiteKeyPositions + 1] = { note = note, x = x }
                    x = x + WHITE_W + SPACING
                end
            end

            for i, note in ipairs(NOTES) do
                if isSharp(note) then
                    local prevWhiteIndex = nil
                    for wi, w in ipairs(whiteKeyPositions) do
                        if NOTES[i - 1] == w.note then
                            prevWhiteIndex = wi
                            break
                        end
                    end
                    if prevWhiteIndex then
                        local baseX = whiteKeyPositions[prevWhiteIndex].x
                        local x = baseX + math.floor((WHITE_W + SPACING) / 2)
                        local id = "key_" .. i .. "_" .. note
                        ctx.libs().button.create({
                            app = app,
                            view = view,
                            name = id,
                            x = x,
                            y = y,
                            w = BLACK_W,
                            h = BLACK_H,
                            colorOn = colors.cyan,
                            colorOff = colors.gray,
                            state = false,
                            textOn = note,
                            textX = x + math.floor(BLACK_W / 2),
                            textY = y + 1
                        })
                    end
                end
            end
        end,

        draw = function(mon)
            for i, note in ipairs(NOTES) do
                if not isSharp(note) then
                    ctx.libs().button.draw("key_" .. i .. "_" .. note, mon)
                end
            end
            for i, note in ipairs(NOTES) do
                if isSharp(note) then
                    ctx.libs().button.draw("key_" .. i .. "_" .. note, mon)
                end
            end
        end,

        touch = function(x, y)
            for i, note in ipairs(NOTES) do
                local id = "key_" .. i .. "_" .. note
                if ctx.libs().button.isWithinBoundingBox(x, y, id) then
                    ctx.libs().button.update(id, { state = true })
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
