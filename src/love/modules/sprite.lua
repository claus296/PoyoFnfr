local Object = require "lib.classic"

local Sprite = Object:extend()

local function addAnim(self, name, prefix, indices, framerate, loop)
    if framerate == nil then framerate = 24 end
    if loop == nil then loop = true end

    local anim = {
        prefix = prefix,
        framerate = framerate,
        loop = loop,
        frames = {}
    }

    local add = function(f)
        table.insert(anim.frames, {
            quad = love.graphics.newQuad(f.x, f.y, f.width, f.height,
                                         self.width, self.height),
            data = f
        })
    end

    if not indices then
        for _, f in ipairs(self.xmlData[prefix]) do 
            add(f) 
        end
    else
        for _, i in ipairs(indices) do
            local f = self.xmlData[prefix][i + 1]
            if not f then f = self.xmlData[prefix][i - 1] end
            add(f)
        end
    end

    self.anims[name] = anim
    self.lastAnimAdded = anim
end

function Sprite:new(x, y)
    self.x = x or 0
    self.y = y or 0

    self.width = 0
    self.height = 0
    self.orientation = 0
    self.alpha = 1
    self.sizeX = 1
    self.sizeY = 1
    self.animOffsets = {}
    self.offsetX = 0
    self.offsetY = 0
    self.shearX = 0
    self.shearY = 0

    self.curAnimated = false

    self.xmlData = {}
    self.anims = {}

    self.time = 1
    self.finished = true
    self.paused = false
end

function Sprite:load(image, desc)
    self.image = image
    self.width = image:getWidth()
    self.height = image:getHeight()

    self.xmlData = {}
    self.anims = {}

    local data = xml.parse(desc)
    for _, e in ipairs(data) do
        if e.tag == "SubTexture" then
            local d = {
                x = tonumber(e.attr["x"]),
                y = tonumber(e.attr["y"]),
                width = tonumber(e.attr["width"]),
                height = tonumber(e.attr["height"])
            }

            local ox = tonumber(e.attr["frameX"]) or 0
            local oy = tonumber(e.attr["frameY"]) or 0
            local ow = tonumber(e.attr["frameWidth"]) or 0
            local oh = tonumber(e.attr["frameHeight"]) or 0
            if ox ~= 0 or oy ~= 0 or ow ~= 0 or oh ~= 0 then
                d.offset = {x = ox, y = oy, width = ow, height = oh}
            end

            local name = string.sub(e.attr["name"], 1, -5)
            if not self.xmlData[name] then self.xmlData[name] = {} end
            table.insert(self.xmlData[name], d)
        end
    end

    return self
end

function Sprite:addByPrefix(name, prefix, framerate, loop)
    addAnim(self, name, prefix, nil, framerate, loop)
    return self
end

function Sprite:addByIndices(name, prefix, indices, framerate, loop)
    addAnim(self, name, prefix, indices, framerate, loop)
    return self
end

function Sprite:addOffset(anim, x, y)
    x = x or 0
    y = y or 0

    self.animOffsets[anim] = {x, y}

    return self
end

function Sprite:animate(anim, loop)
    local resetTimer = false
    self.curAnimated = true

    if not self.curAnim or anim ~= self.curName then
        self.curAnim = self.anims[anim]
        self.curName = anim
        resetTimer = true
    end

    if self.curAnim then
        self.curAnim.loop = loop or false
    end

    self.time = 1
    self.finished = false

    return self
end

function Sprite:setAnimSpeed(speed)
    self.curAnim.framerate = speed
    return self
end

function Sprite:getAnimName()
    return self.curName
end

function Sprite:isAnimName(name)
    return self.anims[name] or false
end

function Sprite:stop()
    self.curAnim = nil
    self.timer = 1
    self.finished = true
    self.curAnimated = false
    return self
end

function Sprite:pause()
    self.paused = true
    return self
end

function Sprite:resume()
    self.paused = false
    self.curAnimated = true
    return self
end

function Sprite:update(dt)
    if self.curAnim and not self.finished and not self.paused then
        self.time = self.time + self.curAnim.framerate * dt
        if self.time > #self.curAnim.frames then
            if self.curAnim.loop then
                self.time = 1
            else
                self.time = #self.curAnim.frames
                self.finished = true
                self.curAnimated = false
            end
        end
    end
end

