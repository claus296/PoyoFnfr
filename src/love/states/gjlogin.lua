return {
    enter = function(self)
        username = ""
        token = ""
        usernameInput = true
        passwordInput = false
        graphics.fadeIn(0.5)
    end,

    update = function(self, dt)
        
    end,

    keypressed = function(self, key)
        if usernameInput then
            if key == "backspace" then
                username = string.sub(username, 1, -2)
            elseif key == "return" then
                usernameInput = false
                passwordInput = true
            else
                -- cancel out all special characters
                if key ~= "lctrl" and key ~= "rctrl" and key ~= "lalt" and key ~= "ralt" and key ~= "lmeta" and key ~= "rctrl" and key ~= "lctrl" and key ~= "ralt" and key ~= "lalt" and key ~= "rmeta" and key ~= "lmeta" and key ~= "lsuper" and key ~= "rsuper" and key ~= "mode" and key ~= "compose" and key ~= "pause" and key ~= "printscreen" and key ~= "escape" and key ~= "help" then
                    if not love.keyboard.isDown("lshift") then
                        if key ~= "lshift" then
                            username = username .. key
                        end
                    else
                        if key ~= "lshift" then
                            username = username .. string.upper(key)
                        end
                    end
                end
            end
        elseif passwordInput then
            if key == "backspace" then
                token = string.sub(token, 1, -2)
            elseif key == "return" then
                status.setLoading(true)
                graphics.fadeOut(0.5,
                function()
                    Gamestate.switch(menu)
                    status.setLoading(false)
                end)
            else
                token = token .. key
            end
        end
    end,

    draw = function(self)
        love.graphics.print("Username: " .. username, 0, 0)
        love.graphics.print("Token: " .. token, 0, 20)
    end,

    leave = function(self)
        gamejoltLogin["username"] = username
        gamejoltLogin["token"] = token
        local file = love.filesystem.newFile("gamejoltLogin")
		file:open("w")
		file:write(lume.serialize(gamejoltLogin))
		file:close()
        success = gamejolt.authUser(username, token)
        if success then
            gamejoltSupport = true
            gamejoltLogin["useGamejolt"] = true
        else
            gamejoltSupport = false
            gamejoltLogin["useGamejolt"] = false
        end
    end
}