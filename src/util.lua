local U = {}
function U.clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

function U.sign(v)
    return v > 0 and 1 or (v < 0 and -1 or 0)
end

function U.copy(t)
    if type(t) ~= "table" then
        return t
    end
    local out = {}
    for k, v in pairs(t) do
        out[k] = U.copy(v)
    end
    return out
end

function U.distance(a, b)
    return math.sqrt((a.rx - b.rx) ^ 2 + (a.ry - b.ry) ^ 2)
end

function U.serialize(t)
    if type(t) == "number" or type(t) == "boolean" then
        return tostring(t)
    end
    if type(t) == "string" then
        return string.format("%q", t)
    end
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    local out = { "{" }
    for _, k in ipairs(keys) do
        out[#out + 1] = "[" .. U.serialize(k) .. "]=" .. U.serialize(t[k]) .. ","
    end
    out[#out + 1] = "}"
    return table.concat(out)
end

function U.csv(value)
    return "\"" .. tostring(value or ""):gsub("\"", "\"\"") .. "\""
end
return U
