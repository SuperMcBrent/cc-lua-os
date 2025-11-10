local dependencies = {}

local function prepare(mainData, extraLists, headers)
    local prepared = {}
    local maxKeyLen = 0
    local MAX_KEY_LEN = 20
    local maxValLen = 0
    local extraCols = {}
    local totalExtraCols = #extraLists

    for colIndex, extraTable in ipairs(extraLists or {}) do
        for k, v in pairs(extraTable) do
            extraCols[k] = extraCols[k] or {}
            extraCols[k][colIndex] = v
        end
    end

    for k, v in pairs(mainData) do
        local keyStr = k:gsub(" Essence", "")
        if #keyStr > maxKeyLen then maxKeyLen = #keyStr end
        local valStr = tostring(v or "-")
        if #valStr > maxValLen then maxValLen = #valStr end
    end

    local colWidths = {}
    for i = 1, totalExtraCols do colWidths[i] = 1 end
    for _, extras in pairs(extraCols) do
        for i = 1, totalExtraCols do
            local val = extras[i] or "-"
            colWidths[i] = math.max(colWidths[i], #tostring(val))
        end
    end

    if headers then
        local keyHeader = headers[1] or ""
        maxKeyLen = math.max(maxKeyLen, #keyHeader)
        local mainHeader = headers[2] or ""
        maxValLen = math.max(maxValLen, #mainHeader)
        for i = 1, totalExtraCols do
            local h = headers[i + 2] or ""
            colWidths[i] = math.max(colWidths[i], #h)
        end
    end

    maxKeyLen = math.min(maxKeyLen, MAX_KEY_LEN)

    if headers then
        local headerLine = "| "
        local keyHeader = headers[1] or ""
        if #keyHeader > MAX_KEY_LEN then keyHeader = keyHeader:sub(1, MAX_KEY_LEN - 3) .. "..." end
        keyHeader = keyHeader .. string.rep(" ", maxKeyLen - #keyHeader)
        headerLine = headerLine .. keyHeader

        local mainHeader = headers[2] or ""
        mainHeader = string.rep(" ", maxValLen - #mainHeader) .. mainHeader
        headerLine = headerLine .. " | " .. mainHeader

        for i = 1, totalExtraCols do
            local h = headers[i + 2] or ""
            h = string.rep(" ", colWidths[i] - #h) .. h
            headerLine = headerLine .. " | " .. h
        end
        headerLine = headerLine .. " |"
        prepared["HEADER"] = headerLine
    end

    local spacerLine = "| " .. string.rep(" ", maxKeyLen) .. " | " .. string.rep(" ", maxValLen)
    for i = 1, totalExtraCols do
        spacerLine = spacerLine .. " | " .. string.rep(" ", colWidths[i])
    end
    spacerLine = spacerLine .. " |"
    prepared["SPACER"] = spacerLine

    for k, v in pairs(mainData) do
        local keyStr = k:gsub(" Essence", "")
        if #keyStr > MAX_KEY_LEN then keyStr = keyStr:sub(1, MAX_KEY_LEN - 3) .. "..." end
        keyStr = keyStr .. string.rep(" ", maxKeyLen - #keyStr)

        local valStr = tostring(v or "-")
        valStr = string.rep(" ", maxValLen - #valStr) .. valStr

        local extras = extraCols[k] or {}
        local extraParts = {}
        for i = 1, totalExtraCols do
            local val = extras[i] or "-"
            val = string.rep(" ", colWidths[i] - #tostring(val)) .. tostring(val)
            table.insert(extraParts, val)
        end

        local line = "| " .. keyStr .. " | " .. valStr
        if totalExtraCols > 0 then
            line = line .. " | " .. table.concat(extraParts, " | ")
        end
        line = line .. " |"

        prepared[k] = line
    end

    prepared.__maxKeyLen = maxKeyLen
    prepared.__maxValLen = maxValLen
    prepared.__extraColWidths = colWidths

    return prepared
end

local function getRow(prepared, key)
    return prepared[key] or nil
end

local function getRows(prepared)
    local rows = {}
    for k, v in pairs(prepared) do
        if type(k) == "string" and not k:match("^__") and k ~= "HEADER" and k ~= "SPACER" then
            table.insert(rows, v)
        end
    end
    table.sort(rows)
    return rows
end

return {
    id = "tablebuilder",
    name = "Table Builder Library",
    alias = "tablebuilder",
    dependencies = {},

    init = function(deps)
        dependencies = deps or {}
    end,

    prepare = prepare,
    getRow = getRow,
    getRows = getRows
}
