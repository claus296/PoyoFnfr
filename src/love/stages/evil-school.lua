return {
    enter = function()
		pixel = true
		love.graphics.setDefaultFilter("nearest")
        stageImages = {
			love.filesystem.load("sprites/week6/evil-school.lua")() -- evil school
        }
		enemy = Character.senpai(0,0)
        enemy = love.filesystem.load("sprites/week6/spirit.lua")()
		enemy.x, enemy.y = -340, -20

        girlfriend.x, girlfriend.y = -375, -250
		boyfriend.x, boyfriend.y = 100, 25
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190
    end,

    load = function(self)
        
    end,

    update = function(self, dt)
		stageImages[1]:update(dt)
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			stageImages[1]:udraw()

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
    end
}