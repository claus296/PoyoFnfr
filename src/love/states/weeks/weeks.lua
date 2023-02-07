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

animList = {
	"left",
	"down",
	"up",
	"right"
}
inputList = {
	"gameLeft",
	"gameDown",
	"gameUp",
	"gameRight"
}
blammedColours = {
	{49, 162, 253}, -- Blue
	{49, 253, 140}, -- Green
	{251, 51, 245}, -- Magenta
	{253, 69, 49}, -- Orange
	{251, 166, 51}, -- Yellow
}
curColours = {
	255, 255, 255, 1
}
local notePosTweenEnemy = {}
local notePosTweenReceptors = {}

local eventFuncs = {
	["Add Camera Zoom"] = function(size, sizeHud)
		size = tonumber(size) or 0.015
		sizeHud = tonumber(sizeHud) or 0.03

		Timer.tween(
			(60/bpm)/4,
			extraCamZoom,
			{
				sizeX = extraCamZoom.sizeX + size,
				sizeY = extraCamZoom.sizeY + size
			},
			"out-quad"
		)
		Timer.tween(
			(60/bpm)/4,
			uiScale,
			{
				sizeX = uiScale.sizeX + sizeHud,
				sizeY = uiScale.sizeY + sizeHud
			},
			"out-quad"
		)
	end,
	["Camera Flash"] = function()
		weeks:doFlash()
	end,
	["bg alpha"] = function() --IM SORRY I KNOW IT'S TERRIBLE IM JUST LAZY
		weeks:doFlash()
	end,
	["Note Spin"] = function(orientation, speed)
		spin = 3.145
		speed = 0.3

		Timer.tween(speed, boyfriendArrows[1], {orientation = boyfriendArrows[1].orientation + spin}, "out-expo")
		Timer.tween(speed, boyfriendArrows[2], {orientation = boyfriendArrows[2].orientation + spin}, "out-expo")
		Timer.tween(speed, boyfriendArrows[3], {orientation = boyfriendArrows[3].orientation + spin}, "out-expo")
		Timer.tween(speed, boyfriendArrows[4], {orientation = boyfriendArrows[4].orientation + spin}, "out-expo")

		Timer.tween(speed, enemyArrows[1], {orientation = enemyArrows[1].orientation + spin}, "out-expo")
		Timer.tween(speed, enemyArrows[2], {orientation = enemyArrows[2].orientation + spin}, "out-expo")
		Timer.tween(speed, enemyArrows[3], {orientation = enemyArrows[3].orientation + spin}, "out-expo")
		Timer.tween(speed, enemyArrows[4], {orientation = enemyArrows[4].orientation + spin}, "out-expo")
	end,
}

missCounter = 0
noteCounter = 0
altScore = 0
scoreDeath = false

ratingTimers = {}

useAltAnims = false
notMissed = {enemy = {}, boyfriend = {}}
judgements = {enemy = {}, boyfriend = {}}
local noteTransTweenReceptors = {enemy = {}, boyfriend = {}}
local noteTransTweenNotes = {enemy = {}, boyfriend = {}}
local noteTransparencyReceptors = {enemy = {}, boyfriend = {}}
local noteTransparencyNotes = {enemy = {}, boyfriend = {}}
local textUIScale = {x = 1, y = 1}

function tweenPauseButtons()

end

