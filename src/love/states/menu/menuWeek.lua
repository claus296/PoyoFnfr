local downFunc, confirmFunc, backFunc, drawFunc, menuFunc, menuDesc

local menuState

local menuNum = 1
local theTracks
weekNum = 1
local songNum, songAppend
local songDifficulty = 2

local difficultyStrs = { 
	"easy",
	"normal",
	"hard"
}
local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

local function switchMenu(menu)

end

return {
	enter = function(self, previous)
		songNum = 0
		weekNum = 1
		theTracks = ""
		for trackLength = 1, #weekMeta[weekNum][2] do
			if theTracks ~= "" then
				theTracks = theTracks .. " | " .. weekMeta[weekNum][2][trackLength]
			else
				theTracks = weekMeta[weekNum][2][trackLength]
			end
		end

		currentWeek = 0


		function colourTween()
			Timer.tween(
				0.1,
				freeColour, 
				{
					[1] = freeplayColours[weekNum][1],
					[2] = freeplayColours[weekNum][2],
					[3] = freeplayColours[weekNum][3]
				}, 
				"linear"
			)
		end
		function colourTweenAlt()
			Timer.tween(
				0.1,
				freeColour, 
				{
					[1] = freeplayColours[1][1],
					[2] = freeplayColours[1][2],
					[3] = freeplayColours[1][3]
				}, 
				"linear"
			)
		end

		cam.sizeX, cam.sizeY = 0.9, 0.9
		camScale.x, camScale.y = 0.9, 0.9

		updatePres("Choosing A Week", "In the Week Select Menu", "logo", now)

		freeColour = {
			255,255,255
		}
		freeplayColours = {
			{255,180,200}
		}
		Timer.tween(
			0.8,
			freeColour, 
			{
				[1] = freeplayColours[1][1],
				[2] = freeplayColours[1][2],
				[3] = freeplayColours[1][3]
			}, 
			"linear"
		)
		
		titleBG = graphics.newImage(love.graphics.newImage(graphics.imagePath("menu/weekMenu")))

		arrowLeft = love.filesystem.load("sprites/menu/menuArrow.lua")()
		arrowRight = love.filesystem.load("sprites/menu/menuArrow.lua")()

		arrowLeft.x, arrowLeft.y = -250, -270
		arrowRight.x, arrowRight.y = 250, -270

		--amongus

		arrowRight.orientation = 1.5707963267949*2

		bfDanceLines = love.filesystem.load("sprites/menu/idlelines.lua")()

		gfDanceLines = love.filesystem.load("sprites/menu/idlelines.lua")()

		bfDanceLines.sizeX, bfDanceLines.sizeY = 0.5, 0.5
		gfDanceLines.sizeX, gfDanceLines.sizeY = 0.5, 0.5

		bfDanceLines.x, bfDanceLines.y = 400, 0
		gfDanceLines.x, gfDanceLines.y = 0, -20

		weekImages = graphics.newImage(love.graphics.newImage(graphics.imagePath("menu/week1")))

		weekImages.y = -270

		bfDanceLines:animate("boyfriend", true)
		gfDanceLines:animate("girlfriend", true)

		switchMenu(1)

		graphics.setFade(0)
		graphics.fadeIn(0.5)

		function confirmFunc()
			music[1]:stop()
			songNum = 1

			status.setLoading(true)

			graphics.fadeOut(
				0.5,
				function()
					
					songAppend = difficultyStrs[songDifficulty]

					storyMode = true

					Gamestate.switch(weekData[weekNum], songNum, songAppend, weekNum)

					status.setLoading(false)
				end
			)
		end
		
	end,

	update = function(self, dt)
		function menuFunc()
			theTracks = ""
			for trackLength = 1, #weekMeta[weekNum][2] do
				if theTracks ~= "" then
					theTracks = theTracks .. " | " .. weekMeta[weekNum][2][trackLength]
				else
					theTracks = weekMeta[weekNum][2][trackLength]
				end
			end
		end

		bfDanceLines:update(dt)
		gfDanceLines:update(dt)
		arrowLeft:update(dt)
		arrowRight:update(dt)
		--print(weekNum)

		if not graphics.isFading() then
			if input:pressed("left") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowLeft:animate("arrow pressed", false)
					wait(0.1)
					arrowLeft:animate("arrow", true)
				end)

				if freeplayColours[weekNum] then colourTween() else colourTweenAlt() end
				menuFunc()
			elseif input:pressed("right") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowRight:animate("arrow pressed", false)
					wait(0.1)
					arrowRight:animate("arrow", true)
				end)

				if freeplayColours[weekNum] then colourTween() else colourTweenAlt() end

				menuFunc()
			elseif input:pressed("confirm") then
				audio.playSound(confirmSound)
                bfDanceLines:animate("boyfriend confirm", false)

				confirmFunc()
			elseif input:pressed("back") then
				audio.playSound(selectSound)

				Gamestate.switch(menuSelect)
			end
		end

	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			--titleBG:draw()

			love.graphics.push()

				graphics.setColorF(freeColour[1], freeColour[2], freeColour[3])
				love.graphics.scale(cam.sizeX, cam.sizeY)
				
				titleBG:draw()

				graphics.setColor(1, 1, 1)

				bfDanceLines:draw()
				gfDanceLines:draw()

				--weekImages[currentWeek + 1]:draw()
				graphics.setColorF(freeColour[1], freeColour[2], freeColour[3])

				weekImages:draw()

				love.graphics.color.printf(weekDesc[weekNum], -639, -395, 853, "center", nil, 1.5, 1.5, freeColour[1], freeColour[2], freeColour[3])

				love.graphics.color.printf(theTracks, -639, 350, 853, "center", nil, 1.5, 1.5, freeColour[1], freeColour[2], freeColour[3])

				love.graphics.setColor(0, 0, 0, 0.4)

				love.graphics.rectangle("fill", -240, -700, 480, 500)
				love.graphics.rectangle("fill", -240, 300, 480, 500)



				love.graphics.setColor(1, 1, 1)
				arrowLeft:draw()
				arrowRight:draw()

			love.graphics.pop()
		love.graphics.pop()
	end,

	leave = function(self)
		bfDanceLines = nil
		gfDanceLines = nil
		titleBG = nil
		Timer.clear()
	end
}