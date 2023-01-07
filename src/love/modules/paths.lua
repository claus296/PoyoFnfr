local paths = {}

function paths.get(key) return key end

function paths.file(key)
    local contents = love.filesystem.read(paths.get(key))
    return contents
end

function paths.image(key)
    return love.graphics.newImage(graphics.imagePath(key))
end

function paths.xml(key) return paths.file(key .. ".xml") end

function paths.sprite(x, y, key)
    return sprite(
        x, y
    ):load(
        paths.image(key), 
        paths.xml("sprites/" .. key)
    )
end

return paths