return {
	enter = function(self)
		if not settings.boyPlay then
			bfUpdateUI = require "states.weeks.notesHandler-P1"
		end

		girlfriendSpeedMultiplier = 1
		font = love.graphics.newFont("fonts/vcr.ttf", 24)
		love.graphics.setDefaultFilter("nearest")
		pixelFont = love.graphics.newFont("fonts/pixel.fnt")
		love.graphics.setDefaultFilter("linear")
		totalScore = 0

		botplayAlpha = {1}
		botplayY = -100

		function boyPlayAlphaChange()
			Timer.tween(1.25, botplayAlpha, {0}, "in-out-cubic", function()
				Timer.tween(1.25, botplayAlpha, {1}, "in-out-cubic", boyPlayAlphaChange)
			end)
		end
		boyPlayAlphaChange()

		--PAUSE MENU IMAGES
		pauseBG = graphics.newImage(love.graphics.newImage(graphics.imagePath("pause/pause_box")))
		pauseShadow = graphics.newImage(love.graphics.newImage(graphics.imagePath("pause/pause_shadow")))

		sounds = {
			countdown = {
				three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
				two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
				one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
				go = love.audio.newSource("sounds/countdown-go.ogg", "static")
			},
			miss = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			Hitsounds = {
				love.audio.newSource("sounds/hitSound.ogg", "static"),
			},
			death = love.audio.newSource("sounds/death.ogg", "static"),
			breakfast = love.audio.newSource("songs/misc/breakfast.ogg", "stream"),
			["text"] = love.audio.newSource("sounds/pixel/text.ogg", "static"),
			["continue"] = love.audio.newSource("sounds/pixel/continue-text.ogg", "static"),
		}
		images = {
			icons = love.graphics.newImage(graphics.imagePath("icons")),
			notes = love.graphics.newImage(graphics.imagePath("notes/"..noteskins[settings.noteSkins])),
			notesplashes = love.graphics.newImage(graphics.imagePath("noteSplashes")),
			numbers = love.graphics.newImage(graphics.imagePath("numbers")),
			rating = love.graphics.newImage(graphics.imagePath("rating")),
		}

		sprites = {
			icons = love.filesystem.load("sprites/icons.lua"),
			numbers = love.filesystem.load("sprites/numbers.lua")
		}

		if love.math.random(1,1000) == 500 then
			girlfriend = Character.luigi(0,0, false)
		else
			girlfriend = Character.girlfriend(0,0)
		end
		boyfriend = Character.boyfriend(0,0)
		rating = love.filesystem.load("sprites/rating.lua")()
			
		rating.sizeX, rating.sizeY = 0.75, 0.75
		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites.numbers()

			numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5

			numbers[i].offsetX = -150
		end

		enemyIcon = sprites.icons()
		boyfriendIcon = sprites.icons()

		if settings.downscroll then
			downscrollOffset = -750
		else
			downscrollOffset = 0
		end

		enemyIcon.y = 350 + downscrollOffset
		boyfriendIcon.y = 350 + downscrollOffset
		enemyIcon.sizeX, enemyIcon.sizeY = 1.5, 1.5
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.5, 1.5

		countdownFade = {}

		countdown = love.filesystem.load("sprites/countdown.lua")()

		function setDialogue(strList)
			dialogueList = strList
			curDialogue = 1
			timer = 0
			progress = 1
			output = ""
			isDone = false
		end
	end,

	load = function(self)
		holdingInput = false
		missCounter = 0
		noteCounter = 0
		altScore = 0

		doingAnim = false -- for week 4 stuff
		hitSick = false
		paused = false
		pauseMenuSelection = 1
		judgements = {enemy = {}, boyfriend = {}} -- clear our judgements
		
		for i = 1, 4 do
			notMissed.enemy[i] = true
			notMissed.boyfriend[i] = true
		end
		useAltAnims = false

		rating.x = girlfriend.x + 70
		for i = 1, 3 do
			numbers[i].x = girlfriend.x - 100 + 50 * i
		end

		cam.x, cam.y = -boyfriend.x - 75, -boyfriend.y - 25

		notesPos = {
			enemy = {
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0}
			},
			boyfriend = {
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0},
				{x=0, y=0, defaultX=0, defaultY=0, orientation=0}
			}
		}
	
		for i = 1, 3 do
			numbers[i].x = girlfriend.x - 100 + 50 * i
		end

		ratingVisibility = {0}
		combo = 0

		enemy:animate("idle")
		boyfriend:animate("idle")
		

		graphics.fadeIn(0.5, function()
			modchartHandler:onLoad()
		end)
	end,

	initUI = function(self)
		events = {}
		songEvents = {}
		eventsP = {}
		enemyNotes = {}
		boyfriendNotes = {}
		picoNotes = {}
		health = 50
		score = 0
		enemyScore = 0
		missCounter = 0
		altScore = 0
		sicks = 0
		goods = 0
		bads = 0
		shits = 0
		hitCounter = 0
		textUIScale = {x = 1, y = 1}

		if not enemy.colours then 
			enemy.colours = {255, 255, 255}
		end
		if not boyfriend.colours then 
			boyfriend.colours = {255, 255, 255}
		end

		for i = 1, 4 do 
			noteTransparencyNotes.enemy[i] = 1
			noteTransparencyNotes.boyfriend[i] = 1
		
			noteTransparencyReceptors.enemy[i] = 1
			noteTransparencyReceptors.boyfriend[i] = 1
		end

		local curInput = inputList[i]

		sprites.leftArrow = love.filesystem.load("sprites/notes/" .. noteskins[settings.noteSkins] .. "/left-arrow.lua")
		sprites.downArrow = love.filesystem.load("sprites/notes/" .. noteskins[settings.noteSkins] .. "/down-arrow.lua")
		sprites.upArrow = love.filesystem.load("sprites/notes/" .. noteskins[settings.noteSkins] .. "/up-arrow.lua")
		sprites.rightArrow = love.filesystem.load("sprites/notes/" .. noteskins[settings.noteSkins] .. "/right-arrow.lua")

		leftArrowSplash = love.filesystem.load("sprites/notes/noteSplashes.lua")()
		downArrowSplash = love.filesystem.load("sprites/notes/noteSplashes.lua")()
		upArrowSplash = love.filesystem.load("sprites/notes/noteSplashes.lua")()
		rightArrowSplash = love.filesystem.load("sprites/notes/noteSplashes.lua")()

		enemyArrows = {
			sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
		}
		boyfriendArrows = {
			sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
		}
		picoArrows = {
			sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
		}

		for i = 1, 4 do				
			if settings.middleScroll then
				boyfriendArrows[i].x = -410 + 165 * i
				-- ew stuff
				enemyArrows[1].x = -925 + 165 * 1 
				enemyArrows[2].x = -925 + 165 * 2
				enemyArrows[3].x = 100 + 165 * 3
				enemyArrows[4].x = 100 + 165 * 4

				leftArrowSplash.x = -410 + 165 * 1
				downArrowSplash.x = -410 + 165 * 2
				upArrowSplash.x =  -410 + 165 * 3 
				rightArrowSplash.x = -410 + 165 * 4 

			else
				enemyArrows[i].x = -925 + 165 * i 
				boyfriendArrows[i].x = 100 + 165 * i 

				leftArrowSplash.x = 100 + 165 * 1
				downArrowSplash.x = 100 + 165 * 2
				upArrowSplash.x =  100 + 165 * 3 
				rightArrowSplash.x = 100 + 165 * 4 

			end
			enemyArrows[i].y = -400
			boyfriendArrows[i].y = -400
			leftArrowSplash.y = -400
			downArrowSplash.y = -400
			upArrowSplash.y = -400
			rightArrowSplash.y = -400

			enemyNotes[i] = {}
			boyfriendNotes[i] = {}
			picoNotes[i] = {}
		end
	end,

	generateEvents = function(self, ec) -- ec = events chart
		ec = json.decode(love.filesystem.read(ec))
		ec = ec["song"]
		allEvents = ec["events"]
		for i = 1, #allEvents do
			table.insert(
				songEvents,
				{
					eventTime = allEvents[i][1],
					eventName = allEvents[i][2][1][1],
					eventValue1 = allEvents[i][2][1][2],
					eventValue2 = allEvents[i][2][1][3],
				}
			)
		end
	end,
	-- psych is dumb it has like several different event files for some dumb reason
	generateEventsOld = function(self, ec)
		ec = json.decode(love.filesystem.read(ec))
		ec = ec["song"]
		for i = 1, #ec["notes"] do
			for j = 1, #ec["notes"][i]["sectionNotes"] do
				sectionNotesE = ec["notes"][i]["sectionNotes"]
				table.insert(
					songEvents,
					{
						eventTime = sectionNotesE[j][1] or 0,
						-- 2 is just the noteType (psych is strange)
						eventName = sectionNotesE[j][3] or "Hey!",
						eventValue1 = sectionNotesE[j][4] or "",
						eventValue2 = sectionNotesE[j][5] or "",
					}
				)
				--print(songEvents[i].eventTime, songEvents[i].eventName, songEvents[i].eventValue1, songEvents[i].eventValue2)
			end
		end
	end,

	generateNotes = function(self, chart)
		if not love.filesystem.getInfo(chart) then
			-- remove -hard from the end of the chart name
			chart = chart:gsub("-hard", "")
			-- remove -easy from the end of the chart name
			chart = chart:gsub("-easy", "")
		end
		local eventBpm
		chart = json.decode(love.filesystem.read(chart))
		GlobalChart = chart -- make it global
		chart = chart["song"]
		curSong = chart["song"]

		for i = 1, #chart["notes"] do
			bpm = chart["notes"][i]["bpm"]

			if bpm then
				break
			end
		end
		if not bpm then
			bpm = 100
		end
		if inst then
			inst:parse()
			inst:setBPM(bpm)
			inst:setIntensity(20)
			inst:onBeat(function() 
				if phillyGlow then
					if not glowTween then
						glowTween = Timer.tween(0.25, gradient, {sizeY = 1.2}, "out-quad", function()
							Timer.tween(1.15, gradient, {sizeY = 0.1}, "out-quad", function()
								glowTween = nil
							end)
						end)
					end
				end
				modchartHandler:onBeat(inst:getBeat())
			end)
		end
		if voices then
			voices:parse()
			voices:setBPM(bpm)
			voices:setIntensity(20)
			voices:onBeat(function() end)
		end

		if settings.customScrollSpeed == 1 then
			speed = chart["speed"] or 1
		else
			speed = settings.customScrollSpeed
		end
		songName = chart.songName
		needsVoices = chart.needsVoices

		for i = 1, #chart["notes"] do
			eventBpm = chart["notes"][i]["bpm"] or 100

			for j = 1, #chart["notes"][i]["sectionNotes"] do
				local sprite
				local sectionNotes = chart["notes"][i]["sectionNotes"]

				local mustHitSection = chart["notes"][i]["mustHitSection"]
				local altAnim = chart["notes"][i]["altAnim"] or false
				local noteType = sectionNotes[j][2]
				local noteTime = sectionNotes[j][1]

				--print(noteTime, noteType, mustHitSection, altAnim, eventBpm, #chart["notes"][i]["sectionNotes"])

				if j == 1 then
					table.insert(
						events, 
						{
							eventTime = sectionNotes[1][1], 
							mustHitSection = mustHitSection, 
							bpm = eventBpm, 
							altAnim = altAnim
						}
					)
				end

				if noteType == 0 or noteType == 4 then
					sprite = sprites.leftArrow
				elseif noteType == 1 or noteType == 5 then
					sprite = sprites.downArrow
				elseif noteType == 2 or noteType == 6 then
					sprite = sprites.upArrow
				elseif noteType == 3 or noteType == 7 then
					sprite = sprites.rightArrow
				end

				if mustHitSection then
					if noteType >= 4 then
						local id = noteType - 3
						local c = #enemyNotes[id] + 1
						local x = enemyArrows[id].x

						table.insert(enemyNotes[id], sprite())
						enemyNotes[id][c].x = x
						enemyNotes[id][c].y = noteTime 
						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end

						enemyNotes[id][c]:animate("on", false)

						if sectionNotes[j][3] > 0 then
							local c

							for k = 71 / speed, sectionNotes[j][3], 71 / speed * 1.7 do
								local c = #enemyNotes[id] + 1

								table.insert(enemyNotes[id], sprite())
								enemyNotes[id][c].x = x
								enemyNotes[id][c].y = (noteTime + k)

								enemyNotes[id][c]:animate("hold", false)
							end

							c = #enemyNotes[id]

							enemyNotes[id][c].offsetY = 10

							enemyNotes[id][c]:animate("end", false)
						end
					elseif noteType >= 0 and noteType < 4 then
						local id = noteType + 1
						local c = #boyfriendNotes[id] + 1
						local x = boyfriendArrows[id].x

						table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].x = x
						boyfriendNotes[id][c].y = noteTime 
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end

						boyfriendNotes[id][c]:animate("on", false)

						if sectionNotes[j][3] > 0 then
							local c

							for k = 71 / speed, sectionNotes[j][3], 71 / speed * 1.7 do
								local c = #boyfriendNotes[id] + 1

								table.insert(boyfriendNotes[id], sprite())
								boyfriendNotes[id][c].x = x
								boyfriendNotes[id][c].y = (noteTime + k)

								boyfriendNotes[id][c]:animate("hold", false)
							end

							c = #boyfriendNotes[id]

							boyfriendNotes[id][c].offsetY = 10

							boyfriendNotes[id][c]:animate("end", false)
						end	
					end
				else
					if noteType >= 4 then
						local id = noteType - 3
						local c = #boyfriendNotes[id] + 1
						local x = boyfriendArrows[id].x

						table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].x = x
						boyfriendNotes[id][c].y = noteTime 
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end

						boyfriendNotes[id][c]:animate("on", false)

						if sectionNotes[j][3] > 0 then
							local c

							for k = 71 / speed, sectionNotes[j][3], 71 / speed * 1.7 do
								local c = #boyfriendNotes[id] + 1

								table.insert(boyfriendNotes[id], sprite())
								boyfriendNotes[id][c].x = x
								boyfriendNotes[id][c].y = (noteTime + k)

								boyfriendNotes[id][c]:animate("hold", false)
							end

							c = #boyfriendNotes[id]

							boyfriendNotes[id][c].offsetY = 10

							boyfriendNotes[id][c]:animate("end", false)
						end
					elseif noteType >= 0 and noteType < 4 then
						local id = noteType + 1
						local c = #enemyNotes[id] + 1
						local x = enemyArrows[id].x

						table.insert(enemyNotes[id], sprite())
						enemyNotes[id][c].x = x
						enemyNotes[id][c].y = noteTime
						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end

						enemyNotes[id][c]:animate("on", false)

						if sectionNotes[j][3] > 0 then
							local c

							for k = 71 / speed, sectionNotes[j][3], 71 / speed * 1.7 do
								local c = #enemyNotes[id] + 1

								table.insert(enemyNotes[id], sprite())
								enemyNotes[id][c].x = x
								enemyNotes[id][c].y = (noteTime + k)
								if k > sectionNotes[j][3] - 71 / speed then
									enemyNotes[id][c].offsetY = 10

									enemyNotes[id][c]:animate("end", false)
								else
									enemyNotes[id][c]:animate("hold", false)
								end
							end

							c = #enemyNotes[id]

							enemyNotes[id][c].offsetY = 10

							enemyNotes[id][c]:animate("end", false)
						end
					end
				end
			end
		end

		for i = 1, 4 do
			table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
			table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
		end

		-- Workarounds for bad charts that have multiple notes around the same place
		for i = 1, 4 do
			local offset = 0

			for j = 2, #enemyNotes[i] do
				local index = j - offset

				if enemyNotes[i][index]:getAnimName() == "on" and enemyNotes[i][index - 1]:getAnimName() == "on" and ((enemyNotes[i][index].y - enemyNotes[i][index - 1].y <= 10)) then
					table.remove(enemyNotes[i], index)

					offset = offset + 1
				end
			end
		end
		for i = 1, 4 do
			local offset = 0

			for j = 2, #boyfriendNotes[i] do
				local index = j - offset

				if boyfriendNotes[i][index]:getAnimName() == "on" and boyfriendNotes[i][index - 1]:getAnimName() == "on" and ((boyfriendNotes[i][index].y - boyfriendNotes[i][index - 1].y <= 10)) then
					table.remove(boyfriendNotes[i], index)

					offset = offset + 1
				end
			end
		end
	end,
	generatePicoNotes = function(self, chartP)
		chartP = json.decode(love.filesystem.read(chartP))
		chartP = chartP["song"]
		
		for i = 1, #chartP["notes"] do
			for j = 1, #chartP["notes"][i]["sectionNotes"] do
				local sectionNotes = chartP["notes"][i]["sectionNotes"][j]
				local spriteP
				
				local noteTimeP = sectionNotes[1]
				local noteTypeP = sectionNotes[2]
				local Pspeed = chartP["speed"] or 1

				spriteP = sprites.downArrow

				if noteTypeP >= 0 and noteTypeP < 4 then
					local id = noteTypeP + 1
					local c = #picoNotes[id] + 1
					local x = picoNotes[id].x

					table.insert(picoNotes[id], spriteP())
					picoNotes[id][c].x = x
					picoNotes[id][c].y = noteTimeP * 0.6 * Pspeed

					picoNotes[id][c]:animate("on", false)
				end
				
			end
		end
	end,

	doDialogue = function(dt)
		characterSpeaking = dialogueList[curDialogue][1]
		local fullDialogue = dialogueList[curDialogue][2]

		
		timer = timer + 0.75 * love.timer.getDelta()
		
		if timer >= 0.05 then
			if progress < string.len(fullDialogue) then
				sounds["text"]:play()

				progress = progress + 1

				output = string.sub(fullDialogue, 1, math.floor(progress))

				timer = 0
			else
				timer = 0
			end
		end
	end,

	advanceDialogue = function()
		local fullDialogue = dialogueList[curDialogue][2]
		characterSpeaking = dialogueList[curDialogue][1]
		audio.playSound(sounds["continue"])

		if progress < string.len(fullDialogue) then
			progress = string.len(fullDialogue)
			characterSpeaking = dialogueList[curDialogue][1]
			output = string.sub(fullDialogue, 1, math.floor(progress))
		else
			if curDialogue < #dialogueList then				
				curDialogue = curDialogue + 1
				timer = 0
				progress = 1
				output = ""
			else
				isDone = true
			end
		end
	end,

	-- Gross countdown script
	setupCountdown = function(self)
		lastReportedPlaytime = 0
		musicTime = (240 / bpm) * -1000

		musicThres = 0
		musicPos = 0

		countingDown = true
		countdownFade[1] = 0
		audio.playSound(sounds.countdown.three)
		Timer.after(
			(60 / bpm),
			function()
				countdown:animate("ready")
				countdownFade[1] = 1
				audio.playSound(sounds.countdown.two)
				Timer.tween(
					(60 / bpm),
					countdownFade,
					{0},
					"linear",
					function()
						countdown:animate("set")
						countdownFade[1] = 1
						audio.playSound(sounds.countdown.one)
						Timer.tween(
							(60 / bpm),
							countdownFade,
							{0},
							"linear",
							function()
	
								countdown:animate("go")

								countdownFade[1] = 1
								audio.playSound(sounds.countdown.go)
								Timer.tween(
									(60 / bpm),
									countdownFade,
									{0},
									"linear",
									function()
										countingDown = false

										previousFrameTime = love.timer.getTime() * 1000
										musicTime = 0

										voices:setVolume(settings.vocalsVol)
										if inst then 
											inst:setVolume(settings.instVol)
											inst:play() 
										end
										voices:play()
									end
								)
							end
						)
					end
				)
			end
		)
	end,

	setIcon = function(self, icon, name)
		if icon == "boyfriend" then
			if boyfriendIcon:isAnimName(name) then
				boyfriendIcon:animate(name, false)
			else
				boyfriendIcon:animate("default", false)
			end
		elseif icon == "enemy" then
			if enemyIcon:isAnimName(name) then
				enemyIcon:animate(name, false)
			else
				enemyIcon:animate("default", false)
			end
		end
	end,

	safeAnimate = function(self, sprite, animName, loopAnim, timerID)
		sprite:animate(animName, loopAnim)

		spriteTimers[timerID] = 12
	end,

	update = function(self, dt)
		modchartHandler:onUpdate(dt)
		hitCounter = (sicks + goods + bads + shits)

		if inst then inst:update(dt) end
		voices:update(dt)

		if paused then
			if input:pressed("gameDown") then
				if pauseMenuSelection == 3 then
					pauseMenuSelection = 1
				else
					pauseMenuSelection = pauseMenuSelection + 1
				end
			end

			if input:pressed("gameUp") and paused then
				if pauseMenuSelection == 1 then
					pauseMenuSelection = 3
				else
					pauseMenuSelection = pauseMenuSelection - 1
				end
			end
		end

		status.setLoading(true)

		if not graphics.isFading() then
			if quitPressed then
				quitPressed = false
				music[1]:play()
				graphics.fadeOut(
					0.5,
					function()
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end

		convertedAcc = string.format(
			"%.2f%%",
			(altScore / (noteCounter + missCounter))
		)

		currentSeconds = musicTime / 1000
		songLength = voices:getDuration("seconds")
		timeLeft = songLength - currentSeconds
		--timeLeftFixed = math.floor(timeLeft)
		-- get the minutes and seconds of timeLeft
		timeLeftMinutes = math.floor(timeLeft / 60)
		timeLeftSeconds = math.floor(timeLeft % 60)
		-- format the timeLeft string
		timeLeftString = string.format("%02d:%02d", timeLeftMinutes, timeLeftSeconds)

		if input:pressed("pause") and not countingDown and not inCutscene and not doingDialogue then
			if not paused then
				pauseTime = musicTime
				paused = true
				if inst then inst:pause() end
				voices:pause()
				tweenPauseButtons()
				love.audio.play(sounds.breakfast)
			end
		end

		if paused then
			musicTime = pauseTime
			if input:pressed("confirm") then
				love.audio.stop(sounds.breakfast) -- since theres only 3 options, we can make the sound stop without an else statement
				if pauseMenuSelection == 1 then
					if inst then inst:resume() end
					voices:resume()
					paused = false
				elseif pauseMenuSelection == 2 then
					pauseRestart = true
					Gamestate.push(gameOver)
				elseif pauseMenuSelection == 3 then
					paused = false
					if inst then inst:stop() end
					voices:stop()
					if inst then inst:stop() end
					storyMode = false
					quitPressed = true
				end
			end
		end

		if not doingDialogue and not inCutscene then
			oldMusicThres = musicThres
			if countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!
				musicTime = musicTime + 1000 * dt
			else
				if not graphics.isFading() then
					local time = love.timer.getTime()
					local seconds = voices:tell("seconds")

					musicTime = musicTime + (time * 1000) - (previousFrameTime or 0)
					previousFrameTime = time * 1000

					if lastReportedPlaytime ~= seconds * 1000 then
						lastReportedPlaytime = seconds * 1000
						musicTime = (musicTime + lastReportedPlaytime) / 2
					end
				end
			end

			if settings.botPlay then
				hitSick = true
			end
			
			absMusicTime = math.abs(musicTime)
			musicThres = math.floor(absMusicTime / 100) -- Since "musicTime" isn't precise, this is needed

			for i = 1, #events do
				if events[i].eventTime <= absMusicTime then
					local oldBpm = bpm

					if events[i].bpm then
						bpm = events[i].bpm
						if not bpm then bpm = oldBpm end
					end

					if camTimer then
						Timer.cancel(camTimer)
					end
					if events[i].mustHitSection then
						camTimer = Timer.tween(1.25, cam, {x = -boyfriend.x - 355, y = -boyfriend.y - 340}, "out-quad")
					else
						camTimer = Timer.tween(1.25, cam, {x = -enemy.x - 600, y = -enemy.y - 275}, "out-quad")
					end

					if events[i].altAnim then
						useAltAnims = true
					else
						useAltAnims = false
					end

					table.remove(events, i)

					break
				end
			end

			for i = 1, #songEvents do
				if songEvents[i].eventTime <= absMusicTime then
					if eventFuncs[songEvents[i].eventName] then
						eventFuncs[songEvents[i].eventName](songEvents[i].eventValue1, songEvents.eventValue2)
					end

					table.remove(songEvents, i)
					break
				end
			end

			if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 240000 / bpm) < 100 then
				if uiScaleTimer then Timer.cancel(uiScaleTimer) end
				if camScaleTimer then Timer.cancel(camScaleTimer) end

				camScaleTimer = Timer.tween((60 / bpm) / 16, cam, {sizeX = camScale.x * 1.05, sizeY = camScale.y * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), cam, {sizeX = camScale.x, sizeY = camScale.y}, "out-quad") end)
				uiScaleTimer = Timer.tween((60 / bpm) / 16, uiScale, {sizeX = uiScale.x * 1.05, sizeY = uiScale.y * 1.05}, "out-quad", function() uiScaleTimer = Timer.tween((60 / bpm), uiScale, {sizeX = uiScale.x, sizeY = uiScale.y}, "out-quad") end)
			end

			girlfriend:update(dt)
			enemy:update(dt)
			boyfriend:update(dt)
			if picoSpeaker then picoSpeaker:update(dt) end
			leftArrowSplash:update(dt)
			rightArrowSplash:update(dt)
			upArrowSplash:update(dt)
			downArrowSplash:update(dt)

			if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 120000 / bpm) < 100 then
				if spriteTimers[1] == 0 then
					girlfriend:animate("idle", false)
					
					girlfriend:setAnimSpeed(14.4 / (110 / bpm) * girlfriendSpeedMultiplier)
				end
				if spriteTimers[2] == 0 then
					if enemy:getAnimName() == "idle" or enemy:getAnimName() == "left"
						or enemy:getAnimName() == "right" or enemy:getAnimName() == "up"
							or enemy:getAnimName() == "down" then
								self:safeAnimate(enemy, "idle", false, 2)
					elseif not enemy:getAnimName() == "idle" and not enemy:getAnimName() == "left"
						and not enemy:getAnimName() == "right" and not enemy:getAnimName() == "up"
							and not enemy:getAnimName() == "down" and not enemy:isAnimated() then
								self:safeAnimate(enemy, "idle", false, 2)
					end
				end
				if spriteTimers[3] == 0 then
					self:safeAnimate(boyfriend, "idle", false, 3)
				end
			end

			for i = 1, 3 do
				local spriteTimer = spriteTimers[i]

				if spriteTimer > 0 then
					spriteTimers[i] = spriteTimer - 1
				end
			end
		end
	end,

	updateUI = function(self, dt)
		if not settings.botPlay and not paused then 
			bfUpdateUI:updateUI()
		end
		if extraCamZoom.sizeX > 1 then
			extraCamZoom.sizeX = extraCamZoom.sizeX - 0.01
			extraCamZoom.sizeY = extraCamZoom.sizeY - 0.01
		end
		if not paused then
			if not doingDialogue and not inCutscene then
				musicPos = musicTime * 0.6 * speed

				for i = 1, 4 do
					local enemyArrow = enemyArrows[i]
					local boyfriendArrow = boyfriendArrows[i]
					local picoArrow = picoArrows[i]
					local enemyNote = enemyNotes[i]
					local boyfriendNote = boyfriendNotes[i]
					local picoNote = picoNotes[i]
					local curAnim = animList[i]
					local curInput = inputList[i]

					noteNum = i

					enemyArrow:update(dt)
					boyfriendArrow:update(dt)

					if settings.botPlay then
						if not boyfriendArrow:isAnimated() then
							boyfriendArrow:animate("off", false)
						end
					end

					if not enemyArrow:isAnimated() then
						enemyArrow:animate("off", false)
					end

					if #enemyNote > 0 then
						if ((-400 + enemyNote[1].y * 0.6 * speed) - musicPos <= -400) then
							voices:setVolume(1)

							enemyArrow:animate("confirm", false)

							if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
								if useAltAnims then
									self:safeAnimate(enemy, curAnim .. " alt", true, 2)
								else
									self:safeAnimate(enemy, curAnim, true, 2) 
								end
							else
								if not settings.disableEnemyScore then
									if love.math.random(1,4) == 4 then
										enemyScore = enemyScore + 125
									else
										enemyScore = enemyScore + 300
									end
								end
								if useAltAnims then
									self:safeAnimate(enemy, curAnim .. " alt", false, 2)
								else
									self:safeAnimate(enemy, curAnim, false, 2)
								end
							end

							table.remove(enemyNote, 1)
						end
					end

					if picoSpeaker then 
						if #picoNote > 0 then
							if (picoNote[1].y - musicPos <= -400)then
								voices:setVolume(1)

								self:safeAnimate(picoSpeaker, curAnim, false, 2)

								table.remove(picoNote, 1)
							end
						end
					end

					if settings.botPlay then
						if #boyfriendNote > 0 and (((-400 + boyfriendNote[1].y * 0.6 * speed) - musicPos <= -400)) then
							voices:setVolume(1)

							boyfriendArrow:animate("confirm", false)

							if boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end" then
								self:safeAnimate(boyfriend, curAnim, true, 2)
							else
								self:safeAnimate(boyfriend, curAnim, false, 2)
								score = score + 350
								
								table.insert(judgements.boyfriend, {
									img = love.filesystem.load("sprites/rating.lua")(),
									rating = "sickPlus",
									transparency = 1
								})

								judgements.boyfriend[#judgements.boyfriend].img:animate(judgements.boyfriend[#judgements.boyfriend].rating, false)
								judgements.boyfriend[#judgements.boyfriend].img.x = girlfriend.x
								judgements.boyfriend[#judgements.boyfriend].img.y = girlfriend.y - 100
								judgements.boyfriend[#judgements.boyfriend].img.sizeX, judgements.boyfriend[#judgements.boyfriend].img.sizeY = 0.75, 0.75

								altScore = altScore + 100.00
								sicks = sicks + 1
								noteCounter = noteCounter + 1
								missCounter = 0
								combo = combo + 1

								numbers[1]:animate(tostring(math.floor(combo / 100 % 10), false)) -- 100's
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10), false)) -- 10's
								numbers[3]:animate(tostring(math.floor(combo % 10), false)) -- 1's

								for i = 1, 5 do
									if ratingTimers[i] then Timer.cancel(ratingTimers[i]) end
								end

								ratingVisibility[1] = 1
								rating.y = girlfriend.y - 50
								for i = 1, 3 do
									numbers[i].y = girlfriend.y + 50
								end

								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
								ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
								ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
							end

							table.remove(boyfriendNote, 1)
						end
					end
				end

				if health > 100 then
					health = 100
				elseif health > 20 and boyfriendIcon:getAnimName() == "boyfriend losing" then
					boyfriendIcon:animate("boyfriend", false)
				elseif health <= 0 then -- Game over
					health = 0
					if not settings.practiceMode then
						Gamestate.push(gameOver)
					end
				elseif health <= 20 and boyfriendIcon:getAnimName() == "boyfriend" then
					boyfriendIcon:animate("boyfriend losing", false)
				end

				if enemyScore > score and not (inst:getDuration() > musicTime/1000) then
					if not settings.practiceMode and not settings.botplay then
						Gamestate.push(gameOver)
					end
				end
				if enemyScore >= score and not settings.practiceMode and not settings.botplay then
					scoreDeath = true
				elseif score > enemyScore then
					scoreDeath = false
				end

				enemyIcon.x = 425 - health * 10
				boyfriendIcon.x = 585 - health * 10

				if not countingDown then
					if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
						if enemyIconTimer then Timer.cancel(enemyIconTimer) end
						if boyfriendIconTimer then Timer.cancel(boyfriendIconTimer) end

						enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon, {sizeX = 1.75, sizeY = 1.75, orientation = 0.15}, "out-quad", function() enemyIconTimer = Timer.tween((60 / bpm), enemyIcon, {sizeX = 1.5, sizeY = 1.5, orientation = 0}, "out-quad") end)
						boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon, {sizeX = -1.75, sizeY = 1.75, orientation = -0.15}, "out-quad", function() boyfriendIconTimer = Timer.tween((60 / bpm), boyfriendIcon, {sizeX = -1.5, sizeY = 1.5, orientation = 0}, "out-quad") end)
					end
				end
			end
		end
	end,

	doFlash = function(self)
		if not settings.noFlash then
			Timer.tween((60/bpm)/4, flash, {alpha = 1}, "linear", function() Timer.tween((60/bpm), flash, {alpha = 0}, "linear") end)
		end
	end,

	changeNotePos = function(self, who, note, time, x, y)
		who = who or "enemy"
		note = note or -1
		time = time or (60/bpm)
		x = x or 0
		y = y or 0

		if time == -1 then
			if who == "enemy" then
				if note == -1 then 
					for i = 1, 4 do 
						notesPos.enemy[i].x = x
						notesPos.enemy[i].y = y
					end
				else
					notesPos.enemy[note].x = x
					notesPos.enemy[note].y = y
				end
			elseif who == "boyfriend" then
				if note == -1 then 
					for i = 1, 4 do 
						notesPos.boyfriend[i].x = x
						notesPos.boyfriend[i].y = y
					end
				else
					notesPos.boyfriend[note].x = x
					notesPos.boyfriend[note].y = y
				end
			end
		else
			if who == "enemy" then
				if note == -1 then 
					for i = 1, 4 do 
						if notePosTweenEnemy[i] then 
							Timer.cancel(notePosTweenEnemy[i])
						end
						notePosTweenEnemy[i] = Timer.tween(time, notesPos.enemy[i], {x = x, y = y}, "out-quad")
					end
				else
					if notePosTweenEnemy[note] then 
						Timer.cancel(notePosTweenEnemy[note])
					end
					notePosTweenEnemy[note] = Timer.tween(time, notesPos.enemy[note], {x = x, y = y}, "out-quad")
				end
			elseif who == "boyfriend" then
				if note == -1 then 
					for i = 1, 4 do 
						if notePosTweenReceptors[i] then 
							Timer.cancel(notePosTweenReceptors[i])
						end
						notePosTweenReceptors[i] = Timer.tween(time, notesPos.boyfriend[i], {x = x, y = y}, "out-quad")
					end
				else
					if notePosTweenReceptors[note] then 
						Timer.cancel(notePosTweenReceptors[note])
					end
					notePosTweenReceptors[note] = Timer.tween(time, notesPos.boyfriend[note], {x = x, y = y}, "out-quad")
				end
			end
		end
	end,

	changeNoteTransparency = function(self, time, transparency, lane, who, withNotes, func)
		-- if lane is -1, do all lanes
		-- if withNotes is true, make the notes change transparency with it
		time = time or (60/bpm)
		transparency = transparency or 0
		withNotes = withNotes or false
		lane = lane or -1
		func = func or function() end
		who = who or "enemy"
		if who == "boyfriend" then
			if lane == -1 then 
				for i = 1, 4 do 
					if noteTransTweenReceptors[i] then 
						Timer.cancel(noteTransTweenReceptors[i])
					end
					if noteTransTweenNotes[i] then 
						Timer.cancel(noteTransTweenNotes[i])
					end
					noteTransTweenReceptors[i] = Timer.tween(time, noteTransparencyReceptors.boyfriend, {[i] = transparency}, "out-quad", func)
					if withNotes then noteTransTweenNotes[i] = Timer.tween(time, noteTransparencyNotes.boyfriend, {[i] = transparency}, "out-quad") end 
				end
			else
				if noteTransTweenReceptors[1] then 
					Timer.cancel(noteTransTweenReceptors[1])
				end
				if noteTransTweenNotes[1] then 
					Timer.cancel(noteTransTweenNotes[1])
				end
				noteTransTweenNotes[lane] = Timer.tween(time, noteTransparencyReceptors.boyfriend, {[lane] = transparency}, "out-quad", func)
				if withNotes then noteTransTweenNotes[lane] = Timer.tween(time, noteTransparencyNotes.boyfriend, {[lane] = transparency}, "out-quad") end 
			end
		else
			if lane == -1 then 
				for i = 1, 4 do 
					if noteTransTweenReceptors[i] then 
						Timer.cancel(noteTransTweenReceptors[i])
					end
					if noteTransTweenNotes[i] then 
						Timer.cancel(noteTransTweenNotes[i])
					end
					noteTransTweenReceptors[i] = Timer.tween(time, noteTransparencyReceptors.enemy, {[i] = transparency}, "out-quad", func)
					if withNotes then noteTransTweenNotes[i] = Timer.tween(time, noteTransparencyNotes.enemy, {[i] = transparency}, "out-quad") end 
				end
			else
				if noteTransTweenReceptors[1] then 
					Timer.cancel(noteTransTweenReceptors[1])
				end
				if noteTransTweenNotes[1] then 
					Timer.cancel(noteTransTweenNotes[1])
				end
				noteTransTweenNotes[lane] = Timer.tween(time, noteTransparencyReceptors.enemy, {[lane] = transparency}, "out-quad", func)
				if withNotes then noteTransTweenNotes[lane] = Timer.tween(time, noteTransparencyNotes.enemy, {[lane] = transparency}, "out-quad") end 
			end
		end
	end,

	zoomCamera = function(self, time, sizeX, sizeY, easeType, direct)
		if extraCamZoom then
			Timer.cancel(extraCamZoom)
		end
		if direct then
			theCamZoom = Timer.tween(
				time,
				extraCamZoom,
				{
					sizeX = sizeX,
					sizeY = sizeY
				},
				easeType
			)
		else
			theCamZoom = Timer.tween(
				time,
				extraCamZoom,
				{
					sizeX = extraCamZoom.sizeX + sizeX,
					sizeY = extraCamZoom.sizeY + sizeY
				},
				easeType
			)
		end
	end,

	drawRating = function(self, multiplier)
		love.graphics.push()
			if multiplier then
				love.graphics.translate(cam.x * multiplier, cam.y * multiplier)
			else
				love.graphics.translate(cam.x, cam.y)
			end

			graphics.setColor(1, 1, 1, ratingVisibility[1])

			rating:draw()

			if combo >= 100 then
				numbers[1]:draw()
			end
			if combo >= 10 then
				numbers[2]:draw()
			end
			numbers[3]:draw()
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end, -- i love men so much men just make me go wfhjlisdfjkl;jsdrfghnlkgbdehrsgnkadlufhgbkldashbfgoigabdfrsoliabdrsglkadjrshgpio9abejrsgn;kladsfjghlikhb 

	drawUI = function(self)
		love.graphics.push()
			graphics.setColor(1,1,1, flash.alpha)
			love.graphics.rectangle("fill", 0, 0, 1280, 720)
			graphics.setColor(1,1,1)
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end
			love.graphics.scale(uiScale.sizeX, uiScale.sizeY)

			for i = 1, 4 do
				if enemyArrows[i]:getAnimName() == "off" then
					graphics.setColor(0.6, 0.6, 0.6,noteTransparencyNotes.enemy[i])
				end
				if settings.middleScroll then
					graphics.setColor(0.6,0.6,0.6,(noteTransparencyNotes.enemy[i]-0.7))
				else
					if paused then 
						graphics.setColor(0.6,0.6,0.6,(noteTransparencyNotes.enemy[i]-0.7))
					else
						graphics.setColor(1,1,1,noteTransparencyNotes.enemy[i] )
					end
				end

				if not paused then
					if not settings.downscroll then
						enemyArrows[i]:udraw(1, 1, enemyArrows[i].x + notesPos.enemy[i].x, enemyArrows[i].y + notesPos.enemy[i].y)
					else
						enemyArrows[i]:udraw(1, -1, enemyArrows[i].x + notesPos.enemy[i].x, enemyArrows[i].y + notesPos.enemy[i].y)
					end
					
				end
				if paused then 
					graphics.setColor(0.6,0.6,0.6,(noteTransparencyNotes.boyfriend[i]-0.7))
				else
					graphics.setColor(1, 1, 1, (noteTransparencyNotes.boyfriend[i]))
				end
				if not paused then
					if not settings.downscroll then
						boyfriendArrows[i]:udraw(1, 1, boyfriendArrows[i].x + notesPos.boyfriend[i].x, boyfriendArrows[i].y + notesPos.boyfriend[i].y)
					else
						boyfriendArrows[i]:udraw(1, -1, boyfriendArrows[i].x + notesPos.boyfriend[i].x, boyfriendArrows[i].y + notesPos.boyfriend[i].y)
					end

				end
				if hitSick then
					if not settings.botPlay then
						if input:pressed("gameLeft") then
							leftArrowSplash:animate("left" .. love.math.random(1,2))
						elseif input:pressed("gameRight") then
							rightArrowSplash:animate("right" .. love.math.random(1,2))
						elseif input:pressed("gameUp") then
							upArrowSplash:animate("up" .. love.math.random(1,2))
						elseif input:pressed("gameDown") then
							downArrowSplash:animate("down" .. love.math.random(1,2))
						end
					else
						if boyfriendArrows[1]:getAnimName() == "confirm" then
							if wasReleased1 then
								leftArrowSplash:animate("left" .. love.math.random(1,2))
								wasReleased1 = false
							end
						end
						if boyfriendArrows[2]:getAnimName() == "confirm" then
							if wasReleased2 then
								downArrowSplash:animate("down" .. love.math.random(1,2))
								wasReleased2 = false
							end
						end
						if boyfriendArrows[3]:getAnimName() == "confirm" then
							if wasReleased3 then
								upArrowSplash:animate("up" .. love.math.random(1,2))
								wasReleased3 = false
							end
						end
						if boyfriendArrows[4]:getAnimName() == "confirm" then
							if wasReleased4 then
								rightArrowSplash:animate("right" .. love.math.random(1,2))
								wasReleased4 = false
							end
						end
					end
				end
				if settings.botPlay then
					if boyfriendArrows[1]:getAnimName() ~= "confirm" then
						wasReleased1 = true
					end
					if boyfriendArrows[2]:getAnimName() ~= "confirm" then
						wasReleased2 = true
					end
					if boyfriendArrows[3]:getAnimName() ~= "confirm" then
						wasReleased3 = true
					end
					if boyfriendArrows[4]:getAnimName() ~= "confirm" then
						wasReleased4 = true
					end
				end
				love.graphics.push()
					leftArrowSplash.orientation = notesPos.boyfriend[1].orientation
					downArrowSplash.orientation = notesPos.boyfriend[2].orientation
					upArrowSplash.orientation = notesPos.boyfriend[3].orientation
					rightArrowSplash.orientation = notesPos.boyfriend[4].orientation
					if not paused then
						if leftArrowSplash:isAnimated() then
							leftArrowSplash:draw(leftArrowSplash.x+notesPos.boyfriend[1].x, leftArrowSplash.y+notesPos.boyfriend[1].y)
						end
						if rightArrowSplash:isAnimated() then
							rightArrowSplash:draw(rightArrowSplash.x+notesPos.boyfriend[2].x, rightArrowSplash.y+notesPos.boyfriend[2].y)
						end
						if upArrowSplash:isAnimated() then
							upArrowSplash:draw(upArrowSplash.x+notesPos.boyfriend[3].x, upArrowSplash.y+notesPos.boyfriend[3].y)
						end
						if downArrowSplash:isAnimated() then
							downArrowSplash:draw(downArrowSplash.x+notesPos.boyfriend[4].x, downArrowSplash.y+notesPos.boyfriend[4].y)
						end
					end
				love.graphics.pop()
				
				love.graphics.push()
					love.graphics.translate(0, -musicPos)

					for j = #enemyNotes[i], 1, -1 do
						if ((-400 + enemyNotes[i][j].y * 0.6 * speed) - musicPos <= 560) then
							enemyNotes[i][j].orientation = notesPos.enemy[i].orientation
							local animName = enemyNotes[i][j]:getAnimName()

							if animName == "hold" or animName == "end" then
								graphics.setColor(1, 1, 1, 0.5)
							end
							if settings.middleScroll then
								graphics.setColor(1, 1, 1, 0.5)
							end
							if enemyNotes[i][j]:getAnimName() == "hold" then
								enemyNotes[i][j]:udraw(1, 1 * 1.7, enemyNotes[i][j].x + notesPos.enemy[i].x, -400 + enemyNotes[i][j].y * 0.6 * speed + notesPos.enemy[i].y)
							else
								enemyNotes[i][j]:udraw(1, enemyNotes[i][j].sizeY, enemyNotes[i][j].x + notesPos.enemy[i].x, -400 + enemyNotes[i][j].y * 0.6 * speed + notesPos.enemy[i].y)
							end
							graphics.setColor(1, 1, 1)
						end
					end
					for j = #boyfriendNotes[i], 1, -1 do
						if ((-400 + boyfriendNotes[i][j].y * 0.6 * speed) - musicPos <= 560) then
							boyfriendNotes[i][j].orientation = notesPos.boyfriend[i].orientation
							local animName = boyfriendNotes[i][j]:getAnimName()

							if animName == "hold" or animName == "end" then
								graphics.setColor(1, 1, 1, math.min(0.5, (500 + ((-400 + boyfriendNotes[i][j].y * 0.6 * speed) - musicPos)) / 150))
							else
								graphics.setColor(1, 1, 1, math.min(1, (500 + ((-400 + boyfriendNotes[i][j].y * 0.6 * speed) - musicPos)) / 75))
							end
				
							if boyfriendNotes[i][j]:getAnimName() == "hold" then
								boyfriendNotes[i][j]:udraw(1, 1 * 1.7, boyfriendNotes[i][j].x + notesPos.boyfriend[i].x, -400 + boyfriendNotes[i][j].y * 0.6 * speed + notesPos.boyfriend[i].y)
							else
								boyfriendNotes[i][j]:udraw(1, boyfriendNotes[i][j].sizeY, boyfriendNotes[i][j].x + notesPos.boyfriend[i].x, -400 + boyfriendNotes[i][j].y * 0.6 * speed + notesPos.boyfriend[i].y)
							end
						end
					end
					graphics.setColor(1, 1, 1)
				love.graphics.pop()
			end
			graphics.setColor(1, 1, 1, countdownFade[1])
			if not settings.downscroll then
				countdown:udraw(1, 1)
			else
				countdown:udraw(1, -1)
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,
	drawTimeLeftBar = function()
		love.graphics.push()
			graphics.setColor(0, 0, 0, 0.5)
			love.graphics.rectangle("fill", 0, 0, 1282, 25)
			graphics.setColor(1, 0, 0, 0.5)
			love.graphics.rectangle("fill", 0, 0, 1282 * (timeLeft / songLength), 25)
			graphics.setColor(1, 1, 1)
			-- center the text in the bar
			love.graphics.printf("Time Left: " .. timeLeftString, 0, 0, 1282, "center")
		love.graphics.pop()
	end,
	drawHealthBar = function()
		love.graphics.push()
			-- Scroll underlay
			love.graphics.push()
				graphics.setColor(0,0,0,settings.scrollUnderlayTrans)
				if settings.middleScroll then
					love.graphics.rectangle("fill", 400, -100, 90 + 170 * 2.35, 1000)
				else
					love.graphics.rectangle("fill", 755, -100, 90 + 170 * 2.35, 1000)
				end
				graphics.setColor(1,1,1,1)
			love.graphics.pop()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiScale.sizeX, uiScale.sizeY)
			graphics.setColor(enemy.colours[1]/255, enemy.colours[2]/255, enemy.colours[3]/255)
			love.graphics.rectangle("fill", -500, 350+downscrollOffset, 1000, 25)
			graphics.setColor(boyfriend.colours[1]/255, boyfriend.colours[2]/255, boyfriend.colours[3]/255)
			love.graphics.rectangle("fill", 500, 350+downscrollOffset, -health * 10, 25)
			graphics.setColor(0, 0, 0)
			love.graphics.setLineWidth(10)
			love.graphics.rectangle("line", -500, 350+downscrollOffset, 1000, 25)
			love.graphics.setLineWidth(1)
			graphics.setColor(1, 1, 1)

			boyfriendIcon:draw()
			enemyIcon:draw()
			graphics.setColor(uiTextColour[1],uiTextColour[2],uiTextColour[3])
			accForRatingText = (altScore / (noteCounter + missCounter))
			if accForRatingText >= 101 then
				ratingText = "what... how..."
			elseif accForRatingText >= 100 then
				ratingText = "PERFECT!!!"
			elseif accForRatingText >= 90 then
				ratingText = "Great!"
			elseif accForRatingText >= 70 then
				ratingText = "Good!"
			elseif accForRatingText >= 69 then
				ratingText = "Nice!"
			elseif accForRatingText >= 60 then
				ratingText = "Okay"
			elseif accForRatingText >= 50 then
				ratingText = "Meh..."
			elseif accForRatingText >= 40 then
				ratingText = "Could be better..."
			elseif accForRatingText >= 30 then
				ratingText = "It's an issue of skill."
			elseif accForRatingText >= 20 then
				ratingText = "Bad."
			elseif accForRatingText >= 10 then
				ratingText = "How."
			elseif accForRatingText >= 0 then
				ratingText = "Bruh."
			end -- Marvellous \
			if (altScore / (noteCounter + missCounter)) >= 100 and noteCounter + missCounter <= 0 then 
				convertedAcc = "0%"
			elseif (altScore / (noteCounter + missCounter)) >= 100 and not (noteCounter + missCounter <= 0) then
				convertedAcc = "100%"
			end
			if convertedAcc == "nan%" then
				convertedAcc = "0%"
			end
			if convertedAcc2 == "nan%" then
				convertedAcc2 = "0%"
			end

			if not settings.disableEnemyScore then
				uitextf("Opponent Score: " .. enemyScore .. " | Score: " .. score .. " | Misses: " .. missCounter .. " | Accuracy: " .. convertedAcc .. " | Rating: " .. (ratingText or "???"), -600, 400+downscrollOffset, 1200, "center")
			else
				uitextf("Score: " .. score .. " | Misses: " .. missCounter .. " | Accuracy: " .. convertedAcc .. " | Rating: " .. (ratingText or "???"), -600, 400+downscrollOffset, 1200, "center")
			end

			if settings.botPlay then
				botplayY = botplayY + math.sin(love.timer.getTime()) * 0.15
				uitext("BOTPLAY", -85, botplayY, 0, 2, 2, 0, 0, 0, 0, botplayAlpha[1])
			end

			if settings.sideJudgements then
				uitextf(
					"Sicks: " .. sicks ..
					"\n\nGoods: " .. goods ..
					"\n\nBads: " .. bads ..
					"\n\nShits: " .. shits ..
					"\n\nTotal: " .. (sicks + goods + bads + shits),
					-900,
					0, 
					750, -- annoying limit and i don't want to test if it works with nil 
					"left"
				)
			end
		love.graphics.pop()
		if settings.keystrokes then
			love.graphics.push()
				love.graphics.scale(uiScale.sizeX, uiScale.sizeY)
				-- keystrokes
				graphics.setColor(1, 1, 1)

				if input:down("gameUp") then
					love.graphics.rectangle("fill", 131, 631, 30, 30) 
				end
				
				if input:down("gameDown") then
					love.graphics.rectangle("fill", 100, 631, 30, 30)
				end
				
				if input:down("gameRight") then
					love.graphics.rectangle("fill", 162, 631, 30, 30)
				end
								
				if input:down("gameLeft") then
					love.graphics.rectangle("fill", 69, 631, 30, 30)
				end
				
				graphics.setColor(0, 0, 0)

				love.graphics.rectangle("line", 69, 631, 30, 30) -- left
				love.graphics.rectangle("line", 100, 631, 30, 30) -- down
				love.graphics.rectangle("line", 131, 631, 30, 30) -- up
				love.graphics.rectangle("line", 162, 631, 30, 30) -- right

				love.graphics.printf(customBindLeft, 74, 626, 20, "left", nil, 1.5, 1.5)  -- left
				love.graphics.printf(customBindDown, 105, 626, 20, "left", nil, 1.5, 1.5)  -- down
				love.graphics.printf(customBindUp, 136, 626, 20, "left", nil, 1.5, 1.5)  -- up
				love.graphics.printf(customBindRight, 167, 626, 20, "left", nil, 1.5, 1.5)  -- right

				graphics.setColor(1, 1, 1)
			love.graphics.pop()
		end
		love.graphics.push()
			love.graphics.setFont(pauseFont)
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			if paused then
				graphics.setColorF(pauseColor[1], pauseColor[2], pauseColor[3])
				if week == 5 then
					love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
					love.graphics.scale(0.7, 0.7)
					love.graphics.scale(uiScale.sizeX, uiScale.sizeY)
				end
				graphics.setColor(0, 0, 0, 0.8)
				love.graphics.rectangle("fill", -10000, -2000, 25000, 10000)
				graphics.setColor(1, 1, 1)
				pauseShadow:draw()
				pauseBG:draw()
				if pauseMenuSelection ~= 1 then
					uitextflarge("Resume", -305, -275, 600, "center", false)
				else
					uitextflarge("Resume", -305, -275, 600, "center", true)
				end
				if pauseMenuSelection ~= 2 then
					uitextflarge("Restart", -305, -75, 600, "center", false)
					--  -600, 400+downscrollOffset, 1200, "center"
				else
					uitextflarge("Restart", -305, -75, 600, "center", true)
				end
				if pauseMenuSelection ~= 3 then
					uitextflarge("Quit", -305, 125, 600, "center", false)
				else
					uitextflarge("Quit", -305, 125, 600, "center", true)
				end
			end
			love.graphics.setFont(font)
		love.graphics.pop()
	end,

	drawDialogue = function()
		if pixel then love.graphics.setFont(pixelFont)
		else love.graphics.setFont(font) end
		uitextf(output, 150, 435, 200, "left", 0, 4.7, 4.7)
	end,

	leave = function(self)
		if inst then inst:stop() end
		voices:stop()
		uiTextColour = {1,1,1}
		extraCamZoom.sizeX = 1
		extraCamZoom.sizeY = 1

		Timer.clear()

		fakeBoyfriend = nil
		died = false
		modFolderMod = false
	end
}
