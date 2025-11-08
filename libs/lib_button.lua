local buttonData, dependencies = {}, {}
local composites, groups = {}, {}

local function ensure(app, view)
    if not buttonData[app] then buttonData[app] = {} end
    if not buttonData[app][view] then buttonData[app][view] = {} end
end

local function assertParams(t)
    for _, k in ipairs({ "app", "view", "name", "x", "y" }) do
        if t[k] == nil then error("Missing mandatory parameter: " .. k) end
    end
end

local function ensureUniqueId(id)
    for _, apps in pairs(buttonData) do
        for _, views in pairs(apps) do
            if views[id] then
                error("Duplicate button id: " .. id)
            end
        end
    end
    if composites[id] then
        error("Duplicate composite id: " .. id)
    end
end

local function create(params)
    if type(params) ~= "table" then error("create() requires a table") end

    assertParams(params)
    ensureUniqueId(params.name)

    ensure(params.app, params.view)

    local text = params.textOn or "ON"
    local b = {
        app = params.app,
        view = params.view,
        name = params.name,
        x = params.x,
        y = params.y,
        width = params.w or #text,
        height = params.h or 1,
        colorOn = params.colorOn or colors.lime,
        colorOff = params.colorOff or colors.red,
        state = params.state ~= nil and params.state or true,
        visible = params.visible ~= false,
        textOn = text,
        textOff = params.textOff or "",
        textX = params.textX or params.x,
        textY = params.textY or params.y,
        header = params.header or "",
        group = params.group,
        composite = params.composite
    }

    buttonData[params.app][params.view][params.name] = b

    if b.group then
        groups[b.group] = groups[b.group] or {}
        table.insert(groups[b.group], b)
    end

    if b.composite then
        composites[b.composite] = composites[b.composite] or {}
        table.insert(composites[b.composite], b)
    end

    return b
end

local function get(name)
    for _, apps in pairs(buttonData) do
        for _, views in pairs(apps) do
            if views[name] then
                return views[name]
            end
        end
    end
    return nil
end

local function update(name, props)
    local b = get(name)
    if not b or type(props) ~= "table" then return end
    for k, v in pairs(props) do
        if b[k] ~= nil then b[k] = v end
    end
end

local function isWithinBoundingBox(x, y, id)
    local function check(b)
        return b.visible and x >= b.x and x < b.x + b.width and y >= b.y and y < b.y + b.height
    end

    if composites[id] then
        for _, b in ipairs(composites[id]) do if check(b) then return true end end
        return false
    elseif groups[id] then
        for _, b in ipairs(groups[id]) do if check(b) then return true end end
        return false
    else
        local b = get(id)
        return b and check(b) or false
    end
end

local function draw(id, mon)
    local function drawButton(b)
        if not b.visible then return end
        local color = b.state and b.colorOn or b.colorOff
        local text = b.state and b.textOn or b.textOff
        dependencies.draw.drawLine(b.x, b.y, b.width, b.height, color, mon)
        if b.header ~= "" then
            dependencies.draw.drawTitle(b.x, b.y - 1, b.header, colors.white, colors.black, mon)
        end
        dependencies.draw.drawTitle(b.textX, b.textY, text, colors.white, color, mon)
    end

    if composites[id] then
        for _, b in ipairs(composites[id]) do drawButton(b) end
    elseif groups[id] then
        for _, b in ipairs(groups[id]) do drawButton(b) end
    else
        local b = get(id)
        if b then drawButton(b) end
    end
end

local function quick(app, view, name, x, y, text, colorOn)
    return create({
        app = app,
        view = view,
        name = name,
        x = x,
        y = y,
        w = #text,
        h = 1,
        colorOn = colorOn or colors.lime,
        colorOff = colors.red,
        state = true,
        textOn = text,
        textOff = "",
        textX = x,
        textY = y
    })
end

return {
    id = "buttons",
    name = "Button Library",
    alias = "button",
    dependencies = { "draw" },
    init = function(deps)
        dependencies = deps or {}
        if not dependencies.draw then
            error("Missing dependency: draw")
        end
    end,
    create = create,
    quick = quick,
    update = update,
    isWithinBoundingBox = isWithinBoundingBox,
    draw = draw
}
