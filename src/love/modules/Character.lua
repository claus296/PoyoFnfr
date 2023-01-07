local character = {}

function character.poyo(x, y)
    curEnemy = "poyo"
    local char = paths.sprite(x or 0, y or 0, "city/poyospr")
    char:addByPrefix("idle", "poyo idle", 24, false)

    char:addByPrefix("left", "poyo left", 24, false)
    char:addByPrefix("right", "poyo right", 24, false)
    char:addByPrefix("up", "poyo up", 24, false)
    char:addByPrefix("down", "poyo down", 24, false)

    char:addOffset("idle",  275, 0   )

    char:addOffset("left", 275, 0  )
    char:addOffset("right", 275, 0  )
    char:addOffset("up",   275, 0  )
    char:addOffset("down",  275, 0 )

    char:animate("idle", false)

    char.colours = {175,102,206}

    return char
end

function character.boyfriend(x, y)
    curPlayer = "boyfriend"
    local char = paths.sprite(x or 0, y or 0, "city/newbfpoyo")
    char:addByPrefix("idle", "BF idle dance", 24, false)

    char:addByPrefix("left", "BF NOTE LEFT", 24, false)
    char:addByPrefix("right", "BF NOTE RIGHT", 24, false)
    char:addByPrefix("up", "BF NOTE UP", 24, false)
    char:addByPrefix("down", "BF NOTE DOWN", 24, false)

    char:addOffset("idle",      300, 240      )

    char:addOffset("left",   300, 240        )
    char:addOffset("right", 300, 240       )
    char:addOffset("up",    300, 240       )
    char:addOffset("down",  300, 240      )

    char:animate("idle", false)

    char.colours = {49,176,209}

    return char
end

function character.girlfriend(x, y, isEnemy)
    if isEnemy then
        curEnemy = "girlfriend"
    end
    local char = paths.sprite(x or 0, y or 0, "GF_assets")
    char:addByPrefix("idle", "GF Dancing Beat", 24, false)
    char:addByPrefix("sad", "gf sad", 24, false)
    char:addByPrefix("fear", "GF FEAR ", 24, false)
    char:addByPrefix("cheer", "GF Cheer", 24, false)

    char:addByPrefix("left", "GF left note", 24, false)
    char:addByPrefix("right", "GF Right Note", 24, false)
    char:addByPrefix("up", "GF Up Note", 24, false)
    char:addByPrefix("down", "GF Down Note", 24, false)

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
    local char = paths.sprite(x or 0, y or 0, "luigi")
    char:addByPrefix("idle", "luigi idle", 24, false)

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