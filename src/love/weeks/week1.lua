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
		stages["stage"]:enter()
		BgAlpha = 1

		week = 1

		song = songNum
		difficulty = songAppend

		weeks:setIcon("enemy", "poyo")

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["stage"]:load()

		if song == 3 then
			inst = waveAudio:newSource("songs/epic/inst.ogg", "stream")
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
		stages["stage"]:update(dt)

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

		if not (countingDown or graphics.isFading()) and not (enemyScore > score) and not (inst:getDuration() > musicTime/1000) and not paused then
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
			love.graphics.scale(extraCamZoom.sizeX, extraCamZoom.sizeY)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			if musicTime <= 216000 then
				stages["stage"]:draw()
			end
			weeks:drawRating(0.9)
		love.graphics.pop()
		
		weeks:drawTimeLeftBar()
		weeks:drawHealthBar()
		if not paused then
			weeks:drawUI()
		end
	end,

	leave = function(self)
		stages["stage"]:leave()
		BgAlpha = 1

		weeks:leave()
	end
}
