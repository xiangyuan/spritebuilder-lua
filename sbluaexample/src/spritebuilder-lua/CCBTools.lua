local function deepcopy(dst, obj)
    local function copy(d, tv)
        for k,v in pairs(tv) do
            d[k] = v
        end
    end
    for k,v in pairs(obj) do
        if type(v) ~= "table" then
            dst[k] = v
        else
            dst[k] = {}
            copy(dst[k], v)
        end
    end
end

local function color3B_to_color4B(color3B)
    return cc.c4b(color3B.r, color3B.g, color3B.b, 255)
end

local CCBTools = {
    deepcopy = deepcopy,
    c3b_c4b = color3B_to_color4B,
}

return CCBTools