local C = {}
function C.circleRect(x, y, r, rx, ry, w, h)
    local nx = math.max(rx, math.min(rx + w, x))
    local ny = math.max(ry, math.min(ry + h, y))
    return (x - nx) ^ 2 + (y - ny) ^ 2 <= r * r
end

function C.segmentCircle(ax, ay, bx, by, cx, cy, r)
    local dx, dy = bx - ax, by - ay
    local len = dx * dx + dy * dy
    local t = len > 0 and math.max(0, math.min(1, ((cx - ax) * dx + (cy - ay) * dy) / len)) or 0
    return (ax + dx * t - cx) ^ 2 + (ay + dy * t - cy) ^ 2 <= r * r
end

function C.segmentRect(ax, ay, bx, by, x, y, w, h, padding)
    padding = padding or 0
    x, y, w, h = x - padding, y - padding, w + 2 * padding, h + 2 * padding
    local low, high = 0, 1
    local function slab(start, delta, minv, maxv)
        if math.abs(delta) < 1e-10 then
            return start >= minv and start <= maxv
        end
        local a, b = (minv - start) / delta, (maxv - start) / delta
        if a > b then
            a, b = b, a
        end
        low, high = math.max(low, a), math.min(high, b)
        return low <= high
    end
    return slab(ax, bx - ax, x, x + w) and slab(ay, by - ay, y, y + h), low
end

function C.hits(shape, entity)
    local x, y, r = entity.rx, entity.ry, entity.radius
    if shape.kind == "circle" then
        return (x - shape.x) ^ 2 + (y - shape.y) ^ 2 <= (r + shape.radius) ^ 2
    end
    for _, cell in ipairs(shape.cells or {}) do
        if C.circleRect(x, y, r, cell.x - 0.5, cell.y - 0.5, 1, 1) then
            return true
        end
    end
    return false
end

function C.cells(origin, dx, dy, range, width, spread)
    local out = {}
    local mag = math.sqrt(dx * dx + dy * dy)
    dx, dy = dx / mag, dy / mag
    for y = origin.y - range - 1, origin.y + range + 1 do
        for x = origin.x - range - 1, origin.x + range + 1 do
            local vx, vy = x - origin.x, y - origin.y
            -- One diagonal SQM is a whole grid step, not one Euclidean unit.
            local forward = (vx * dx + vy * dy) / mag
            local side = math.abs(vx * -dy + vy * dx)
            local half = spread and (0.5 + math.max(0, forward - 1) * spread) or (width / 2)
            if
                forward >= 0.5
                and forward <= range + 0.1
                and side <= half + 0.05
                and math.max(math.abs(vx), math.abs(vy)) <= range
            then
                out[#out + 1] = { x = x, y = y }
            end
        end
    end
    return { kind = "cells", cells = out }
end
return C
