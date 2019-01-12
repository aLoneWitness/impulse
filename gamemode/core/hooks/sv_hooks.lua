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

function IMPULSE:PlayerSay(ply, text)
	for v,k in pairs(player.GetAll()) do
		k:AddChatText(text)
	end
end