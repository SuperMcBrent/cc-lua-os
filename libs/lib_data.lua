function Serialize(ctx, data, name)
    print("Serializing data to " .. name)
    if not fs.exists('/data') then
        fs.makeDir('/data')
    end
    local f = fs.open('/data/' .. name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end

function Unserialize(ctx, name)
    print("Unserializing data from " .. name)
    local data = nil
    if fs.exists('/data/' .. name) then
        local f = fs.open('/data/' .. name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

return {
    id = "data",
    name = "Persistence Library",
    alias = "data",
    dependencies = {},
    serialize = function(ctx, data, name)
        return Serialize(ctx, data, name)
    end,
    unserialize = function(ctx, name)
        return Unserialize(ctx, name)
    end
}

--[[
    Example usage:

    local ok, res = pcall(libs.data.serialize, ctx, { foo = "bar" }, "test")
    if not ok then
        print("serialize error:", res)
    end

    local ok2, res2 = pcall(libs.data.unserialize, ctx, "test")
    if not ok2 then
        print("unserialize error:", res)
    end

    for k, _ in pairs(res2) do
        print(k)
    end
]]
