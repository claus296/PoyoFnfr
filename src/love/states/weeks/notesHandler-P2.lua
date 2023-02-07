local addJudgements
function addJudgements(givenRating)
    local judgementRating = givenRating
    if not pixel then
        table.insert(judgements.enemy, {
            img = love.filesystem.load("sprites/rating.lua")(),
            rating = judgementRating,
            transparency = 1
        })
    else
        table.insert(judgements.enemy, {
            img = love.filesystem.load("sprites/pixel/rating.lua")(),
            rating = judgementRating,
            transparency = 1
        })
    end
    judgements.enemy[#judgements.enemy].img:animate(judgements.enemy[#judgements.enemy].rating, false)
    judgements.enemy[#judgements.enemy].img.x = girlfriend.x
    judgements.enemy[#judgements.enemy].img.y = girlfriend.y - 100
    if not pixel then judgements.enemy[#judgements.enemy].img.sizeX, judgements.enemy[#judgements.enemy].img.sizeY = 0.75
        , 0.75 end
    judgements.enemy[#judgements.enemy].img.offsetX = 150
end

return {
    updateUI = function(self, dt)
        for i = 1, 4 do
            local curInput = inputList2[i]
            local curAnim = animList[i]
            local enemyNote = enemyNotes[i]
            local enemyArrow = enemyArrows[i]
            if #enemyNote > 0 then
                if not countingDown then
                    if ((-400 + enemyNote[1].y * 0.6 * speed) - (musicPos or 0) < -575) then
                        if inst then voices:setVolume(0) end

                        notMissed[noteNum] = false
                        if not settings.noMiss then
                            if enemyNote[1]:getAnimName() ~= "hold" and enemyNote[1]:getAnimName() ~= "end" then
                                health = health + 2
                            end
                        else
                            health = 0
                        end
                        if enemyNote[1]:getAnimName() ~= "hold" and enemyNote[1]:getAnimName() ~= "end" then
                            missCounter2 = missCounter2 + 1
                        end

                        table.remove(enemyNote, 1)z

                        hitSick = false

                        combo2 = 0
                    end
                end
            end

            if input:down(curInput) then
                holdingInput = true
            else
                holdingInput = false
            end

            if input:pressed(curInput) then
                enemyArrow:animate("press", false)
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

                if #enemyNote > 0 then
                    if enemyNote[1] and enemyNote[1]:getAnimName() == "on" then
                        if (math.abs(enemyNote[1].y - musicTime) < 100) then
                            notePos = math.abs(enemyNote[1].y - musicTime)
                            local ratingAnim

                            notMissed[noteNum] = true

                            voices:setVolume(1)

                            if notePos <= 15 then -- "Sick Plus" Note: Just for a cooler looking rating. Does not give anything special
                                score2 = score2 + 350
                                addJudgements("sickPlus")
                                altScore2 = altScore2 + 100.00
                            elseif notePos <= 35 then -- "Sick"
                                score2 = score2 + 350
                                addJudgements("sick")
                                altScore2 = altScore2 + 100.00
                            elseif notePos <= 50 then -- "Good"
                                score2 = score2 + 200
                                addJudgements("good")
                                altScore2 = altScore2 + 66.66
                            elseif notePos <= 80 then -- "Bad"
                                score2 = score2 + 100
                                addJudgements("bad")
                                altScore2 = altScore2 + 33.33
                            else -- "Shit"
                                if settings.ghostTapping then
                                    success = false
                                else
                                    score2 = score2 + 50
                                end
                                altScore2 = altScore2 + 1.11
                                addJudgements("shit")
                            end

                            combo2 = combo2 + 1

                            --rating:animate(ratingAnim, false)
                            numbers2[1]:animate(tostring(math.floor(combo2 / 100 % 10), false)) -- 100's
                            numbers2[2]:animate(tostring(math.floor(combo2 / 10 % 10), false)) -- 10's
                            numbers2[3]:animate(tostring(math.floor(combo2 % 10), false)) -- 1's

                            for i = 3, 5 do
                                if ratingTimers[i] then Timer.cancel(ratingTimers[i]) end
                            end -- ratingTimer 1&2 is judgements

                            ratingVisibility[1] = 1
                            judgements.enemy[#judgements.enemy].img.y = girlfriend.y - 50
                            for i = 1, 3 do
                                numbers2[i].y = girlfriend.y + 50
                            end

                            --ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
                            Timer.tween(
                                1.1,
                                judgements.enemy[#judgements.enemy],
                                {
                                    transparency = 0
                                },
                                "linear"
                            )
                            Timer.tween(
                                1.25,
                                judgements.enemy[#judgements.enemy].img,
                                {
                                    y = girlfriend.y - 100
                                },
                                "out-expo"
                            )
                            --ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
                            if combo2 >= 100 then
                                ratingTimers[3] = Timer.tween(2, numbers2[1],
                                    { y = girlfriend.y + love.math.random(-10, 10) }, "out-elastic") -- 100's
                            end
                            if combo2 >= 10 then
                                ratingTimers[4] = Timer.tween(2, numbers2[2],
                                    { y = girlfriend.y + love.math.random(-10, 10) }, "out-elastic") -- 10's
                            end
                            ratingTimers[5] = Timer.tween(2, numbers2[3], { y = girlfriend.y + love.math.random(-10, 10) }
                                , "out-elastic") -- 1's

                            if combo2 < 10 then
                                numbers2[3].x = girlfriend.x
                            elseif combo2 < 100 then
                                numbers2[2].x = girlfriend.x - 25
                                numbers2[3].x = girlfriend.x + 25
                            else
                                numbers2[1].x = girlfriend.x - 50
                                numbers2[2].x = girlfriend.x
                                numbers2[3].x = girlfriend.x + 50
                            end
                            if not settings.ghostTapping or success then
                                enemyArrow:animate("confirm", false)

                                if useAltAnims then
                                    weeks:safeAnimate(enemy, curAnim .. " alt", false, 2)
                                else
                                    weeks:safeAnimate(enemy, curAnim, false, 2)
                                end
                                doingAnim = false

                                if not settings.noMiss then
                                    if enemyNote[1]:getAnimName() ~= "hold" or enemyNote[1]:getAnimName() ~= "end" then
                                        health = health - 1
                                    end
                                else
                                    health = 0
                                end

                                health = health + 1
                                if enemyNote[1]:getAnimName() ~= "hold" or enemyNote[1]:getAnimName() ~= "end" then
                                    noteCounter2 = noteCounter2 + 1
                                end

                                success = true
                            end
                            table.remove(enemyNote, 1)
                        else
                            if not settings.ghostTapping then
                                success = false
                            end
                        end
                    end

                    if not success then
                        if not countingDown then
                            audio.playSound(sounds.miss[love.math.random(3)])

                            notMissed[noteNum] = false

                            if enemy:isAnimName("miss " .. curAnim) then weeks:safeAnimate(enemy, "miss " .. curAnim,
                                false, 3) end

                            hitSick = false

                            score2 = score2 - 10
                            combo2 = 0
                            if not settings.noMiss then
                                health = health + 1
                            else
                                health = 0
                            end
                            missCounter2 = missCounter2 + 1
                        end
                    end
                end
            end

            if input:down(curInput) then
                holdingInput = true
            else
                holdingInput = false
            end

            if enemyNote[1] then
                if notMissed[noteNum] and #enemyNote > 0 and input:down(curInput) and ((enemyNote[1].y - musicTime <= 0)) and
                    (enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end") then
                    voices:setVolume(1)

                    enemyArrow:animate("confirm", false)

                    if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
                        if useAltAnims then
                            weeks:safeAnimate(enemy, curAnim .. " alt", true, 2)
                        else
                            weeks:safeAnimate(enemy, curAnim, true, 2)
                        end
                    else
                        if useAltAnims then
                            weeks:safeAnimate(enemy, curAnim .. " alt", false, 2)
                        else
                            weeks:safeAnimate(enemy, curAnim, false, 2)
                        end
                    end

                    table.remove(enemyNote, 1)
                end
            end

            if input:released(curInput) then
                modchartHandler:onKeyReleased(curInput)
                enemyArrow:animate("off", false)
            end
        end
    end,

    drawRating = function(self)
        love.graphics.push()
        if not pixel then
            if judgements.enemy[1] then
                for i = 1, #judgements.enemy do
                    graphics.setColor(1, 1, 1, judgements.enemy[i].transparency)
                    judgements.enemy[i].img:draw()
                end
            end
            if combo2 >= 5 then
                if combo2 >= 100 then
                    numbers2[1]:draw()
                end
                if combo2 >= 10 then
                    numbers2[2]:draw()
                end
                numbers2[3]:draw()
            end
        else
            if judgements.enemy[1] then
                for i = 1, #judgements.enemy do
                    graphics.setColor(1, 1, 1, judgements.enemy[i].transparency)
                    judgements.enemy[i].img:udraw(6, 6)
                end
            end
            if combo2 >= 5 then
                if combo2 >= 100 then
                    numbers2[1]:udraw(6, 6)
                end
                if combo2 >= 10 then
                    numbers2[2]:udraw(6, 6)
                end
                numbers2[3]:udraw(6, 6)
            end
        end
        graphics.setColor(1, 1, 1)
        love.graphics.pop()
    end
}
