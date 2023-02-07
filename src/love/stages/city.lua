return {
    enter = function()
        stageImages = {
            graphics.newImage(love.graphics.newImage(graphics.imagePath("city/cityBG")))
        }

        enemy = Character.poyo(0,0)

        girlfriend = love.filesystem.load("sprites/city/newGf.lua")()

        fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")()

        speaker = love.filesystem.load("sprites/city/speaker.lua")()

        girlfriend.x, girlfriend.y = 100, -220
        speaker.x, speaker.y = 100, -260
        enemy.x, enemy.y = -775, -500
        boyfriend.x, boyfriend.y = -200, -440
        fakeBoyfriend.x, fakeBoyfriend.y = 260, -125

        girlfriend.sizeX, girlfriend.sizeY = 0.6
        boyfriend.scale.x, boyfriend.scale.y = 1.2

        speaker:animate("anim", true)

    end,

    load = function()
        cam.x, cam.y = -150, 156
    end,

    update = function(self, dt)
        speaker:update(dt)

		speaker:setAnimSpeed(14.4 / (60 / bpm) * girlfriendSpeedMultiplier)
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

            love.graphics.setColor(1,1,1,BgAlpha)
			stageImages[1]:draw()
            love.graphics.setColor(1,1,1,1)

            love.graphics.setColor(1,1,1,CharAlpha)
            speaker:draw()
			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x, cam.y)

			enemy:draw()
            love.graphics.setColor(1,1,1,1)
            
			boyfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x * 1.1, cam.y * 1.1)

		love.graphics.pop()
    end,

    leave = function()
        stageImages[1] = nil
        speaker = nil

    end
}