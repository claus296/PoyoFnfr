return {
    enter = function()
		pixel = true
		love.graphics.setDefaultFilter("nearest")
        stageImages = {
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/sky"))), -- sky
			graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/school"))), -- school
			graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/street"))), -- street
			graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/trees-back"))), -- trees-back
			love.filesystem.load("sprites/week6/trees.lua")(), -- trees
			love.filesystem.load("sprites/week6/petals.lua")(), -- petals
			love.filesystem.load("sprites/week6/freaks.lua")() -- freaks
        }
		enemy = Character.senpai(0,0)
		--fakeBoyfriend = love.filesystem.load("sprites/pixel/boyfriend.lua")() -- Used for game over
        girlfriend.x, girlfriend.y = -375, -250
		boyfriend.x, boyfriend.y = 100, 25
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190
		enemy.x, enemy.y = -700, -375
    end,

    load = function(self)
        if song == 3 then
            enemy = love.filesystem.load("sprites/week6/spirit.lua")()
            stageImages[2] = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy.x, enemy.y = -700, -375
        elseif song == 2 then
            enemy = Character.senpaiangry(0,0)
            stageImages[7]:animate("dissuaded", true)
			enemy.x, enemy.y = -700, -375
        end
    end,

    update = function(self, dt)
        if song ~= 3 then
			stageImages[6]:update(dt)
			stageImages[5]:update(dt)
			stageImages[7]:update(dt)
		else
			stageImages[2]:update(dt)
		end
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			if song ~= 3 then
				stageImages[1]:udraw()
			end

			stageImages[2]:udraw()
			if song ~= 3 then
				stageImages[3]:udraw()
				stageImages[4]:udraw()

				stageImages[5]:udraw()
				stageImages[6]:udraw()
				stageImages[7]:udraw()
			end
			girlfriend:udraw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x, cam.y)

			enemy:udraw()
			boyfriend:udraw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x * 1.1, cam.y * 1.1)

		love.graphics.pop()
    end,

    leave = function()
        stageImages[1] = nil
		stageImages[2] = nil
		stageImages[3] = nil
		stageImages[4] = nil
		stageImages[5] = nil
		stageImages[6] = nil
		stageImages[7] = nil
    end
}