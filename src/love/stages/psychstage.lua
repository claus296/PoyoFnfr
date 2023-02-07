function makeLuaSprite(name, img, x, y)
    if img ~= "" then
        --mods.psychShit[modWeekNum][song]
        stageImagesHard[name] = graphics.newImage(love.graphics.newImage("mods/" .. mods.psychModLocations[modWeekNum] .. "/images/" .. directory:gsub("/", "") .. img .. ".png"))
        stageImagesHard[name].scrollX = 1
        stageImagesHard[name].scrollY = 1
    else
        stageImagesHard[name] = {
            x = x - 200,
            y = y - 200,
            sizeX = 1,
            sizeY = 1,
            color = {},
            scrollX = 1,
            scrollY = 1,
    
            draw = function(self)
                graphics.setColor(self.color[1], self.color[2], self.color[3], 1)
                love.graphics.rectangle("fill", self.x, self.y, self.sizeX, self.sizeY)
                graphics.setColor(1, 1, 1, 1)
            end
        }
    end
end
function scaleObject(name, width, height)
    print(stageImagesHard[name])
    stageImagesHard[name].sizeX, stageImagesHard[name].sizeY = stageImagesHard[name].sizeX * width, stageImagesHard[name].sizeY * height
end
function makeGraphic(name, width, height, color)
    stageImagesHard[name].sizeX, stageImagesHard[name].sizeY = width, height
    stageImagesHard[name].color = hexrgb.hex2rgb(color)
end
function setScrollFactor(name, x, y)
    stageImagesHard[name].scrollX, stageImagesHard[name].scrollY = x, y
end
function addLuaSprite(name, isStatic)
    stageImages[#stageImages+1] = stageImagesHard[name]
end
return {
    enter = function(self, stageJson, stageLua)
        if not stageImages then 
            stageImages = {
            }
            stageStaticImages = {
            }
            stageImagesHard = {
            }
        end
        --print(stageJson, stageLua)
        local stageJsonDecode = json.decode(love.filesystem.read(stageJson))
        require (stageLua:gsub("/", "."):gsub("%.lua", ""))
        

        boyfriend.x, boyfriend.y = stageJsonDecode.boyfriend[1], stageJsonDecode.boyfriend[2]
        girlfriend.x, girlfriend.y = stageJsonDecode.girlfriend[1], stageJsonDecode.girlfriend[2]
        enemy.x, enemy.y = stageJsonDecode.opponent[1], stageJsonDecode.opponent[2]

        cam.sizeX, cam.sizeY = stageJsonDecode.defaultZoom, stageJsonDecode.defaultZoom
        camScale.x, camScale.y = stageJsonDecode.defaultZoom, stageJsonDecode.defaultZoom
        directory = stageJsonDecode.directory

        onCreate()

        print(#stageImagesHard)


        stageImages[#stageImages+1] = enemy 
        stageImages[#stageImages+1] = boyfriend
        stageImages[#stageImages+1] = girlfriend
    end,

    load = function()

    end,

    update = function(self, dt)

    end,

    draw = function()
        love.graphics.push()
            for i = 1, #stageImages do
                love.graphics.push()
                    love.graphics.translate(cam.x * (stageImages[i].scrollX or 1), cam.y * (stageImages[i].scrollY or 1))
                    stageImages[i]:draw()
                love.graphics.pop()
            end
        love.graphics.pop()
    end,

    leave = function()
        for i = 1, #stageImages do
            stageImages[i] = nil
        end
    end
}