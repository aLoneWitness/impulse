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
