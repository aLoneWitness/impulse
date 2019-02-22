local unArrestCommand = {
    description = "Un arrests the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			plyTarget:UnArrest()
			plyTarget:Notify("You have been un-arrested by a game moderator.")
			ply:Notify(plyTarget:Name().." has been un-arrested.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/unarrest", unArrestCommand)