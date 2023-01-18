return {
    enter = function()
        stageImages = {
            graphics.newImage(love.graphics.newImage(graphics.imagePath("city-old/cityBG")))
        }

        enemy = Character.poyoOld(0,0)

        boyfriend = love.filesystem.load("sprites/boyfriend.lua")()

        boyfriend.colours = {49,176,209}
        
        girlfriend.x, girlfriend.y = 30, -90
        enemy.x, enemy.y = -380, -110
        boyfriend.x, boyfriend.y = 260, 100

    end,

    load = function()

    end,

    update = function(self, dt)
    
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			stageImages[1]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x, cam.y)

			enemy:draw()
            
			boyfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x * 1.1, cam.y * 1.1)

		love.graphics.pop()
    end,

    leave = function()
        stageImages[1] = nil

    end
}