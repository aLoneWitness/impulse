local timeoutCommand = {
    description = "Gives the player an OOC ban for the time provided, in minutes. Reason is optional.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local time = arg[2]
        local reason = arg[3]
		local plyTarget = impulse.FindPlayer(name)

		if not time or not tonumber(time) then
			return ply:Notify("Please specific a valid time value in minutes.")
		end

		time = tonumber(time)
		time = time * 60

		if plyTarget then
			plyTarget.hasOOCTimeout = CurTime() + time
			plyTarget:Notify("Reason: "..(reason or "Behaviour that violates the community guidelines")..".")
			plyTarget:Notify("You have been issued an OOC communication timeout by a game moderator that will last "..(time / 60).." minutes.")

			timer.Create("impulseOOCTimeout"..plyTarget:SteamID(), time, 1, function()
				if IsValid(plyTarget) and plyTarget.hasOOCTimeout then
					plyTarget.hasOOCTimeout = nil
					plyTarget:Notify("You OOC communication timeout has expired. You may now use OOC again. Please review the community guidelines before sending messages again.")
				end
			end)

			ply:Notify("You have issued "..plyTarget:Name().." an OOC timeout for "..(time / 60).." minutes.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/ooctimeout", timeoutCommand)

local unTimeoutCommand = {
	description = "Revokes an OOC communication timeout from the player specified.",
	requiresArg = true,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			plyTarget.hasOOCTimeout = nil
			ply:Notify("The OOC communication timeout has been removed from "..plyTarget:Name()..".")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/unooctimeout", unTimeoutCommand)