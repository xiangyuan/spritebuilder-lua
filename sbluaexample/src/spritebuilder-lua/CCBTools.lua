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

local CCBTools = {
    deepcopy = deepcopy
}

return CCBTools