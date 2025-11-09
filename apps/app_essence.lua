local applicationName = "Essence"
local rootViewName = "mainView"
local protocol = "essenceFarmLogs"
local active = false

local testBtnId = "test_essence_request"
local nextPageBtnId = "next_page"
local prevPageBtnId = "prev_page"
local sortButtons = {
    name = "sort_name",
    total = "sort_total",
    avg = "sort_avg"
}

local itemsInStorage = {}
local lastMessage = nil
local snapshot = { table = nil, time = 0 }
local lastAverages = {}

local currentSortColumn, currentSortOrder = "total", "desc"
local currentPage = 1
local linesPerPage = 30

local STORAGE_REFRESH_INTERVAL = 5 --s
local TRANSMIT_INTERVAL = 2        --s
local storageRefreshTimer = 0
local transmitTimer = 0

local function RefreshItemsInStorage(ctx)
    local me = ctx.os.peripherals().me_bridge
    if not (me and me.getItems) then return end
    local items = me.getItems() or {}
    local newStorageCounts = {}
    for _, item in pairs(items) do
        if item.displayName then
            newStorageCounts[item.displayName] = item.count or 0
        end
    end
    itemsInStorage = newStorageCounts
end

local function SortTable(column, order)
    local sorted = {}
    for k, v in pairs(lastMessage or {}) do
        table.insert(sorted, { name = k, value = v, avg = lastAverages[k] or 0 })
    end
    table.sort(sorted, function(a, b)
        if column == "name" then
            return (order == "asc") and (a.name:lower() < b.name:lower()) or (a.name:lower() > b.name:lower())
        elseif column == "total" then
            return (order == "asc") and (a.value < b.value) or (a.value > b.value)
        elseif column == "avg" then
            return (order == "asc") and (a.avg < b.avg) or (a.avg > b.avg)
        end
        return false
    end)
    return sorted
end

local function HasAverages()
    for _ in pairs(lastAverages or {}) do return true end
    return false
end

local function SetSortMode(ctx, column, order)
    if column == "avg" and not HasAverages() then
        column, order = "total", "desc"
    end

    currentSortColumn, currentSortOrder = column, order

    for key, id in pairs(sortButtons) do
        local label = key:gsub("^%l", string.upper)
        local state, arrow = false, ""
        if key == column then
            state = true
            arrow = (order == "asc") and " ^" or " v"
        end
        local visible = not (key == "avg" and not HasAverages())
        ctx.libs().button.update(id, {
            state = state,
            visible = visible,
            textOn = label .. arrow,
            textOff = label
        })
    end
end

