-- Optional authorized sprites: see assets/README.md. Graphics never modify combat.
local Animation={};Animation.__index=Animation
local dirs={ ["0,-1"]=1,["1,-1"]=2,["1,0"]=3,["1,1"]=4,
    ["0,1"]=5,["-1,1"]=6,["-1,0"]=7,["-1,-1"]=8 }
function Animation.new(kind)
    local self=setmetatable({kind=kind},Animation)
    local path="assets/"..(kind=="player" and "player" or "bosses").."/manifest.lua"
    if love.filesystem.getInfo(path) then
        local ok,manifest=pcall(function() return love.filesystem.load(path)() end)
        if ok then
            local loaded,err=pcall(function()
                self.manifest=manifest;self.quads={};self.frameImages={}
                for _,path in ipairs(manifest.images or {manifest.image}) do
                local image=love.graphics.newImage(path)
                image:setFilter("nearest","nearest")
                self.image=self.image or image
                local w,h=image:getDimensions()
                assert(w%manifest.frameWidth==0 and h%manifest.frameHeight==0,"dimensões incompatíveis")
                local cols=w/manifest.frameWidth
                for i=0,(w/manifest.frameWidth)*(h/manifest.frameHeight)-1 do
                    self.quads[#self.quads+1]=love.graphics.newQuad((i%cols)*manifest.frameWidth,
                        math.floor(i/cols)*manifest.frameHeight,manifest.frameWidth,manifest.frameHeight,w,h)
                    self.frameImages[#self.quads]=image
                end
                end
                for _,rows in pairs(manifest.states) do for _,frames in pairs(rows) do
                    for _,index in ipairs(frames) do assert(self.quads[index],"frame fora da spritesheet") end
                end end
            end)
            if not loaded then self.image=nil;self.error=tostring(err) end
        else self.error=tostring(manifest) end
    end
    return self
end
local function color(r,g,b,a) love.graphics.setColor(r,g,b,a or 1) end
function Animation:draw(e,x,y,sqm,time)
    local g=love.graphics
    local direction=dirs[e.faceX..","..e.faceY] or 5
    local walking=e.step~=nil
    local frame=walking and math.min(4,math.floor(e.walkPhase*4)+1) or 1
    if self.image then
        local state=e.state=="moving" and "walk" or e.state=="attacking" and "attack" or e.state=="dead" and "death" or "idle"
        local rows=self.manifest.states[state] or self.manifest.states.idle
        local frames=rows[direction] or rows[5] or rows[1]
        local index=walking and (frame-1)%#frames+1 or math.floor(time*(self.manifest.fps or 8))%#frames+1
        local scale=sqm/(self.manifest.sqmPixels or self.manifest.frameWidth)
        local ox=self.manifest.originX or self.manifest.frameWidth/2
        local oy=self.manifest.originY or self.manifest.frameHeight
        local sy=scale
        if self.manifest.flipY then sy=-scale;oy=self.manifest.frameHeight-oy end
        color(.02,.025,.03,.32);g.ellipse("fill",x,y,sqm*.30,sqm*.12)
        if e.hp<=0 then color(.48,.48,.48,.55)
        elseif e.flash and e.flash>0 then color(1,.5,.5)
        else color(1,1,1) end
        local selected=frames[index]
        g.draw(self.frameImages[selected],self.quads[selected],x,y,0,scale,sy,ox,oy)
        return
    end
    local boss=self.kind=="boss"
    local scale=sqm/32*(boss and 1.22 or 1)
    g.push();g.translate(x,y);g.scale(scale,scale)
    if e.hp<=0 then
        color(.04,.06,.09,.65);g.ellipse("fill",0,0,15,6)
        color(boss and .5 or .18,.22,.3);g.rectangle("fill",-13,-8,24,8,3)
        g.pop();return
    end
    color(.02,.025,.03,.32);g.ellipse("fill",0,0,boss and 13 or 10,5)
    local bob=walking and ((frame==2 or frame==4) and -1.3 or 0) or math.sin(time*2)*.35
    g.translate(0,bob)
    local gait=walking and (frame%2==0 and 2 or -2) or 0
    color(.08,.13,.19);g.rectangle("fill",-7,-9+gait,6,10,2);g.rectangle("fill",2,-9-gait,6,10,2)
    color(.16,.2,.26);g.rectangle("fill",-8,-3+gait,7,4,1);g.rectangle("fill",2,-3-gait,8,4,1)
    color(.025,.04,.07);g.rectangle("fill",-11,-28,23,21,4)
    if boss then color(.47,.11,.22) else color(.12,.34,.52) end
    g.rectangle("fill",-9,-27,19,18,3)
    if boss then color(.8,.24,.29) else color(.2,.6,.69) end
    g.rectangle("fill",-7,-26,6,16,2)
    color(.86,.69,.36);g.rectangle("fill",-9,-12,19,3)
    color(.07,.1,.16);g.rectangle("fill",-7,-41,16,17,5)
    color(.87,.76,.55);g.rectangle("fill",-5,-38,12,11,3)
    local back=e.faceY<0
    if back then color(.09,.14,.22);g.rectangle("fill",-6,-40,14,15,3)
    else
        color(boss and .8 or .58,boss and .22 or .72,boss and .26 or .78)
        g.rectangle("fill",-7,-41,17,6,2)
        color(.08,.13,.2);g.rectangle("fill",-5,-33,13,3)
        color(.45,.93,.93);g.rectangle("fill",e.faceX<0 and -5 or 1,-33,5,2)
    end
    local armX=e.faceX<0 and -12 or 12
    local attack=e.state=="attacking" or e.state=="windup"
    local lift=attack and -9 or 0
    color(.84,.71,.51);g.rectangle("fill",armX-3,-24+lift,6,10,2)
    if boss then
        color(.5,.38,.26);g.rectangle("fill",armX,-35+lift,3,20)
        color(.16,.19,.26);g.rectangle("fill",armX-4,-39+lift,11,11,2)
        color(.6,.65,.7);g.rectangle("fill",armX-3,-40+lift,3,3);g.rectangle("fill",armX+5,-36+lift,3,3)
    else
        color(.74,.86,.89);g.rectangle("fill",armX-1,-30+lift,3,16)
        color(.28,.58,.67);g.rectangle("fill",armX-4,-16+lift,9,3)
        color(.66,.78,.82);g.rectangle("fill",-armX-1,-27,3,12)
    end
    if e.flash and e.flash>0 then color(1,1,1,.45);g.rectangle("fill",-9,-40,19,31,4) end
    g.pop()
end
return Animation
