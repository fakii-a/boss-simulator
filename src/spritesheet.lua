-- Carregador de folhas regulares. Nenhuma regra de combate depende deste módulo.
local Spritesheet = {}

function Spritesheet.load(definition)
    local image = love.graphics.newImage(definition.path)
    image:setFilter("nearest", "nearest")

    local imageWidth, imageHeight = image:getDimensions()
    local frameWidth = definition.frameWidth
    local frameHeight = definition.frameHeight

    assert(frameWidth > 0 and frameHeight > 0, "O tamanho do frame deve ser positivo")
    assert(
        imageWidth % frameWidth == 0 and imageHeight % frameHeight == 0,
        "A folha não é divisível pelo tamanho do frame: " .. definition.path
    )

    local columns = imageWidth / frameWidth
    local capacity = columns * (imageHeight / frameHeight)
    local frameCount = definition.frameCount or capacity
    assert(
        frameCount >= 1 and frameCount <= capacity and frameCount == math.floor(frameCount),
        "Quantidade de frames inválida: " .. definition.path
    )

    local frames = {}
    for index = 0, frameCount - 1 do
        local column = index % columns
        local row = math.floor(index / columns)
        frames[#frames + 1] = {
            image = image,
            quad = love.graphics.newQuad(
                column * frameWidth,
                row * frameHeight,
                frameWidth,
                frameHeight,
                imageWidth,
                imageHeight
            ),
            w = frameWidth,
            h = frameHeight,
            flipY = definition.flipY or false,
        }
    end

    return frames
end

return Spritesheet
