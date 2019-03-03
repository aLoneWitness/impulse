if SERVER then
	util.AddNetworkString("impulseOpsNamechange")
	util.AddNetworkString("impulseOpsDoNamechange")

	net.Receive("impulseOpsDoNamechange", function(len, ply)
		if not ply.NameChangeForced then
			return
		end

		local charName = net.ReadString()

		if charName:len() >= 24 or charName:len() <= 6 then return ply:Notify("Name too long.") end -- min/max name sizes
		charName = charName:Trim()
		if charName == "" then return end
		charName = impulse.SafeString(charName) -- dont allow for stings made to break stuff

		ply:SetRPName(charName, true)
		ply:Notify("You have changed your name to "..charName..".")

		ply.NameChangeForced = nil
	end)
else
	local nameChangeText = "You have been forced to change your name by a game moderator as it was deemed inappropriate.\nPlease change your name below to something more sutable.\nEXAMPLE: John Doe"
	net.Receive("impulseOpsNamechange", function()
		local panel = Derma_StringRequest("impulse", nameChangeText, "", 
			function(newName)
				net.Start("impulseOpsDoNamechange")
				net.WriteString(newName)
				net.SendToServer()
			end,
			function(newName)
				return false
			end, "Change name")

		local cancelButton = (panel:GetChildren()[6]):GetChildren()[2]
		local changeButton = (panel:GetChildren()[6]):GetChildren()[1]
		local buttonPanel = (panel:GetChildren()[6])
		buttonPanel:SetWide(changeButton:GetWide() + 5)
		buttonPanel:CenterHorizontal()
		cancelButton:Remove()
	end)
end

local changeNameCommand =  {
	description = "Force changes the specified players name.",
	requiresArg = true,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			net.Start("impulseOpsNamechange")
			net.Send(plyTarget)

			plyTarget.NameChangeForced = true
			ply:Notify(plyTarget:Name().." has been forced name-changed.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
	end
}

impulse.RegisterChatCommand("/forcenamechange", changeNameCommand)