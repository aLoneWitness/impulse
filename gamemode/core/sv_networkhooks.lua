netstream.Hook("impulseCharacterCreate", function(player, charName, charModel, charSkin)
	local playerID = player:SteamID()
	local playerGroup = player:GetUserGroup()
	local timestamp = math.floor(os.time())

	if charName:len() >= 24 or charName:len() <= 6 then return end -- min/max name sizes
	charName = charName:Trim()
	if charName == "" then return end

	local query = mysql:Select("impulse_players")
	query:Where("steamid", playerID)
	query:Callback(function(result)
		if (type(result) == "table" and #result > 0) then return end -- if player already exists; halt
		
		local insertQuery = mysql:Insert("impulse_players")
		insertQuery:Insert("rpname", charName)
		insertQuery:Insert("steamid", playerID)
		insertQuery:Insert("group", playerGroup)
		insertQuery:Insert("xp", 0)
		insertQuery:Insert("money", impulse.Config.StartingMoney)
		insertQuery:Insert("bankmoney", impulse.Config.StartingBankMoney)
		insertQuery:Insert("model", charModel)
		insertQuery:Insert("skin", charSkin)
		insertQuery:Insert("firstjoin", timestamp)
		insertQuery:Insert("data", "[]")
		insertQuery:Callback(function(result, status, lastID)
			if IsValid(player) then
				local setupData = {
					rpname = charName,
					steamid = playerID,
					group = playerGroup,
					xp = 0,
					money = impulse.Config.StartingMoney,
					bankmoney = impulse.Config.StartingBankMoney,
					model = charModel,
					skin = charSkin
				}

				print("[impulse] "..playerID.." has been submitted to the database. RP Name: ".. charName)
				hook.Run("SetupPlayer", player, setupData)
			end
		end)
		insertQuery:Execute()
	end)
	query:Execute()
end)

netstream.Hook("msg", function(ply, text)
	if (ply.NextChat or 0) < CurTime() then
		hook.Run("PlayerSay", ply, text, false)
		ply.NextChat = CurTime() + math.max(#text / 250, 0.4)
	end
end)