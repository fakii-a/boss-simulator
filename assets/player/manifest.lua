-- Supplied PNG textures; four 64x64 views per sheet, three walking poses.
-- Direction assignment is visually inferred; diagonal views reuse cardinal art.
local views={3,3,4,4,1,1,2,2} -- N NE E SE S SW W NW
local idle,walk={},{}
for direction,frame in ipairs(views) do
    idle[direction]={frame}
    walk[direction]={frame,frame+4,frame,frame+8}
end
return {
    images={"assets/player/Image_2D_5264_6629.png",
        "assets/player/Image_2D_2059_8444.png","assets/player/Image_2D_2077_8463.png"},
    frameWidth=64,frameHeight=64,sqmPixels=32,originX=48,originY=59,flipY=true,
    states={idle=idle,walk=walk}, -- no verified attack/death sequence supplied
}
