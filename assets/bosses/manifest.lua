-- User-supplied swordsman views. Visual replacement only, no claim of a new boss kit.
local idle, walk = {}, {}
for direction, frame in ipairs({ 3, 3, 4, 4, 1, 1, 2, 2 }) do
    idle[direction] = { frame }
    walk[direction] = { frame, frame + 4, frame, frame + 8 }
end
return {
    images = {
        "assets/bosses/Image_2D_1512_8212.png",
        "assets/bosses/Image_2D_6535_9423.png",
        "assets/bosses/Image_2D_6537_9433.png",
    },
    frameWidth = 64,
    frameHeight = 64,
    sqmPixels = 30,
    originX = 48,
    originY = 59,
    flipY = true,
    states = { idle = idle, walk = walk },
}
