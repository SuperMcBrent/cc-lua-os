local importName = "left"
local exportName = "right"
local import = peripheral.wrap(importName)
local export = peripheral.wrap(exportName)
peripheral.find("modem", rednet.open)

local itemsFile = "counts.txt"
local tempFile  = "counts.tmp"
local flagFile  = "clear.flg"

local items     = {}
if fs.exists(itemsFile) then
    local f = fs.open(itemsFile, "r")
    items = textutils.unserialize(f.readAll()) or {}
    f.close()
end

function StripEssence(itemname)
    return itemname:gsub("_essence", "")
end

function AddItem(item)
    local name = StripEssence(item.displayName)
    items[name] = (items[name] or 0) + item.count
end

function SaveItemsToFile()
    local f = fs.open(tempFile, "w")
    f.write(textutils.serialize(items))
    f.close()
    if fs.exists(itemsFile) then fs.delete(itemsFile) end
    fs.move(tempFile, itemsFile)
end

function CheckAndClear()
    if fs.exists(flagFile) then
        items = {}
        if fs.exists(itemsFile) then fs.delete(itemsFile) end
        if fs.exists(tempFile) then fs.delete(tempFile) end
        fs.delete(flagFile)
        print("Essence counts cleared (flag)")
    end
end

function HandleRequest(sender, message, protocol)
    print("Handling: " .. tostring(message))
    if message == "provideEssenceCount" then
        local snapshot = {}
        if fs.exists(itemsFile) then
            local f = fs.open(itemsFile, "r")
            snapshot = textutils.unserialize(f.readAll()) or {}
            f.close()
        end
        rednet.send(sender, snapshot, protocol)
    elseif message == "clearEssenceCount" then
        fs.open(flagFile, "w").close()
        print("Clear request received")
    end
end

function RequestListener()
    local sender, message, protocol = rednet.receive()
    if type(message) == "table" and protocol == "batchedRequests" then
        print("Received batch of " .. #message .. " requests")
        for _, req in ipairs(message) do
            HandleRequest(sender, req.message, req.protocol)
        end
    else
        HandleRequest(sender, message, protocol)
    end
end

function MoveItemsLoop()
    while true do
        CheckAndClear()

        for i = 1, 27 do
            local item = import.getItemDetail(i)
            if item then
                AddItem(item)
                import.pushItems(exportName, i, item.count)
            end
        end

        SaveItemsToFile()
        sleep(0.1)
    end
end

parallel.waitForAll(
    MoveItemsLoop,
    function()
        while true do
            RequestListener()
        end
    end
)
