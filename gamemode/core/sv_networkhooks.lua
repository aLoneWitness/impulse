netstream.Hook("impulseCharacterCreate", function(player, charName, charModel, charSkin)
	local playerID = player:SteamID()
	local playerGroup = player:GetUserGroup()
	local timestamp = math.floor(os.time())

	if charName:len() >= 24 or charName:len() <= 6 then return end -- min/max name sizes

	local query = mysql:Select("impulse_players")
	query:Where("steamid", playerID)
	query:Callback(function(result)
		if (type(result) == "table" and #result > 0) then return end -- if player already exists; halt
		
		local insertQuery = mysql:Insert("impulse_players")
		insertQuery:Insert("rpname", charName or "")
		insertQuery:Insert("steamid", playerID)
		insertQuery:Insert("group", playerGroup)
		insertQuery:Insert("xp", 0)
		insertQuery:Insert("money", 10)
		insertQuery:Insert("bankmoney", 20)
		insertQuery:Insert("model", charModel)
		insertQuery:Insert("skin", charSkin)
		insertQuery:Insert("firstjoin", timestamp)
		insertQuery:Callback(function(result, status, lastID)
			print("[impulse] "..playerID.." has been submitted to the database. ".. charName)
		end)
		insertQuery:Execute()
	end)
	query:Execute()
end)

netstream.Hook("msg", function(ply, text)
	if (player.NextChat or 0) < CurTime() then
		hook.Run("PlayerSay", ply, text, false)
		player.NextChat = CurTime() + math.max(#text / 250, 0.4)
	end
end)