function Sprite:isAnimFinished()
    return self.finished
end

function Sprite:draw()
    if self.alpha <= 0 then return end

    local frame
    if self.curAnim then
        frame = self.curAnim.frames[math.floor(self.time)]
    else
        frame = self.lastAnimAdded.frames[1]
    end

    local x, y = self.x, self.y
    local ox, oy = 0, 0

    if frame.data.offset then
        local mult = 2.5 / 5

        if frame.data.offset and frame.data.offset.width == 0 then
            ox = math.floor(frame.data.width / 2 - frame.data.width * mult)
        else
            ox = math.floor(frame.data.offset.width / 2 -
                                frame.data.offset.width * mult) +
                     frame.data.offset.x
        end

        if frame.data.offset and frame.data.offset.height == 0 then
            oy = math.floor(frame.data.height / 2 - frame.data.height * mult)
        else
            oy = math.floor(frame.data.offset.height / 2 -
                                frame.data.offset.height * mult) +
                     frame.data.offset.y
        end
    end

    local customOffset = self.animOffsets[self.curName]
    if customOffset then
        ox = ox + customOffset[1]
        oy = oy + customOffset[2]
    end

    love.graphics.draw(
        self.image, 
        frame.quad, 
        x, 
        y, 
        self.orientation,
        self.sizeX, 
        self.sizeY, 
        ox,
        oy,
        self.shearX, 
        self.shearY
    )
end

function Sprite:udraw(sizex, sizey)
    if self.alpha <= 0 then return end

    local frame
    if self.curAnim then
        frame = self.curAnim.frames[math.floor(self.time)]
    else
        frame = self.lastAnimAdded.frames[1]
    end

    local x, y = self.x, self.y
    local ox, oy = 0, 0

    if frame.data.offset then
        local mult = 2.5 / 5

        if frame.data.offset and frame.data.offset.width == 0 then
            ox = math.floor(frame.data.width / 2 - frame.data.width * mult)
        else
            ox = math.floor(frame.data.offset.width / 2 -
                                frame.data.offset.width * mult) +
                     frame.data.offset.x
        end

        if frame.data.offset and frame.data.offset.height == 0 then
            oy = math.floor(frame.data.height / 2 - frame.data.height * mult)
        else
            oy = math.floor(frame.data.offset.height / 2 -
                                frame.data.offset.height * mult) +
                     frame.data.offset.y
        end
    end

    local customOffset = self.animOffsets[self.curName]
    if customOffset then
        ox = ox + customOffset[1]
        oy = oy + customOffset[2]
    end

    love.graphics.draw(
        self.image, 
        frame.quad, 
        x, 
        y, 
        self.orientation,
        sizeX or 7, 
        sizeY or 7, 
        ox,
        oy,
        self.shearX, 
        self.shearY
    )
end

function Sprite:cdraw(r, g, b, a)
    if self.alpha <= 0 then return end

    local frame
    if self.curAnim then
        frame = self.curAnim.frames[math.floor(self.time)]
    else
        frame = self.lastAnimAdded.frames[1]
    end

    local x, y = self.x, self.y
    local ox, oy = 0, 0

    if frame.data.offset then
        local mult = 2.5 / 5

        if frame.data.offset and frame.data.offset.width == 0 then
            ox = math.floor(frame.data.width / 2 - frame.data.width * mult)
        else
            ox = math.floor(frame.data.offset.width / 2 -
                                frame.data.offset.width * mult) +
                     frame.data.offset.x
        end

        if frame.data.offset and frame.data.offset.height == 0 then
            oy = math.floor(frame.data.height / 2 - frame.data.height * mult)
        else
            oy = math.floor(frame.data.offset.height / 2 -
                                frame.data.offset.height * mult) +
                     frame.data.offset.y
        end
    end

    local customOffset = self.animOffsets[self.curName]
    if customOffset then
        ox = ox + customOffset[1]
        oy = oy + customOffset[2]
    end

    graphics.setColor(r, g, b, a)

    love.graphics.draw(
        self.image, 
        frame.quad, 
        x, 
        y, 
        self.orientation,
        self.sizeX, 
        self.sizeY, 
        ox,
        oy,
        self.shearX, 
        self.shearY
    )

    graphics.setColor(1,1,1)
end

function Sprite:isAnimated()
    return self.curAnimated or true
end

return Sprite