local Animation=require("src.animation")
local U=require("src.util")
local R={};R.__index=R
function R.new()
    return setmetatable({player=Animation.new("player"),boss=Animation.new("boss"),
        view={x=24,y=112,w=900,h=592}},R)
end
function R:camera(world)
    local v,s=self.view,world.config.arena.sqm*world.config.window.scale
    local cx,cy=(world.arena.cols+1)/2,(world.arena.rows+1)/2
    if world.config.camera.follow then cx,cy=world.player.rx,world.player.ry end
    local halfX,halfY=v.w/(2*s),v.h/(2*s)
    cx=U.clamp(cx,math.min(.5+halfX,world.arena.cols/2+.5),math.max(world.arena.cols+.5-halfX,world.arena.cols/2+.5))
    cy=U.clamp(cy,math.min(.5+halfY,world.arena.rows/2+.5),math.max(world.arena.rows+.5-halfY,world.arena.rows/2+.5))
    self.cx,self.cy,self.sqm=cx,cy,s
end
function R:point(x,y)
    return self.view.x+self.view.w/2+(x-self.cx)*self.sqm,
        self.view.y+self.view.h/2+(y-self.cy)*self.sqm
end
function R:shape(shape,alpha,kind,outline)
    local g,s=love.graphics,self.sqm
    local colors={warning={1,.68,.22},boss={1,.25,.3},player={.28,.83,.9},debug={1,.2,.85}}
    local c=colors[kind] or colors.boss
    g.setColor(c[1],c[2],c[3],alpha)
    if shape.kind=="circle" then
        local x,y=self:point(shape.x,shape.y)
        g.circle(outline and "line" or "fill",x,y,shape.radius*s)
    else
        for _,cell in ipairs(shape.cells) do
            local x,y=self:point(cell.x,cell.y)
            g.rectangle(outline and "line" or "fill",x-s/2+1,y-s/2+1,s-2,s-2,3)
        end
    end
