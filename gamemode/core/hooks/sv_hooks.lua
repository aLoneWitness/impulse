function IMPULSE:PlayerInitialSpawn(player)
	local isNew = true
	local query = mysql:Select("impulse_players")
	query:Where("steamid", player:SteamID())
	query:Callback(function(result)
		if (type(result) == "table" and #result > 0) then -- if player exists in db
			isNew = false
		end
		netstream.Start(player, "impulseJoinData", isNew)
	end)
	query:Execute()
end

function IMPULSE:PlayerLoadout(player)
	player:SetRunSpeed(impulse.Config.JogSpeed)
	player:SetWalkSpeed(impulse.Config.WalkSpeed)

	return true
end

function IMPULSE:ShowHelp()
	return
end

local talkCol = Color(255, 255, 100)
local infoCol = Color(135, 206, 250)

function IMPULSE:PlayerSay(ply, text, teamChat)
	if teamChat == true then return "" end -- disabled team chat

	if string.StartWith(text, "/") then
		local args = string.Explode(" ", text)
		local command = impulse.chatCommands[string.lower(args[1])]
		if command then
			if command.adminOnly == true and ply:IsAdmin() == false then return "" end
			if command.superAdminOnly == true and ply:IsSuperAdmin() == false then return "" end
			if command.requiresArg == true and (not args[2] or string.Trim(args[2]) == "") then return "" end

			text = string.sub(text, string.len(args[1]) + 1)
			table.remove(args, 1)
			command.onRun(ply, args, text)
		else
			ply:AddChatText(infoCol, "The command "..args[1].." does not exist.")
		end
	else
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:AddChatText(ply, talkCol, " says: ", text)
			end
		end
	end

	return ""
end

function IMPULSE:PlayerCanHearPlayersVoice(listener, speaker)
	if listener:GetPos():DistToSqr(speaker:GetPos()) > impulse.Config.VoiceDistance ^ 2 then
		return false, false
	end 

	return true, true
end