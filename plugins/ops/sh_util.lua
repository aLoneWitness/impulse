local setHealthCommand = {
    description = "Sets health of the specified player.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local firstArg = arg[1]
        local secondArg = arg[2]

        if tonumber(firstArg) then
            ply:SetHealth(firstArg)
            ply:Notify("You set your own health to " ..firstArg)
        elseif type(firstArg) == "string" then
            if tonumber(secondArg) then
                local target = impulse.FindPlayer(firstArg)
                target:Notify("Your health has been set to " ..secondArg)
                target:SetHealth(secondArg)
            end
        end
    end
}

impulse.RegisterChatCommand("/sethealth", setHealthCommand)

local kickCommand = {
    description = "Kicks the specified player from the server.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local plyTarget = impulse.FindPlayer(name)

        local reason = ""

        for v,k in pairs(arg) do
            if v != 1 then
                reason = reason.." "..k
            end
        end

        reason = string.Trim(reason)

        if reason == "" then reason = nil end

        if plyTarget and ply != plyTarget then
            ply:Notify("You have kicked "..plyTarget:Name().." from the server.")
            plyTarget:Kick(reason or "Kicked by a game moderator.")
        else
            return ply:Notify("Could not find player: "..tostring(name))
        end
    end
}

impulse.RegisterChatCommand("/kick", kickCommand)