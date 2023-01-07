return {
    enter = function()
        winColors = {
			{49, 162, 253}, -- Blue
			{49, 253, 140}, -- Green
			{251, 51, 245}, -- Magenta
			{253, 69, 49}, -- Orange
			{251, 166, 51}, -- Yellow
		}
        winAlpha = 1
		winColor = 1
        
        stageImages = {
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/sky"))), -- sky
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/city"))), -- city
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/city-windows"))), -- city-windows
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/behind-train"))), -- behind-train
            graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/street"))) -- street
        }

        stageImages[4].y = -100
		stageImages[4].sizeX, stageImages[4].sizeY = 1.25, 1.25
		stageImages[5].y = -100
		stageImages[5].sizeX, stageImages[5].sizeY = 1.25, 1.25

		enemy = Character.pico(0, 0)

		girlfriend.x, girlfriend.y = -200, -300
		enemy.x, enemy.y = -60, -25
		enemy.sizeX = -1 -- Reverse, reverse!
		boyfriend.x, boyfriend.y = 200, 25
		
		daGoofyColours = {
			1, 1, 1, 1
		}
        
    end,

    load = function()

    end,

    update = function(self, dt)
        if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 240000 / bpm) < 100 then
			winColor = winColor + 1
            winAlpha = 1

			if winColor > 5 then
				winColor = 1
			end
		end
		if phillyGlow then
			daGoofyColours = {
				0.25*255, 0.25*255, 0.25*255, 0.5
			}
		else
			daGoofyColours = {
				255, 255, 255, 1
			}
		end

        if winAlpha > 0 then
            winAlpha = winAlpha - ((bpm/260) * dt)
        end
    end,

    draw = function()
        local curWinColor = winColors[winColor]

        love.graphics.push()
			love.graphics.translate(cam.x * 0.25, cam.y * 0.25)

			stageImages[1]:cdraw(daGoofyColours[1], daGoofyColours[2], daGoofyColours[3])
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x * 0.5, cam.y * 0.5)

			stageImages[2]:cdraw(daGoofyColours[1], daGoofyColours[2], daGoofyColours[3])
			stageImages[3]:cdraw(curWinColor[1], curWinColor[2], curWinColor[3], winAlpha)
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			if phillyGlow then
				gradient:cdraw(curColours[1], curColours[2], curColours[3])
				graphics.setColor(1, 1, 1)
			end
			
			stageImages[4]:cdraw(daGoofyColours[1], daGoofyColours[2], daGoofyColours[3])
			stageImages[5]:cdraw(daGoofyColours[1], daGoofyColours[2], daGoofyColours[3])

			girlfriend:cdraw(curColours[1]/255, curColours[2]/255, curColours[3]/255)
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(cam.x, cam.y)

			enemy:cdraw(curColours[1]/255, curColours[2]/255, curColours[3]/255)
			boyfriend:cdraw(curColours[1]/255, curColours[2]/255, curColours[3]/255)
		love.graphics.pop()
    end,

    leave = function()
        stageImages[1] = nil
        stageImages[2] = nil
        stageImages[3] = nil
        stageImages[4] = nil
        stageImages[5] = nil
    end
}