function DrawTitle(x, y, text, color_txt, color_bg, monitor)
    monitor.setBackgroundColor(color_bg)
    monitor.setTextColor(color_txt)
    monitor.setCursorPos(x, y)
    monitor.write(text)
    monitor.setCursorPos(1, 1)
    monitor.setBackgroundColor(colors.black)
end

function DrawLine(x, y, length, size, color_bar, monitor)
    for yPos = y, y + size - 1 do
        monitor.setBackgroundColor(color_bar)
        monitor.setCursorPos(x, yPos)
        monitor.write(string.rep(" ", length))
        monitor.setBackgroundColor(colors.black)
    end
end

function DrawProg(x, y, length, size, minVal, maxVal, color_bar, color_bg, monitor)
    DrawLine(x, y, length, size, color_bg, monitor)
    local barSize = math.floor((minVal / maxVal) * length)
    DrawLine(x, y, barSize, size, color_bar, monitor)
end

function DrawContent(x, y, height, width, minVal, maxVal, color_bar, color_bg, monitor)
    DrawGraph(x, y, height, width, color_bg, monitor)
    local a = math.floor((minVal / maxVal) * height)
    DrawGraph(x, y, a, width, color_bar, monitor)
end

function DrawGraph(x, y, height, width, color_bar, monitor)
    DrawLine(x, y - height + 1, width, height, color_bar, monitor)
end

function PutTime(x, y, monitor, bool, color)
    monitor.setBackgroundColor(color)
    monitor.setCursorPos(x, y)
    time = textutils.formatTime(os.time(), bool)
    if os.time() < 10.000 then monitor.write("0" .. time) else monitor.write(time) end
    monitor.setBackgroundColor(colors.black)
end

function ClearBox(x, y, h, l, monitor, color)
    monitor.setBackgroundColor(color)
    for i = y, y + h - 1 do
        monitor.setCursorPos(x, i)
        monitor.write(string.rep(" ", l))
    end
    monitor.setBackgroundColor(colors.black)
end

function Empty(monitor)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

local digits = {
    ["0"] = {
        { 1, 1, 1, 1, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 1 },
        { 1, 0, 1, 0, 1 },
        { 1, 1, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 1, 1, 1, 1, 1 },
    },
    ["1"] = {
        { 0, 0, 1, 0, 0 },
        { 0, 1, 1, 0, 0 },
        { 1, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 0, 1, 0, 0 },
        { 1, 1, 1, 1, 1 },
    },
    ["2"] = {
        { 1, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 1, 1, 1, 1 },
    },
    ["3"] = {
        { 1, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 0, 1 },
        { 1, 1, 1, 1, 0 },
    },
    ["4"] = {
        { 1, 0, 0, 1, 0 },
        { 1, 0, 0, 1, 0 },
        { 1, 0, 0, 1, 0 },
        { 1, 1, 1, 1, 1 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 0, 1, 0 },
    },
    ["5"] = {
        { 1, 1, 1, 1, 1 },
        { 1, 0, 0, 0, 0 },
        { 1, 1, 1, 1, 0 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
    },
    ["6"] = {
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
    },
    ["7"] = {
        { 1, 1, 1, 1, 1 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 0 },
        { 1, 0, 0, 0, 0 },
    },
    ["8"] = {
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
    },
    ["9"] = {
        { 0, 1, 1, 1, 0 },
        { 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 1 },
        { 0, 0, 0, 0, 1 },
        { 0, 0, 0, 0, 1 },
        { 0, 1, 1, 1, 0 },
    },
    ["%"] = {
        { 1, 1, 0, 0, 1 },
        { 1, 1, 0, 1, 1 },
        { 0, 0, 0, 1, 0 },
        { 0, 0, 1, 0, 0 },
        { 0, 1, 0, 0, 0 },
        { 1, 1, 0, 1, 1 },
        { 1, 0, 0, 1, 1 },
    }
}

local function drawPixel(x, y, color, monitor)
    local oldBg = monitor.getBackgroundColor()
    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(color)
    monitor.write(" ")
    monitor.setBackgroundColor(oldBg)
end

function drawDigit(x, y, char, color, monitor)
    local scale = 1
    color = color or colors.white
    local shape = digits[char]
    if not shape then return end

    for row = 1, #shape do
        for col = 1, #shape[row] do
            if shape[row][col] == 1 then
                for dy = 0, scale - 1 do
                    for dx = 0, scale - 1 do
                        drawPixel(x + (col - 1) * scale + dx, y + (row - 1) * scale + dy, color, monitor)
                    end
                end
            end
        end
    end
end

function drawNumber(x, y, number, color, spacing, padleft, monitor)
    spacing = spacing or 1
    local text
    if padleft == false then
        text = tostring(number) .. "%"
    else
        text = string.format("%03d", number) .. "%"
    end

    local scale = 1
    local offset = 0
    for i = 1, #text do
        local c = text:sub(i, i)
        drawDigit(x + offset, y, c, color, monitor)
        offset = offset + (5 * scale) + spacing
    end
end

function drawCircle(left, top, width, color, fill, monitor)
    color = color or colors.white
    fill = fill ~= false
    local aspect = 1.5
    local height = math.floor(width / aspect)
    local radiusX = width / 2
    local radiusY = height / 2
    local cx = left + radiusX
    local cy = top + radiusY

    for yy = 0, height do
        for xx = 0, width do
            local dx = (xx - radiusX)
            local dy = (yy - radiusY) * aspect
            local dist = math.sqrt(dx * dx + dy * dy)
            if fill then
                if dist <= radiusX then drawPixel(left + xx, top + yy, color, monitor) end
            else
                if math.abs(dist - radiusX) < 0.5 then drawPixel(left + xx, top + yy, color, monitor) end
            end
        end
    end
end

local rainbowColors = {
    colors.red,
    colors.orange,
    colors.yellow,
    colors.lime,
    colors.green,
    colors.cyan,
    colors.lightBlue,
    colors.blue,
    colors.purple,
    colors.magenta,
    colors.pink,
}

function rainbow(n)
    local t = os.clock() / n
    local idx = math.floor(t % #rainbowColors) + 1
    return rainbowColors[idx]
end

return {
    id = "draw",
    name = "Drawing Library",
    alias = "draw",
    dependencies = {},
    drawTitle = function(...) return DrawTitle(...) end,
    drawLine = function(...) return DrawLine(...) end,
    drawProg = function(...) return DrawProg(...) end,
    drawContent = function(...) return DrawContent(...) end,
    drawGraph = function(...) return DrawGraph(...) end,
    drawNumber = function(...) return drawNumber(...) end,
    drawCircle = function(...) return drawCircle(...) end,
    putTime = function(...) return PutTime(...) end,
    rainbow = function(...) return rainbow(...) end,
    clearBox = function(...) return ClearBox(...) end,
    empty = function(...) return Empty(...) end,
}
