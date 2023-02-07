local addJudgements
function addJudgements(givenRating)
    local judgementRating = givenRating

    if not pixel then
        table.insert(judgements.boyfriend, {
            img = love.filesystem.load("sprites/rating.lua")(),
            rating = judgementRating,
            transparency = 1
        })
    else
        table.insert(judgements.boyfriend, {
            img = love.filesystem.load("sprites/pixel/rating.lua")(),
            rating = judgementRating,
            transparency = 1
        })
    end
    judgements.boyfriend[#judgements.boyfriend].img:animate(judgements.boyfriend[#judgements.boyfriend].rating, false)
    judgements.boyfriend[#judgements.boyfriend].img.x = girlfriend.x
    judgements.boyfriend[#judgements.boyfriend].img.y = girlfriend.y - 100
    if not pixel then judgements.boyfriend[#judgements.boyfriend].img.sizeX, judgements.boyfriend[#judgements.boyfriend].img.sizeY = 0.75, 0.75 end
    judgements.boyfriend[#judgements.boyfriend].img.offsetX = -150
end

return {
    updateUI = function(self, dt)
        for i = 1, 4 do 
            local curInput = inputList[i]
            local curAnim = animList[i]
            local boyfriendNote = boyfriendNotes[i]
            local boyfriendArrow = boyfriendArrows[i]
            if #boyfriendNote > 0 then
                if not countingDown then
                    if ((-400 + boyfriendNote[1].y * 0.6 * speed) - (musicPos or 0) < -575) then
                        if not settings.botPlay then
                            if inst then voices:setVolume(0) end

                            notMissed[noteNum] = false
                            if not settings.noMiss then
                                if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then
                                    health = health - 2
                                end
                            else
                                health = 0
                            end
                            if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then
                                missCounter = missCounter + 1
                            end

                            table.remove(boyfriendNote, 1)

                            if girlfriend:isAnimName("sad") then if combo >= 5 then weeks:safeAnimate(girlfriend, "sad", true, 1) end end

                            hitSick = false

                            combo = 0
                        end
                    end
                end
            end

            if input:down(curInput) then
                holdingInput = true
            else
                holdingInput = false
            end

            if input:pressed(curInput) then
                boyfriendArrow:animate("press", false)
                if settings.Hitsounds then
                    if sounds.Hitsounds[#sounds.Hitsounds]:isPlaying() then
                        sounds.Hitsounds[#sounds.Hitsounds] = sounds.Hitsounds[#sounds.Hitsounds]:clone()
                        sounds.Hitsounds[#sounds.Hitsounds]:play()
                    else
                        sounds.Hitsounds[#sounds.Hitsounds]:play()
                    end
                    for hit = 2, #sounds.Hitsounds do
                        if not sounds.Hitsounds[hit]:isPlaying() then
                            sounds.Hitsounds[hit] = nil -- Nil afterwords to prevent memory leak
                        end --                             maybe, idk how love2d works lmfao
                    end
                end
                local success = false

                if settings.ghostTapping then
                    success = true
                    hitSick = false
                end

                modchartHandler:onKeyPressed(curInput)

                if #boyfriendNote > 0 then
                    if boyfriendNote[1] and boyfriendNote[1]:getAnimName() == "on" then
                        if (math.abs(boyfriendNote[1].y - musicTime) < 100) then
                            notePos = math.abs(boyfriendNote[1].y - musicTime)
                            local ratingAnim

                            notMissed[noteNum] = true

                            voices:setVolume(1)

                            if notePos <= 15 then -- "Sick Plus" Note: Just for a cooler looking rating. Does not give anything special
                                score = score + 350
                                addJudgements("sickPlus")
                                altScore = altScore + 100.00
                                sicks = sicks + 1
                                hitSick = true
                            elseif notePos <= 35 then -- "Sick"
                                score = score + 350
                                addJudgements("sick")
                                altScore = altScore + 100.00
                                sicks = sicks + 1
                                hitSick = true
                            elseif notePos <= 50 then -- "Good"
                                score = score + 200
                                addJudgements("good")
                                altScore = altScore + 66.66
                                goods = goods + 1
                                hitSick = false
                            elseif notePos <= 80 then -- "Bad"
                                score = score + 100
                                addJudgements("bad")
                                altScore = altScore + 33.33
                                bads = bads + 1
                                hitSick = false
                            else -- "Shit"
                                if settings.ghostTapping then
                                    success = false
                                else
                                    score = score + 50
                                 end
                                altScore = altScore + 1.11
                                addJudgements("shit")
                                shits = shits + 1
                                hitSick = false
                            end

                            combo = combo + 1

                            --rating:animate(ratingAnim, false)
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
                            if not settings.ghostTapping or success then
                                boyfriendArrow:animate("confirm", false)

                                weeks:safeAnimate(boyfriend, curAnim, false, 3)
                                doingAnim = false

                                if not settings.noMiss then
                                    if boyfriendNote[1]:getAnimName() ~= "hold" or boyfriendNote[1]:getAnimName() ~= "end" then
                                        health = health + 1
                                    end
                                else
                                    health = 0
                                end

                                health = health + 1
                                if boyfriendNote[1]:getAnimName() ~= "hold" or boyfriendNote[1]:getAnimName() ~= "end" then
                                    noteCounter = noteCounter + 1
                                end

                                success = true
                            end
                            table.remove(boyfriendNote, 1)
                        else
                            if not settings.ghostTapping then
                                success = false
                            end
                        end
                    end

                    if not success then
                        if not countingDown then
                            if not settings.botPlay then
                                audio.playSound(sounds.miss[love.math.random(3)])
    
                                notMissed[noteNum] = false
    
                                if girlfriend:isAnimName("sad") then if combo >= 5 then weeks:safeAnimate(girlfriend, "sad", true, 1) end end
    
                                weeks:safeAnimate(boyfriend, "miss " .. curAnim, false, 3)
    
                                hitSick = false
    
                                score = score - 10
                                combo = 0
                                if not settings.noMiss then
                                    health = health - 1
                                else
                                    health = 0
                                end
                                missCounter = missCounter + 1
                            end
                        end
                    end
                end
            end

            if input:down(curInput) then
                holdingInput = true
            else
                holdingInput = false
            end

            if notMissed[noteNum] and #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y - musicTime <= 0)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
                voices:setVolume(1)
    
                table.remove(boyfriendNote, 1)
    
                boyfriendArrow:animate("confirm", false)
    
                weeks:safeAnimate(boyfriend, curAnim, true, 3)
            end
    
            if input:released(curInput) then
                modchartHandler:onKeyReleased(curInput)
                boyfriendArrow:animate("off", false)
            end
        end
    end,

    drawRating = function(self)
        if settings.middleScroll then
            love.graphics.translate(400, 0)
        end
        love.graphics.push()
            if not pixel then
                if judgements.boyfriend[1] then
                    for i = 1, #judgements.boyfriend do
                        graphics.setColor(1, 1, 1, judgements.boyfriend[i].transparency)
                        judgements.boyfriend[i].img:draw()
                    end
                end
                if combo >= 5 then
                    if combo >= 100 then
                        numbers[1]:draw()
                    end
                    if combo >= 10 then
                        numbers[2]:draw()
                    end
                    numbers[3]:draw()
                end
            else
                if judgements.boyfriend[1] then
                    for i = 1, #judgements.boyfriend do
                        graphics.setColor(1, 1, 1, judgements.boyfriend[i].transparency)
                        judgements.boyfriend[i].img:udraw(6,6)
                    end
                end
                if combo >= 5 then
                    if combo >= 100 then
                        numbers[1]:udraw(6,6)
                    end
                    if combo >= 10 then
                        numbers[2]:udraw(6,6)
                    end
                    numbers[3]:udraw(6,6)
                end
            end
            graphics.setColor(1, 1, 1)
        love.graphics.pop()
    end
}