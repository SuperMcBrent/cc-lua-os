local invName = "create:item_vault_0"
local scanBtnId = "scan_inventory"
local PADDING_X, PADDING_Y = 3, 4
local scanResults = nil
local scanRunning = false

local function rootView(ctx)
    return {
        draw = function(ctx, mon)
            local btnW, btnH = 12, 3
            local x, y = PADDING_X, PADDING_Y

            local label = scanRunning and "Scanning..." or "Scan"
            local color = scanRunning and colors.yellow or colors.lime

            ctx.libs().button.addButton(x, y, btnW, btnH, scanBtnId, color, colors.gray, true, label, "", x + 2, y + 1,
                "")
            ctx.libs().button.drawButton(scanBtnId, mon)
        end,
        touch = function(ctx, x, y)
            if ctx.libs().button.isWithinBoundingBox(x, y, scanBtnId) and not scanRunning then
                scanRunning = true
                scanResults = nil

                local job = function(done_callback)
                    local inv = peripheral.wrap(invName)
                    if not inv or not inv.list then
                        print("Could not access inventory: " .. invName)
                        done_callback()
                        return
                    end

                    local totals = {}
                    for slot, item in pairs(inv.list()) do
                        totals[item.name] = (totals[item.name] or 0) + item.count
                    end

                    done_callback(totals)
                end

                if ctx.os.submitJob then
                    ctx.os.submitJob(job, function(results)
                        scanResults = results
                        scanRunning = false

                        print("\nScan complete:")
                        for name, count in pairs(scanResults) do
                            print((" - %s: %d"):format(name, count))
                        end
                    end)
                else
                    print("System does not expose submitJob")
                    scanRunning = false
                end
            end
        end
    }
end

local views = {
    root = rootView
}

return {
    id = "inventory",
    name = "Inventory",
    protocol = "inventory",
    receive = function(ctx, sender, message) end,
    create = function(ctx) end,
    destroy = function(ctx) end,
    resume = function(ctx) end,
    suspend = function(ctx) end,
    update = function(ctx, dt) end,
    draw = function(ctx, mon, viewId)
        local v = views[viewId]
        if v and v(ctx).draw then v(ctx).draw(ctx, mon) end
    end,
    touch = function(ctx, x, y, viewId)
        local v = views[viewId]
        if v and v(ctx).touch then v(ctx).touch(ctx, x, y) end
    end
}
