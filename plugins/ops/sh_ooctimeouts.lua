local timeoutCommand = {
    description = "Gives the specified player an LOOC/OOC/Report ban for the amount of time provided, in minutes. Reason is optional.",
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

		if plyTarget then
			plyTarget.hasOOCTimeout = true
			plyTarget:Notify("Reason: "..(reason or "Behaviour that violates the community guidelines")..".")
			plyTarget:Notify("You have been issued an OOC communication timeout by a game moderator that will last "..time.." minutes.")

			timer.Create("impulseOOCTimeout"..plyTarget:SteamID(), time, 1, function()
				if IsValid(plyTarget) and plyTarget.hasOOCTimeout then
					plyTarget.hasOOCTimeout = false
					plyTarget:Notify("You OOC communication timeout has expired. You may now use OOC again. Please review the community guidelines before sending messages again.")
				end
			end)
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/ooctimeout", timeoutCommand)