local difficulty

local stageBack, stageFront, curtains

return {
	enter = function(self, from, songNum, songAppend)
		song = songNum
		difficulty = songAppend
		pauseColor = {129, 100, 223}
		weeks:enter()

		enemy = love.filesystem.load("sprites/characters/daddy-dearest.lua")()

		week = 1

		weeks:setIcon("enemy", "daddy dearest")

		self:load()
	end,

	load = function(self)
		weeks:load()
        --print(mods.psychShit[modWeekNum][song] .. "/Inst.ogg")
        inst = waveAudio:newSource(mods.psychShit[modWeekNum][song] .. "/Inst.ogg", "stream")
        voices = waveAudio:newSource(mods.psychShit[modWeekNum][song] .. "/Voices.ogg", "stream")

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
        if difficulty == "easy" then 
            difficulty = "-easy"
        elseif difficulty == "normal" then
            difficulty = ""
        elseif difficulty == "hard" then
            difficulty = "-hard"
        end

		weeks:generateNotes(mods.psychDataShit[modWeekNum][song] .. difficulty .. ".json")
		print(mods.psychDataShit[modWeekNum])
		if love.filesystem.getInfo(mods.psychEvents[modWeekNum][song]) then
			weeks:generateEvents(mods.psychEvents[modWeekNum][song])
		end
        --"mods/" .. dirTable[i] .. "/data/" .. ballsTable[i] .. "/" .. ballsTable[i]
		enemy = mods.psychChars[GlobalChart.song.player2]()
		if GlobalChart.song.player1 ~= "bf" then
			boyfriend = mods.psychChars[GlobalChart.song.player1]()
		end
		stages["psychstage"]:enter(mods.psychStages[modWeekNum][1], mods.psychStages[modWeekNum][2])
		stages["psychstage"]:load()
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["psychstage"]:update(dt)
		if health >= 80 then
			if enemyIcon:getAnimName() == "daddy dearest" then
				weeks:setIcon("enemy", "daddy dearest losing")
			end
		else
			if enemyIcon:getAnimName() == "daddy dearest losing" then
				weeks:setIcon("enemy", "daddy dearest")
			end
		end

		if not (countingDown or graphics.isFading()) and not (inst:getDuration() > musicTime/1000) and not paused then
			if storyMode and song < 3 then
				if score > (highscores[weekNum-1][difficulty].scores[song] or 0) then
					highscores[weekNum-1][difficulty].scores[song] = score
					saveHighscores()
				end
				newAccuracy = convertedAcc:gsub("%%", "")
				if tonumber(newAccuracy) > (highscores[weekNum-1][difficulty].accuracys[song] or 0) then
					print("New accuracy: " .. newAccuracy)
					highscores[weekNum-1][difficulty].accuracys[song] = tonumber(newAccuracy)
					saveHighscores()
				end
				song = song + 1

				self:load()
			else
				status.setLoading(true)

				graphics.fadeOut(
					0.5,
					function()
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(extraCamZoom.sizeX, extraCamZoom.sizeY)
			love.graphics.scale(cam.sizeX, cam.sizeY)
			stages["psychstage"]:draw()
			weeks:drawRating(0.9)
		love.graphics.pop()
		
		weeks:drawTimeLeftBar()
		weeks:drawHealthBar()
		if not paused then
			weeks:drawUI()
		end
	end,

	leave = function(self)
		weeks:leave()
	end
}
