local Movement=require("src.movement")
local Dash={}
local function accelerate(e,p)
    local step=e.step
    local phase=step.elapsed/step.duration
    step.duration=(e.x~=step.fromX and e.y~=step.fromY) and p.diagonalStep or p.straightStep
    step.elapsed=phase*step.duration
end
function Dash.start(e,dx,dy,p)
    e.dash={dx=dx,dy=dy,p=p,left=p.sqms,trail=0}
    -- A partial step is the first segment; retain its endpoints and exact position.
    if e.step then accelerate(e,p);e.dash.left=e.dash.left-1 end
end
function Dash.update(e,dt,world)
    local d=e.dash;local p=d.p
    if not e.step and d.left>0 then
        e.gap=0
        if Movement.start(e,d.dx,d.dy,world,{straightStep=p.straightStep,diagonalStep=p.diagonalStep,
            blockDiagonalCorners=world.config.movement.blockDiagonalCorners}) then
            accelerate(e,p);d.left=d.left-1
        else d.left=0 end
    end
    if e.step then
        Movement.update(e,dt,{stepGap=0})
        d.trail=d.trail-dt
        if d.trail<=0 then
            world:addVisual({kind="effect",style="dash",x=e.rx,y=e.ry,dx=d.dx,dy=d.dy},.16,"player")
            d.trail=.04
        end
    end
    if not e.step and d.left==0 then
        e.dash=nil;e.selfStunTotal=p.recovery;e.selfStunRemaining=p.recovery
    end
end
return Dash
