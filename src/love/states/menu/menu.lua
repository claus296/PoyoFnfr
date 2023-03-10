local upFunc, downFunc, confirmFunc, backFunc, drawFunc, musicStop

local menuState

local menuNum = 1

local songNum, songAppend
local songDifficulty = 2

local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")
local transparency

local function switchMenu(menu)
	function backFunc()
		graphics.fadeOut(0.5, love.event.quit)
	end

	menuState = 1
end

return {
	enter = function(self, previous)
		if not music[1]:isPlaying() then
			music[1]:play()
		end
		music[1]:onBeat(function()
			self:onBeat(music[1]:getBeat())
		end)

		transparency = {0}
		Timer.tween(
			1,
			transparency,
			{[1] = 1},
			"out-quad"
		)
		titleBG = graphics.newImage(love.graphics.newImage(graphics.imagePath("menu/titleBG")))

        enter = love.filesystem.load("sprites/menu/titleEnter.lua")()

		enter.x, enter.y = 250, 275

		enter:animate("anim", true)

		changingMenu = false

		if love.system.getOS() == "OS X" and gamejoltLogin["useGamejolt"] then
			gamejolt.giveTrophy(175141)
		end

		whiteRectangles = {}
		for i = 1, 15 do
			table.insert(whiteRectangles, graphics.newImage(love.graphics.newImage(graphics.imagePath("menu/whiteRectangle"))))
			whiteRectangles[i].x = -780 + 100*i
			whiteRectangles[i].y = -1000
		end

		songNum = 0

		switchMenu(1)

		graphics.setFade(0)
		graphics.fadeIn(0.5)
	end,
	onBeat = function(self, n)
		
	end,

	update = function(self, dt)

		music[1]:updateBeat()
		enter:update(dt)

		if input:pressed("beast") then
			BEASTMODE = true
		end

		if not graphics.isFading() then
			if input:pressed("confirm") then
				enter:animate("pressed", true)
				
				if not changingMenu then
					audio.playSound(confirmSound)
					changingMenu = true
					for i = 1, 15 do
						Timer.tween(0.5 + 0.1 + 0.03*i, whiteRectangles[i], {y = 0}, "linear",
							function()
								if i == 15 then
									graphics.fadeOut(0.2, function()
										Gamestate.switch(menuSelect)
										status.setLoading(false)
									end)
									
								end
							end
						)
					end
				end
			elseif input:pressed("back") then
				audio.playSound(selectSound)

				backFunc()
			end
		end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			love.graphics.push()
				love.graphics.push()
					love.graphics.translate(menuDetails.titleBG.x, menuDetails.titleBG.y)
					titleBG:draw()
					enter:draw()
				love.graphics.pop()
				love.graphics.push()
					love.graphics.scale(0.9, 0.9)
					love.graphics.translate(menuDetails.titleLogo.x, menuDetails.titleLogo.y)
					
				love.graphics.pop()
				love.graphics.push()
					love.graphics.scale(0.9, 0.9)
					--love.graphics.translate(menuDetails.girlfriendTitle.x, menuDetails.girlfriendTitle.y)
				
				love.graphics.pop()
				love.graphics.push()
					graphics.setColor(0, 0, 0, 0.9)
					for i = 1, 15 do
						whiteRectangles[i]:draw()
					end
					graphics.setColor(1, 1, 1)
				love.graphics.pop()
			love.graphics.pop()

		love.graphics.pop()
	end,

	leave = function(self)

		Timer.clear()
	end
}
