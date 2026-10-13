local Movement = {}
function Movement.initialize(e,x,y)
    e.x,e.y,e.rx,e.ry=x,y,x,y
    e.faceX,e.faceY=0,1
    e.step,e.gap=nil,0
    e.walkPhase,e.steps=0,0
end
function Movement.start(e,dx,dy,world,settings)
    if e.step or e.gap>1e-9 or e.hp<=0 or (e.status.stun or 0)>0 then return false end
    if dx==0 and dy==0 then return false end
    e.faceX,e.faceY=dx,dy
    if not world.arena:canStep(e,dx,dy,world.entities,settings.blockDiagonalCorners) then return false end
    local duration=(dx~=0 and dy~=0) and settings.diagonalStep or settings.straightStep
    duration=duration*(e.status.slow and e.status.slow.multiplier or 1)
    e.step={fromX=e.x,fromY=e.y,elapsed=0,duration=duration}
    e.x,e.y=e.x+dx,e.y+dy
    e.steps=e.steps+1
    e.state="moving"
    return true
end
function Movement.update(e,dt,settings)
    if e.step then
        local s=e.step
        s.elapsed=math.min(s.duration,s.elapsed+dt)
        local t=s.elapsed/s.duration
        e.rx,e.ry=s.fromX+(e.x-s.fromX)*t,s.fromY+(e.y-s.fromY)*t
        e.walkPhase=t
        if t>=1-1e-9 then
            e.rx,e.ry=e.x,e.y;e.step=nil
            e.gap=settings.stepGap or 0
        end
    else
        e.gap=math.max(0,e.gap-dt)
    end
end
return Movement