end
function R:draw(world,fonts)
    local g,v=love.graphics,self.view
    self:camera(world)
    local sx,sy=g.transformPoint(v.x,v.y)
    local ex,ey=g.transformPoint(v.x+v.w,v.y+v.h)
    g.setScissor(sx,sy,ex-sx,ey-sy)
    g.setColor(.12,.19,.21);g.rectangle("fill",v.x,v.y,v.w,v.h)
    local s=self.sqm
    for y=1,world.arena.rows do for x=1,world.arena.cols do
        local px,py=self:point(x,y)
        if px+s/2>=v.x and px-s/2<=v.x+v.w and py+s/2>=v.y and py-s/2<=v.y+v.h then
            local wall=world.arena:isWall(x,y)
            local edge=x==1 or y==1 or x==world.arena.cols or y==world.arena.rows
            local variant=(x*17+y*31)%5
            if wall then
                if edge then g.setColor(.10,.25+variant*.008,.22) else g.setColor(.24,.25,.25) end
            else g.setColor(.23+variant*.009,.29+variant*.008,.29+variant*.005) end
            g.rectangle("fill",px-s/2,py-s/2,s,s)
            if wall and not edge then
                g.setColor(.39,.34,.26);g.rectangle("fill",px-s*.4,py-s*.4,s*.8,s*.8,3)
                g.setColor(.61,.5,.32);g.rectangle("line",px-s*.32,py-s*.32,s*.64,s*.64,2)
                g.line(px-s*.32,py-s*.32,px+s*.32,py+s*.32)
                g.line(px+s*.32,py-s*.32,px-s*.32,py+s*.32)
            elseif not wall then
                g.setColor(.48,.52,.43,.14)
                local speck=((x*13+y*7)%19)/19
                g.rectangle("fill",px-s*.35+speck*s*.4,py+s*.18,s*.06,s*.035)
                if world.settings.grid or world.debug then
                    g.setColor(.53,.68,.65,.12);g.rectangle("line",px-s/2,py-s/2,s,s)
                end
            end
        end
    end end
    -- Arena center mark helps recordings reveal camera translation.
    local mx,my=self:point(math.floor(world.arena.cols/2),math.floor(world.arena.rows/2))
    g.setColor(.5,.68,.64,.13);g.circle("line",mx,my,s*2.8)
    g.line(mx-s*.45,my,mx+s*.45,my);g.line(mx,my-s*.45,mx,my+s*.45)
    local cast=world.boss.cast
    if cast and (cast.phase=="windup" or cast.phase=="between") and (world.settings.telegraphs or world.debug) then
        if cast.shape then
            self:shape(cast.shape,.13+math.sin(world.time*15)*.04,"warning")
            self:shape(cast.shape,.8,"warning",true)
        else
            local x,y=self:point(world.boss.rx,world.boss.ry)
            g.setColor(1,.68,.22,.65)
            for _,angle in ipairs(cast.angles) do
                g.line(x,y,x+math.cos(angle)*s*8,y+math.sin(angle)*s*8)
            end
        end
    end
    for _,h in ipairs(world.hazards) do
        local kind=h.owner==world.player and "player" or "boss"
        self:shape(h.shape,.25+h.remaining/h.duration*.2,kind)
        self:shape(h.shape,.85,kind,true)
    end
    for _,vis in ipairs(world.visuals) do self:shape(vis.shape,vis.remaining/vis.duration*.7,vis.kind,true) end
    local entities={world.player,world.boss}
    table.sort(entities,function(a,b) return a.ry<b.ry end)
    for _,e in ipairs(entities) do
        local x,y=self:point(e.rx,e.ry)
        self[e.kind]:draw(e,x,y,s,world.time)
        if e.hp>0 then
            local width=e.kind=="boss" and 66 or 44
            g.setColor(.03,.05,.07,.85);g.rectangle("fill",x-width/2,y-s*1.6,width,5,2)
            g.setColor(e.kind=="boss" and .94 or .27,e.kind=="boss" and .38 or .83,e.kind=="boss" and .4 or .65)
            g.rectangle("fill",x-width/2,y-s*1.6,width*e.hp/e.maxHp,5,2)
            g.setFont(fonts.tiny);g.setColor(.85,.91,.88)
            g.printf(e.kind=="boss" and "ALVIDA · ESTIMADO" or "JOGADOR",x-95,y-s*1.6-16,190,"center")
            if e.status.slow then g.setColor(.55,.77,1);g.print("LENTO",x-20,y+6) end
            if world.debug then
                g.setColor(1,.2,.85);g.circle("line",x,y,e.radius*s)
                local tx,ty=self:point(e.x,e.y)
                g.rectangle("line",tx-s/2+2,ty-s/2+2,s-4,s-4)
                g.print(string.format("%s (%d,%d) %.3f",e.state,e.x,e.y,e.step and e.step.elapsed or 0),x-70,y+22)
            end
        end
    end
    for _,p in ipairs(world.projectiles) do
        local x,y=self:point(p.x,p.y)
        local angle=math.atan2(p.vy,p.vx)
        g.push();g.translate(x,y);g.rotate(angle+world.time*14)
        if p.owner==world.player then g.setColor(.4,.91,1) else g.setColor(1,.52,.33) end
        g.polygon("fill",-s*.22,0,0,-s*.12,s*.22,0,0,s*.12)
        g.pop()
        if world.debug then g.setColor(1,.2,.85);g.circle("line",x,y,p.radius*s) end
    end
    g.setFont(fonts.body)
    for _,t in ipairs(world.texts) do
        local x,y=self:point(t.x,t.y)
        g.setColor(t.kind=="hurt" and 1 or .6,t.kind=="hurt" and .5 or 1,t.kind=="hurt" and .5 or .89,t.remaining/.85)
        g.printf(t.text,x-55,y-s*1.8-(.85-t.remaining)*26,110,"center")
    end
    g.setScissor()
    g.setColor(.44,.61,.59,.3);g.rectangle("line",v.x,v.y,v.w,v.h,6)
end
return R
