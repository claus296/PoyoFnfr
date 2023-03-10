--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local difficulty

local stageBack, stageFront, curtains

return {
	enter = function(self, from, songNum, songAppend)
		pauseColor = {129, 100, 223}
		weeks:enter()
		BgAlpha = 1
		fakeCountdownFade = 0

		cam.sizeX, cam.sizeY = 0.8, 0.8
		camScale.x, camScale.y = 0.8, 0.8


		week = 1

		fakeCountdown = love.filesystem.load("sprites/countdown.lua")()

        enemy = Character.poyo(0,0)
		
		girlfriend = love.filesystem.load("sprites/city/newGf.lua")()

        fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")()

        speaker = love.filesystem.load("sprites/city/speaker.lua")()

        girlfriend.x, girlfriend.y = 100, -220
        speaker.x, speaker.y = 100, -260
        enemy.x, enemy.y = -775, -500
        boyfriend.x, boyfriend.y = -200, -420
        fakeBoyfriend.x, fakeBoyfriend.y = 260, -125
		fakeCountdown.sizeX, fakeCountdown.sizeY = 0.9
		fakeCountdown.x, fakeCountdown.y = 700, 350
		
        girlfriend.sizeX, girlfriend.sizeY = 0.6
        boyfriend.scale.x, boyfriend.scale.y = 1.2

		city = graphics.newImage(love.graphics.newImage(graphics.imagePath("city/cityBG")))

		song = songNum
		difficulty = songAppend

		weeks:setIcon("enemy", "daddy dearest")
		weeks:setIcon("boyfriend", "skid and pump")

        speaker:animate("anim", true)

		self:load()
	end,

	load = function(self)
		weeks:load()
		
        cam.x, cam.y = -150, 156

		if song == 3 then
			if BEASTMODE then
				inst = waveAudio:newSource("songs/MR-BEAST/inst.ogg", "stream")
			else
				inst = waveAudio:newSource("songs/epic/inst.ogg", "stream")
			end
			voices = waveAudio:newSource("songs/epic/voices.ogg", "stream")
		elseif song == 2 then
			inst = waveAudio:newSource("songs/energizer/inst.ogg", "stream")
			voices = waveAudio:newSource("songs/energizer/voices.ogg", "stream")
		else
			inst = waveAudio:newSource("songs/summer-sunset/inst.ogg", "stream")
			voices = waveAudio:newSource("songs/summer-sunset/voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("songs/epic/epic.json")
			weeks:generateEvents("songs/epic/epic.json")
		elseif song == 2 then
			weeks:generateNotes("songs/energizer/energizer.json")
			weeks:generateEvents("songs/energizer/energizer.json")
		else
			weeks:generateNotes("songs/summer-sunset/summer-sunset.json")
			weeks:generateEvents("songs/summer-sunset/events.json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		speaker:update(dt)

		speaker:setAnimSpeed(14.4 / (60 / bpm) * girlfriendSpeedMultiplier)

		if song == 1 then
			if musicTime >= 91448.275862069 then
				if musicTime <= 91562.0689655172 then
					fakeCountdown:animate("ready", false)
					fakeCountdownFade = fakeCountdownFade + 0.25
				end
			end
			if musicTime >= 91648.275862069 then
				if musicTime <= 91762.0689655172 then
					fakeCountdownFade = fakeCountdownFade - 0.25
				end
			end
			if musicTime >= 91862.0689655172 then
				if musicTime <= 91975.8620689655 then
					fakeCountdown:animate("set", false)
					fakeCountdownFade = fakeCountdownFade + 0.25
				end
			end
			if musicTime >= 92062.0689655172 then
				if musicTime <= 92275.8620689655 then
					fakeCountdownFade = fakeCountdownFade - 0.25
				end
			end
			if musicTime >= 92275.8620689655 then
				if musicTime <= 92589.6551724138 then
					fakeCountdown:animate("go", false)
					fakeCountdownFade = fakeCountdownFade + 0.25
				end
			end
			if musicTime >= 92689.6551724138 then
				if musicTime <= 93989.6551724138 then
					fakeCountdownFade = fakeCountdownFade - 0.15
				end
			end
		end

		if song == 3 then
			if musicTime >= 34000 then
				BgAlpha = 0
			end
			if musicTime >= 34250 then
				BgAlpha = 1
			end
			if musicTime >= 50000 then
				BgAlpha = 0.5
			end
			if musicTime >= 58000 then
				BgAlpha = 1
			end
			if musicTime >= 65000 then
				BgAlpha = 0
			end
			if musicTime >= 66000 then
				BgAlpha = 1
			end
			if musicTime >= 82000 then
				BgAlpha = 0.5
			end
			if musicTime >= 97500 then
				BgAlpha = 1
			end
			if musicTime >= 164000 then
				BgAlpha = 0.75
			end
			if musicTime >= 182000 then
				BgAlpha = 1
			end
		end

		if health >= 80 then
			if enemyIcon:getAnimName() == "daddy dearest" then
				weeks:setIcon("enemy", "daddy dearest losing")
			end
		else
			if enemyIcon:getAnimName() == "daddy dearest losing" then
				weeks:setIcon("enemy", "daddy dearest")
			end
		end
		if health <= 20 then
			if boyfriendIcon:getAnimName() == "skid and pump" then
				weeks:setIcon("boyfriend", "skid and pump losing")
			end
		else
			if boyfriendIcon:getAnimName() == "skid and pump losing" then
				weeks:setIcon("boyfriend", "skid and pump")
			end
		end
		if not (countingDown or graphics.isFading()) and not (scoreDeath) and not (inst:getDuration() > musicTime/1000) and not paused then
			if storyMode and song < 3 then
				if score > highscores[weekNum-1][difficulty].scores[song] then
					highscores[weekNum-1][difficulty].scores[song] = score
					saveHighscores()
				end
				newAccuracy = convertedAcc:gsub("%%", "")
				if tonumber(newAccuracy) > highscores[weekNum-1][difficulty].accuracys[song] then
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
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

				if song == 3 then
					love.graphics.setColor(1,1,1,BgAlpha)

					city:draw()

					love.graphics.setColor(1,1,1,1)
				else
					city:draw()
				end

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

				if song == 3 then
					if musicTime <= 65000 then
						speaker:draw()
						girlfriend:draw()
						enemy:draw()
					elseif musicTime >= 66000 then
						speaker:draw()
						girlfriend:draw()
						enemy:draw()
					end
				else
					speaker:draw()
					girlfriend:draw()
					enemy:draw()
				end

				boyfriend:draw()

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 1.1, cam.y * 1.1)

			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()
		
		weeks:drawTimeLeftBar()
		if not paused then
			weeks:drawHealthBar()
		end
		weeks:drawUI()
		if song == 1 then
			love.graphics.setColor(1,1,1,fakeCountdownFade)
			fakeCountdown:draw()
			love.graphics.setColor(1,1,1,1)
		end
		if paused then
			weeks:drawHealthBar()
		end
	end,

	leave = function(self)
		BgAlpha = 1
		fakeCountdownFade = 0
		fakeCountdown = nil
		BEASTMODE = false

		weeks:leave()
	end
}
