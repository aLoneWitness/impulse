netstream.Hook("impulseCharacterCreate", function(player, charName, charModel, charSkin)
	if (ply.NextCreate or 0) > CurTime() then return end

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
	ply.NextCreate = ply.NextCreate + 10
end)

netstream.Hook("msg", function(ply, text)
	if (ply.NextChat or 0) < CurTime() and string.len(text) < 1000 then
		hook.Run("PlayerSay", ply, text, false)
		ply.NextChat = CurTime() + math.max(#text / 250, 0.4)
	end
end)

netstream.Hook("impulseATMWithdraw", function(ply, amount)
	if (ply.NextATM or 0) > CurTime() then return end
	if not isnumber(amount) or amount < 1 or amount >= 1 / 0 or amount > 10000000000000 then return end

	amount = math.floor(amount)

	if ply:CanAffordBank(amount) then
		ply:TakeBankMoney(amount)
		ply:GiveMoney(amount)
		ply:Notify("You have withdrawn "..impulse.Config.CurrencyPrefix..amount.." from your bank account.")
	else
		ply:Notify("You cannot afford to withdraw this amount of money.")
	end
	ply.NextATM = CurTime() + 1
end)

netstream.Hook("impulseATMDeposit", function(ply, amount)
	if (ply.NextATM or 0) > CurTime() then return end
	if not isnumber(amount) or amount < 1 or amount >= 1 / 0 or amount > 10000000000000 then return end

	amount = math.floor(amount)

	if ply:CanAfford(amount) then
		ply:TakeMoney(amount)
		ply:GiveBankMoney(amount)
		ply:Notify("You have deposited "..impulse.Config.CurrencyPrefix..amount.." to your bank account.")
	else
		ply:Notify("You cannot afford to deposit this amount of money.")
	end
	ply.NextATM = CurTime() + 1
end)

util.AddNetworkString("impulseTeamChange")
net.Receive("impulseTeamChange", function(len, ply)
	if ply.lastTeamTry and ply.lastTeamTry < CurTime() + 1 then return end
	
	local teamChangeTime = impulse.Config.TeamChangeTime

	if ply:IsDonator() or ply:IsAdmin() then
		teamChangeTime = impulse.Config.TeamChangeTimeDonator
	end

	if ply.lastTeamChange and ply.lastTeamChange + teamChangeTime > CurTime() then
		ply:Notify("Wait "..math.ceil((ply.lastTeamChange + teamChangeTime) - CurTime()).." seconds before switching team again.")
		return
	end

	local teamId = net.ReadUInt(8)

	if teamId and isnumber(teamId) then
		local setTeam = ply:SetTeam(teamId)
		if setTeam == true then
			ply.lastTeamChange = CurTime()
			ply:Notify("You have changed your team to "..team.GetName(teamId)..".")
			ply:EmitSound("items/ammo_pickup.wav")
		end
	end
end)