local curDir, dirTable
local BASE = ... .. "."
return {
    load = function(self)
        playModMenu = require(BASE .. "playModMenu")
        if not love.filesystem.getInfo("mods", "directory") then
            love.filesystem.createDirectory("mods")
        end
        dirTable = love.filesystem.getDirectoryItems("mods")
        for i = 1, #dirTable do
            --print(love.filesystem.getInfo("mods/" .. dirTable[i], "directory"))
            if love.filesystem.getInfo("mods/" .. dirTable[i] .. "/meta.lua") then
                mods[i] = require("mods." .. dirTable[i] .. ".meta")
                mods[i]:setModName()
                mods[i]:setWeekMeta()
                mods[i]:setWeek()
                mods[i]:setStage()
            elseif love.filesystem.getInfo("mods/" .. dirTable[i] .. "/pack.json") then
                -- is psych mod lol
                -- GRAHHHHHHH I HATE PSYCH MODS!!!!!!!!!!!!!!!!!!!!!!!!!
                local psychJson = json.decode(love.filesystem.read("mods/" .. dirTable[i] .. "/pack.json"))
                table.insert(mods.modNames, psychJson.name)
                table.insert(mods.psychModLocations, dirTable[i])
                ballsTable = love.filesystem.getDirectoryItems("mods/" .. dirTable[i] .. "/songs")
                for j = 1, #ballsTable do
                    if ballsTable[j] ~= "readme.txt" then
                        table.insert(mods.weekMeta, {psychJson.name, {ballsTable[j]}})
                        table.insert(mods.psychShit, {
                            "mods/" .. dirTable[i] .. "/songs/" .. ballsTable[j]
                        })
                        table.insert(mods.psychDataShit, {
                            "mods/" .. dirTable[i] .. "/data/" .. ballsTable[j] .. "/" .. ballsTable[j]
                        })
                        print("mods/" .. dirTable[i] .. "/songs/" .. ballsTable[j])
                        if love.filesystem.getInfo("mods/" .. dirTable[i] .. "/data/" .. ballsTable[j] .. "/events.json") then 
                            --print("mods/" .. dirTable[i] .. "/data/" .. ballsTable[j] .. "/events.json")
                            table.insert(mods.psychEvents, {"mods/" .. dirTable[i] .. "/data/" .. ballsTable[j] .. "/events.json"})
                        else
                            table.insert(mods.psychEvents, {""})
                        end
                    end
                end
                charsTable = love.filesystem.getDirectoryItems("mods/" .. dirTable[i] .. "/characters")
                for j = 1, #charsTable do
                    -- psych character files are json files that set all animations with the anim name and xml
                    -- check if charsTable is a json file
                    if charsTable[j]:sub(-5) == ".json" then
                        local charJson = json.decode(love.filesystem.read("mods/" .. dirTable[i] .. "/characters/" .. charsTable[j]))
                        local charFunc = function()
                            local char = sprite(0, 0)
                            print("mods/" .. dirTable[i] .. "/" .. charJson.image:gsub("characters", "images/characters"))
                            char:setFrames(paths.getModSparrowFrames("mods/" .. dirTable[i] .. "/" .. charJson.image:gsub("characters", "images/characters")))
                            char.json = charJson

                            for o = 1, #char.json.animations do
                                local anim = char.json.animations[o]
                                local animname = anim.name
                                local animanim = anim.anim
                                if animanim == "singLEFT" then animanim = "left" 
                                    elseif animanim == "singRIGHT" then animanim = "right"
                                    elseif animanim == "singUP" then animanim = "up"
                                    elseif animanim == "singDOWN" then animanim = "down"
                                end
                                print(animanim, anim.name, anim.fps)
                                char:addAnimByPrefix(animanim, animname, anim.fps)
                                char:addOffset(animanim, anim.offsets[1], anim.offsets[2])
                                char.colours = char.json.healthbar_colors
                            end
                            char:animate("idle", false)
                            return char

                        end
                        mods.psychChars[charsTable[j]:sub(1, -6)] = charFunc
                    end
                end

                local stagesTable = love.filesystem.getDirectoryItems("mods/" .. dirTable[i] .. "/stages")
                for j = 1, #stagesTable do
                    if stagesTable[j]:sub(-5) == ".json" then
                        table.insert(mods.psychStages, {
                            "mods/" .. dirTable[i] .. "/stages/" .. stagesTable[j],
                            "mods/" .. dirTable[i] .. "/stages/" .. stagesTable[j]:sub(1, -6) .. ".lua"
                        })
                        print(mods.psychStages[#mods.psychStages][1] .. " | " .. mods.psychStages[#mods.psychStages][2])
                    end
                end

                table.insert(mods.WeekData, require "weeks.psychMod")
            end
        end
    end
}
