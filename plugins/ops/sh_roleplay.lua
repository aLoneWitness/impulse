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

			if plyTarget.InJail then
				impulse.Arrest.Prison[plyTarget.InJail][plyTarget:EntIndex()] = nil
				plyTarget.InJail = nil
				timer.Remove(plyTarget:UserID().."impulsePrison")
				plyTarget:StopDrag()
				plyTarget:Spawn()
			end
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/unarrest", unArrestCommand)

local setTeamCommand = {
    description = "Sets the team of the player specified. Teams are refrenced with their team ID number.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local teamID = arg[2]
		local plyTarget = impulse.FindPlayer(name)

		if not tonumber(teamID) then
			return ply:Notify("Team ID should be a number.")
		end

		teamID = tonumber(teamID)

		if plyTarget then
			if teamID and impulse.Teams.Data[teamID] then
				local teamName = team.GetName(teamID)
				plyTarget:SetTeam(teamID)
				plyTarget:Notify("Your team has been set to "..teamName.." by a game moderator.")
				ply:Notify(plyTarget:Name().." has been set to "..teamName..".")
			else
				ply:Notify("Invalid team ID. They are in F4 menu order!")
			end
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/setteam", setTeamCommand)