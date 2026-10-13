-- Supplied sprite sequences. Visual extents never participate in hit detection.
local Effects={};Effects.__index=Effects
local definitions={
    slash={files={"2241_10054","2247_10055","2266_10056","2275_10057","2283_10058"},rect={14,34,67,74}},
    ring={files={"3187_4173","3190_4182"},rect={0,33,223,223}},
    hit={files={"1090_12279","1127_12285","1130_12291","1132_12296"},rect={12,110,138,126}},
}
function Effects.new()
    local self=setmetatable({groups={}},Effects)
    for id,definition in pairs(definitions) do
        local frames={};local r=definition.rect
        for _,name in ipairs(definition.files) do
            local image=love.graphics.newImage("assets/effects/Image_2D_"..name..".png")
            image:setFilter("nearest","nearest")
            frames[#frames+1]={image=image,quad=love.graphics.newQuad(r[1],r[2],r[3],r[4],image:getDimensions()),w=r[3],h=r[4]}
        end
        self.groups[id]=frames
    end
    return self
end
function Effects:sprite(id,progress,x,y,w,h,angle,boss)
    local frames=self.groups[id]
    local frame=frames[math.min(#frames,math.floor(progress*#frames)+1)]
    local alpha=math.max(0,1-progress^3)
    if boss then love.graphics.setColor(1,.14,.18,alpha)
    else love.graphics.setColor(.75,.92,1,alpha) end
    love.graphics.draw(frame.image,frame.quad,x,y,angle or 0,w/frame.w,-h/frame.h,frame.w/2,frame.h/2)
end
function Effects:draw(renderer,visual)
    local shape=visual.shape;local progress=math.max(0,1-visual.remaining/visual.duration)
    local s,boss=renderer.sqm,visual.kind=="boss"
    local x,y=renderer:point(shape.x,shape.y)
    local angle=math.atan2(shape.dy or 0,shape.dx or 1)
    if shape.style=="dash" then
        self:sprite("slash",progress,x,y-s*.35,s*.8,s*.45,angle,false)
    elseif shape.style=="spin" then
        local diameter=(shape.radius or 1.65)*s*2
        self:sprite("ring",progress,x,y,diameter,diameter,progress*math.pi,boss)
    elseif shape.style=="hit" then
        self:sprite("hit",progress,x,y-s*.4,s*1.25,s*1.2,0,boss)
    elseif shape.style=="impact" and shape.area and shape.area.cells then
        for _,cell in ipairs(shape.area.cells) do
            local px,py=renderer:point(cell.x,cell.y)
            self:sprite("hit",progress,px,py,s*1.2,s*1.2,0,boss)
        end
    else
        local reach=shape.range or 1.3
        x=x+math.cos(angle)*reach*s*.55;y=y+math.sin(angle)*reach*s*.55
        self:sprite("slash",progress,x,y,s*math.max(1.6,reach),s*1.7,angle,boss)
    end
end
function Effects:projectile(renderer,p)
    local x,y=renderer:point(p.x,p.y);local s=renderer.sqm
    local progress=((p.lifetime or p.remaining)-p.remaining)*8%1
    self:sprite("slash",progress,x,y,s*.85,s*.65,math.atan2(p.vy,p.vx),p.owner.kind=="boss")
end
return Effects
