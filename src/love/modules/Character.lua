local character = {}

function character.poyo(x, y)
    curEnemy = "poyo"
    local char = sprite(x or 0, y or 0)
    char:setFrames(paths.getSparrowFrames("city/poyospr"))
    char:addAnimByPrefix("idle", "poyo idle", 12, false)

    char:addAnimByPrefix("left", "poyo left", 12, false)
    char:addAnimByPrefix("right", "poyo right", 12, false)
    char:addAnimByPrefix("up", "poyo up", 12, false)
    char:addAnimByPrefix("down", "poyo down", 12, false)

    char:addOffset("idle",  0, 0   )

    char:addOffset("left", 52, 4  )
    char:addOffset("right", 40, 12  )
    char:addOffset("up",   20, 0  )
    char:addOffset("down",  0, 5 )

    char:animate("idle", false)

    char.colours = {255,180,200}

    return char
end

function character.poyoOld(x, y)
    curEnemy = "poyoOld"
    local char = sprite(x or 0, y or 0)
    char:setFrames(paths.getSparrowFrames("city-old/poyolmao"))
    char:addAnimByPrefix("idle", "Idle", 16, false)

    char:addAnimByPrefix("left", "Right", 8, false)
    char:addAnimByPrefix("right", "Left", 8, false)
    char:addAnimByPrefix("up", "Up", 8, false)
    char:addAnimByPrefix("down", "Down", 8, false)

    char:addOffset("idle",  0, 0      )

    char:addOffset("left",  178, -9   )
    char:addOffset("right",  53, -6   )
    char:addOffset("up",     94, -29  )
    char:addOffset("down",   -9, -72  )

    char:animate("idle", false)

    char.flipX = true

    char.colours = {255,180,200}

    return char
end

function character.boyfriend(x, y)
    curPlayer = "newBF"
    local char = sprite(x or 0, y or 0)
    char:setFrames(paths.getSparrowFrames("city/newbfpoyo"))
    char:addAnimByPrefix("idle", "BF idle dance", 12, false)

    char:addAnimByPrefix("left", "BF NOTE LEFT", 12, false)
    char:addAnimByPrefix("right", "BF NOTE RIGHT", 12, false)
    char:addAnimByPrefix("up", "BF NOTE UP", 12, false)
    char:addAnimByPrefix("down", "BF NOTE DOWN", 12, false)

    char:addOffset("idle",   0, 0     )

    char:addOffset("left",  -1, 7     )
    char:addOffset("right", -3, 2     )
    char:addOffset("up",     0, 4     )
    char:addOffset("down",  -15, 18   )

    char:animate("idle", false)

    char.colours = {49,176,209}

    return char
end

function character.girlfriend(x, y, isEnemy)
    if isEnemy then
        curEnemy = "girlfriend"
    end
    local char = sprite(x or 0, y or 0)
    char:setFrames(paths.getSparrowFrames("GF_assets"))
    char:addAnimByPrefix("idle", "GF Dancing Beat", 24, false)
    char:addAnimByPrefix("sad", "gf sad", 24, false)
    char:addAnimByPrefix("fear", "GF FEAR ", 24, false)
    char:addAnimByPrefix("cheer", "GF Cheer", 24, false)

    char:addAnimByPrefix("left", "GF left note", 24, false)
    char:addAnimByPrefix("right", "GF Right Note", 24, false)
    char:addAnimByPrefix("up", "GF Up Note", 24, false)
    char:addAnimByPrefix("down", "GF Down Note", 24, false)

    char:addOffset("idle",  0, 0    )
    char:addOffset("sad",  -2, -21  )
    char:addOffset("fear",  -2, -17 )
    char:addOffset("cheer",  3, 0   )

    char:addOffset("left",  0, -19  )
    char:addOffset("right", 0, -20  )
    char:addOffset("up",    0, 4    )
    char:addOffset("down",  0, -20  )

    char:animate("idle", false)

    char.colours = {165,0,77}

    return char
end

function character.luigi(x, y)
    local char = sprite(x or 0, y or 0)
    char:setFrames(paths.getSparrowFrames("luigi"))
    char:addAnimByPrefix("idle", "luigi idle", 24, false)

    char:addOffset("idle")

    char:animate("idle", false)

    return char
end

character.list = {
    {"Boyfriend", character.boyfriend},
    {"Girlfriend", character.girlfriend},
    {"Poyo", character.poyo},
    {"Luigi", character.luigi}
}

return character