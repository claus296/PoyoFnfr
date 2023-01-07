return {
    enter = function()
        stageImages = {
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week4/sunset"))),
            love.filesystem.load("sprites/week4/bg-limo.lua")(), -- bg-limo
            love.filesystem.load("sprites/week4/limo-dancer.lua")(), -- limo-dancer
            love.filesystem.load("sprites/week4/limo.lua")() -- limo
        }
        girlfriend = Character.girlfriendcar(0, 0)
        enemy = Character.momcar(0,0)
        boyfriend = Character.boyfriendcar(0,0)
        --fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")() -- Used for game over

        --fakeBoyfriend.x, fakeBoyfriend.y = 350, -100
        stageImages[2].y = 250
        stageImages[3].y = -130
        stageImages[4].y = 375
        girlfriend.x, girlfriend.y = -200, -375
        enemy.x, enemy.y = -500, -400
        boyfriend.x, boyfriend.y = 165, -315
    end,

    load = function()

    end,

    update = function(self, dt)
        stageImages[2]:update(dt)
		stageImages[3]:update(dt)
		stageImages[4]:update(dt)

        if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 120000 / bpm) < 100 then
			stageImages[3]:animate("anim", false)

			stageImages[3]:setAnimSpeed(14.4 / (60 / bpm))
		end
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(cam.x * 0.5, cam.y * 0.5)
            love.graphics.translate(camEx.x * 0.5, camEx.y * 0.5)

			stageImages[1]:draw()

			stageImages[2]:draw()
			for i = -475, 725, 400 do
				stageImages[3].x = i

				stageImages[3]:draw()
			end
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x, cam.y)
            --love.graphics.translate(camEx.x, camEx.y)

			girlfriend:draw()
			stageImages[4]:draw()
			enemy:draw()
			boyfriend:draw()
		love.graphics.pop()
    end,

    leave = function()
        stageImages[1] = nil
        stageImages[2] = nil
        stageImages[3] = nil
        stageImages[4] = nil
    end
}