local function rootView(ctx)
    return {
        name = rootViewName,
        init = function()
            local W, H = ctx.os.size()

            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = testBtnId,
                x = 2,
                y = 4,
                w = 9,
                h = 3,
                colorOn = colors.cyan,
                state = true,
                textOn = "Test",
                textOff = "60",
                textX = 3,
                textY = 5
            })

            local group = "sortButtons"
            local colW, colH, gapY = 9, 3, 1
            local startX, startY = 2, 8

            local function addSortButton(id, label, offsetY)
                ctx.libs().button.create({
                    app = applicationName,
                    view = rootViewName,
                    name = id,
                    group = group,
                    x = startX,
                    y = startY + offsetY,
                    w = colW,
                    h = colH,
                    colorOn = colors.orange,
                    colorOff = colors.gray,
                    state = false,
                    textOn = label,
                    textOff = label,
                    textX = startX + 1,
                    textY = startY + offsetY + 1
                })
            end

            addSortButton(sortButtons.name, "Name", 0)
            addSortButton(sortButtons.total, "Total", (colH + gapY))
            addSortButton(sortButtons.avg, "Avg", (colH + gapY) * 2)

            SetSortMode(ctx, currentSortColumn, currentSortOrder)

            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = nextPageBtnId,
                x = 2,
                y = 20,
                w = 9,
                h = 3,
                colorOn = colors.cyan,
                colorOff = colors.gray,
                state = true,
                textOn = "-->",
                textOff = "-->",
                textX = 5,
                textY = 21
            })

            ctx.libs().button.create({
                app = applicationName,
                view = rootViewName,
                name = prevPageBtnId,
                x = 2,
                y = 24,
                w = 9,
                h = 3,
                colorOn = colors.cyan,
                colorOff = colors.gray,
                state = true,
                textOn = "<--",
                textOff = "<--",
                textX = 5,
                textY = 25
            })
        end,

        draw = function(mon)
            local W, H = ctx.os.size()

            local prepared = ctx.libs().tablebuilder.prepare(
                lastMessage or {},
                { lastAverages, itemsInStorage, {} },
                { "Name", "Total", "Avg/min" }
            )

            ctx.libs().button.update(testBtnId, {
                state = snapshot.table == nil,
                textOff = SnapshotCountdown()
            })
            ctx.libs().button.draw(testBtnId, mon)

            for key, id in pairs(sortButtons) do
                local visible = not (key == "avg" and not HasAverages())
                ctx.libs().button.update(id, { visible = visible })
                ctx.libs().button.draw(id, mon)
            end

            local sorted = SortTable(currentSortColumn, currentSortOrder)
            local totalPages = math.max(1, math.ceil(#sorted / linesPerPage))
            if currentPage > totalPages then currentPage = totalPages end

            ctx.libs().button.update(nextPageBtnId, {
                colorOn = (currentPage < totalPages) and colors.cyan or colors.gray,
                state = currentPage < totalPages
            })
            ctx.libs().button.update(prevPageBtnId, {
                colorOn = (currentPage > 1) and colors.cyan or colors.gray,
                state = currentPage > 1
            })

            ctx.libs().button.draw(nextPageBtnId, mon)
            ctx.libs().button.draw(prevPageBtnId, mon)

            if not lastMessage then return end

            ctx.libs().draw.drawTitle(13, 5, ctx.libs().tablebuilder.getRow(prepared, "HEADER"), colors.white,
                colors.black, mon)
            ctx.libs().draw.drawTitle(13, 6, ctx.libs().tablebuilder.getRow(prepared, "SPACER"), colors.white,
                colors.black, mon)

            local startIndex = (currentPage - 1) * linesPerPage + 1
            local endIndex = math.min(startIndex + linesPerPage - 1, #sorted)
            local index = 0

            for i = startIndex, endIndex do
                local entry = sorted[i]
                if not entry then break end
                local key = entry.name
                ctx.libs().draw.drawTitle(
                    13,
                    7 + index,
                    ctx.libs().tablebuilder.getRow(prepared, key),
                    colors.white,
                    colors.black,
                    mon
                )
                index = index + 1
            end

            local totalItems = 0
            for _ in pairs(itemsInStorage) do totalItems = totalItems + 1 end
            ctx.libs().draw.drawTitle(W - 10, 2, tostring(totalItems), colors.white, colors.black, mon)
        end,

        touch = function(x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, testBtnId) then
                TakeSnapshot(lastMessage)
                return
            end

            for key, id in pairs(sortButtons) do
                if ctx.libs().button.isWithinBoundingBox(x, y, id) then
                    if key == "avg" and not HasAverages() then return end
                    if currentSortColumn == key then
                        local newOrder = (currentSortOrder == "asc") and "desc" or "asc"
                        SetSortMode(ctx, key, newOrder)
                    else
                        SetSortMode(ctx, key, "asc")
                    end
                    return
                end
            end

            if ctx.libs().button.isWithinBoundingBox(x, y, nextPageBtnId) then
                local sorted = SortTable(currentSortColumn, currentSortOrder)
                local totalPages = math.max(1, math.ceil(#sorted / linesPerPage))
                if currentPage < totalPages then currentPage = currentPage + 1 end
                return
            end

            if ctx.libs().button.isWithinBoundingBox(x, y, prevPageBtnId) then
                if currentPage > 1 then currentPage = currentPage - 1 end
                return
            end
        end
    }
end

function SnapshotCountdown()
    if not snapshot.table then return nil end
    local elapsed = os.clock() - snapshot.time
    local remaining = 60 - elapsed
    remaining = remaining > 0 and remaining or 0
    return math.floor(remaining + 0.5)
end

function TakeSnapshot(currentTable)
    snapshot.table = {}
    for k, v in pairs(currentTable) do snapshot.table[k] = v end
    snapshot.time = os.clock()
end

function SnapshotReady()
    return snapshot.table and (os.clock() - snapshot.time >= 60)
end

function GetDifferences(currentTable)
    if not snapshot.table then return nil end
    local differences = {}
    for k, oldValue in pairs(snapshot.table) do
        differences[k] = (currentTable[k] or 0) - oldValue
    end
    return differences
end

function ClearSnapshot()
    snapshot.table = nil
    snapshot.time = 0
end

local views = { root = rootView }

return {
    id = "essenceFarmLogs",
    name = applicationName,
    protocol = protocol,
    receive = function(ctx, sender, message)
        lastMessage = message
        if SnapshotReady() then
            lastAverages = GetDifferences(lastMessage) or {}
            ClearSnapshot()
        end
    end,
    create = function(ctx)
        for k, v in pairs(views) do
            local view = v(ctx)
            if view and view.init then view.init() end
        end
        RefreshItemsInStorage(ctx)
    end,
    destroy = function(ctx) ClearSnapshot() end,
    resume = function(ctx) active = true end,
    suspend = function(ctx)
        active = false
        ClearSnapshot()
    end,

    update = function(ctx, dt)
        if not active then return end

        storageRefreshTimer = storageRefreshTimer + dt
        transmitTimer = transmitTimer + dt

        if storageRefreshTimer >= STORAGE_REFRESH_INTERVAL then
            storageRefreshTimer = 0
            RefreshItemsInStorage(ctx)
        end

        if transmitTimer >= TRANSMIT_INTERVAL then
            transmitTimer = 0
            ctx.os.transmit("provideEssenceCount", protocol)
        end
    end,

    draw = function(ctx, mon, viewId)
        local v = views[viewId]
        if v and v(ctx).draw then v(ctx).draw(mon) end
    end,

    touch = function(ctx, x, y, viewId)
        local v = views[viewId]
        if v and v(ctx).touch then v(ctx).touch(x, y) end
    end
}
