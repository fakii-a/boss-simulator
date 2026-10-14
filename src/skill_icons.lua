-- Small original HUD symbols, drawn in code; they are not GLA artwork.
local Icons = {}
function Icons.draw(id, x, y, size)
    local g = love.graphics
    g.push()
    g.translate(x, y)
    g.scale(size / 24, size / 24)
    g.setLineWidth(1.6)
    if id == "dash" then
        for i = 0, 2 do
            g.line(3 + i * 6, 5, 9 + i * 6, 12, 3 + i * 6, 19)
        end
    elseif id == "spin" then
        for i = 0, 2 do
            g.line(4 + i * 6, 19, 9 + i * 6, 5)
        end
    elseif id == "waves" or id == "haki" then
        g.circle("line", 12, 12, 4)
        g.circle("line", 12, 12, 8)
        if id == "waves" then
            g.circle("line", 12, 12, 11)
        else
            g.line(12, 0, 12, 3)
            g.line(12, 21, 12, 24)
            g.line(0, 12, 3, 12)
            g.line(21, 12, 24, 12)
        end
    elseif id == "fissure" then
        g.line(2, 17, 9, 13, 7, 10, 22, 5, 15, 12, 17, 15, 2, 17)
    else
        g.line(5, 20, 19, 4, 20, 9, 9, 20)
        g.line(4, 14, 11, 21)
        if id == "cut" then
            g.line(2, 9, 2, 3, 8, 3)
        elseif id == "shot" then
            g.line(22, 16, 22, 22, 16, 22)
        end
    end
    g.pop()
    g.setLineWidth(1)
end
return Icons
