util.AddNetworkString("impulseATMWithdraw")
util.AddNetworkString("impulseATMDeposit")
util.AddNetworkString("impulseATMOpen")
util.AddNetworkString("impulseReadNote")
util.AddNetworkString("impulseTeamChange")
util.AddNetworkString("impulseBuyItem")
util.AddNetworkString("impulseClassChange")
util.AddNetworkString("impulseCinematicMessage")
util.AddNetworkString("impulseChatMessage")
util.AddNetworkString("impulseZoneUpdate")
util.AddNetworkString("impulseChatState")
util.AddNetworkString("impulseDoorBuy")
util.AddNetworkString("impulseDoorSell")
util.AddNetworkString("impulseDoorLock")
util.AddNetworkString("impulseDoorUnlock")

netstream.Hook("impulseCharacterCreate", function(player, charName, charModel, charSkin)
	if (player.NextCreate or 0) > CurTime() then return end

	local playerID = player:SteamID()
	local playerGroup = player:GetUserGroup()
	local timestamp = math.floor(os.time())

	local canUseName, filteredName =  impulse.CanUseName(charName)

	if canUseName then
		charName = filteredName
	end

	local query = mysql:Select("impulse_players")
	query:Where("steamid", playerID)
	query:Callback(function(result)
		if (type(result) == "table" and #result > 0) then return end -- if player already exists; halt
		
		local insertQuery = mysql:Insert("impulse_players")
		insertQuery:Insert("rpname", charName)
		insertQuery:Insert("steamid", playerID)
		insertQuery:Insert("group", "vip") -- testing value normal: playerGroup
		insertQuery:Insert("xp", 0)
		insertQuery:Insert("money", impulse.Config.StartingMoney)
		insertQuery:Insert("bankmoney", impulse.Config.StartingBankMoney)
		insertQuery:Insert("model", charModel)
		insertQuery:Insert("skin", charSkin)
		insertQuery:Insert("firstjoin", timestamp)
		insertQuery:Insert("data", "[]")
		insertQuery:Insert("ranks", "[]")
		insertQuery:Callback(function(result, status, lastID)
			if IsValid(player) then
				local setupData = {
					rpname = charName,
					steamid = playerID,
					group = "vip", -- testing value normal: playerGroup
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
	player.NextCreate = CurTime() + 10
end)

net.Receive("impulseChatMessage", function(len, ply) -- should implement a check on len here instead of string.len
	if (ply.nextChat or 0) < CurTime() then
		local text = net.ReadString()
		
		if string.len(text) < 1000 then
			hook.Run("PlayerSay", ply, text, false)
		end
		ply.nextChat = CurTime() + math.max(#text / 250, 0.4)
	end
end)

net.Receive("impulseATMWithdraw", function(len, ply)
	if (ply.nextATM or 0) > CurTime() or not ply.currentATM then return end
	if IsValid(ply.currentATM) and (ply:GetPos() - ply.currentATM:GetPos()):LengthSqr() > (120 ^ 2) then return end

	local amount = net.ReadUInt(32)
	if not isnumber(amount) or amount < 1 or amount >= 1 / 0 or amount > 1000000000 then return end

	amount = math.floor(amount)

	if ply:CanAffordBank(amount) then
		ply:TakeBankMoney(amount)
		ply:GiveMoney(amount)
		ply:Notify("You have withdrawn "..impulse.Config.CurrencyPrefix..amount.." from your bank account.")
	else
		ply:Notify("You cannot afford to withdraw this amount of money.")
	end
	ply.nextATM = CurTime() + 1
end)

net.Receive("impulseATMDeposit", function(len, ply)
	if (ply.nextATM or 0) > CurTime() or not ply.currentATM then return end

	local amount = net.ReadUInt(32)
	if not isnumber(amount) or amount < 1 or amount >= 1 / 0 or amount > 10000000000 then return end
	if IsValid(ply.currentATM) and (ply:GetPos() - ply.currentATM:GetPos()):LengthSqr() > (120 ^ 2) then return end

	amount = math.floor(amount)

	if ply:CanAfford(amount) then
		ply:TakeMoney(amount)
		ply:GiveBankMoney(amount)
		ply:Notify("You have deposited "..impulse.Config.CurrencyPrefix..amount.." to your bank account.")
	else
		ply:Notify("You cannot afford to deposit this amount of money.")
	end
	ply.nextATM = CurTime() + 1
end)

net.Receive("impulseTeamChange", function(len, ply)
	if (ply.lastTeamTry or 0) > CurTime() then return end
	ply.lastTeamTry = CurTime() + 1
	
	local teamChangeTime = impulse.Config.TeamChangeTime

	if ply:IsDonator() or ply:IsAdmin() then
		teamChangeTime = impulse.Config.TeamChangeTimeDonator
	end

	if ply.lastTeamChange and ply.lastTeamChange + teamChangeTime > CurTime() then
		ply:Notify("Wait "..math.ceil((ply.lastTeamChange + teamChangeTime) - CurTime()).." seconds before switching team again.")
		return
	end

	local teamID = net.ReadUInt(8)

	if teamID and isnumber(teamID) and impulse.Teams.Data[teamID] then
		if ply:CanBecomeTeam(teamID, true) then
			ply:SetTeam(teamID)
			ply.lastTeamChange = CurTime()
			ply:Notify("You have changed your team to "..team.GetName(teamID)..".")
			ply:EmitSound("items/ammo_pickup.wav")
		end
	end
end)

net.Receive("impulseClassChange",function(len, ply)
	if (ply.lastTeamTry or 0) > CurTime() then return end
	ply.lastTeamTry = CurTime() + 1

	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return
	end

	local classChangeTime = impulse.Config.ClassChangeTime

	if ply:IsAdmin() then
		classChangeTime = 5
	end

	if ply.lastClassChange and ply.lastClassChange + classChangeTime > CurTime() then
		ply:Notify("Wait "..math.ceil((ply.lastClassChange + classChangeTime) - CurTime()).." seconds before switching class again.")
		return
	end

	local classID = net.ReadUInt(8)
	local classes = impulse.Teams.Data[ply:Team()].classes

	if classID and isnumber(classID) and classID > 0 and classes and classes[classID] and not classes[classID].noMenu then
		if ply:CanBecomeTeamClass(classID, true) then
			ply:SetTeamClass(classID)
			ply.lastClassChange = CurTime()
			ply:Notify("You have changed your class to "..classes[classID].name..".")
		end
	end
end)

net.Receive("impulseBuyItem", function(len, ply)
	if (ply.nextBuy or 0) > CurTime() then return end
	ply.nextBuy = CurTime() + 1

	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return
	end

	local buyableID = net.ReadUInt(8)

	local buyableName = impulse.Business.DataRef[buyableID]
	local buyable = impulse.Business.Data[buyableName]

	if buyable and ply:CanBuy(buyableName) and ply:CanAfford(buyable.price) then
		ply:TakeMoney(buyable.price)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)
		impulse.SpawnBuyable(tr.HitPos, buyable)

		ply:Notify("You have purchased "..buyableName.." for "..impulse.Config.CurrencyPrefix..buyable.price..".")
	else
		ply:Notify("You cannot afford this purchase.")
	end
end)

net.Receive("impulseChatState", function(len, ply)
	local state = ply:GetSyncVar(SYNC_TYPING, false)

	if (ply.nextChatState or 0) < CurTime() then
		local isTyping = net.ReadBool()

		ply:SetSyncVar(SYNC_TYPING, isTyping, true)
		ply.nextChatState = CurTime() + .1
	--elseif state then
	--	ply:SetSyncVar(SYNC_TYPING, false, true)
	end
end)

net.Receive("impulseDoorBuy", function(len, ply)
	if (ply.nextDoorBuy or 0) > CurTime() then return end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and ply:CanBuyDoor(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_BUYABLE, true)) and hook.Run("CanEditDoor", ply, traceEnt) != false then
		if ply:CanAfford(impulse.Config.DoorPrice) then
			local owners = {}
			owners[ply:EntIndex()] = true

			traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, owners, true)

			ply.OwnedDoors = ply.OwnedDoors or {}
			ply.OwnedDoors[traceEnt] = true

			ply:TakeMoney(impulse.Config.DoorPrice)
			ply:Notify("You have bought a door for "..impulse.Config.CurrencyPrefix..impulse.Config.DoorPrice..".")
		else
			ply:Notify("You cannot afford to buy this door.")
		end
	end
	ply.nextDoorBuy = CurTime() + 1
end)

net.Receive("impulseDoorSell", function(len, ply)
	if (ply.nextDoorSell or 0) > CurTime() then return end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and ply:IsDoorOwner(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil)) and hook.Run("CanEditDoor", ply, traceEnt) != false then
		traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, nil, true)
		traceEnt:DoorUnlock()

		ply.OwnedDoors = ply.OwnedDoors or {}
		ply.OwnedDoors[traceEnt] = nil

		ply:GiveMoney(impulse.Config.DoorPrice - 2)
		ply:Notify("You have sold a door for "..impulse.Config.CurrencyPrefix..(impulse.Config.DoorPrice - 2)..".")
	end
	ply.nextDoorSell = CurTime() + 1
end)

net.Receive("impulseDoorLock", function(len, ply)
	if (ply.nextDoorLock or 0) > CurTime() then return end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

		if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
			traceEnt:DoorLock()
			traceEnt:EmitSound("doors/latchunlocked1.wav")
		end
	end

	ply.nextDoorLock = CurTime() + 1
end)

net.Receive("impulseDoorUnlock", function(len, ply)
	if (ply.nextDoorUnlock or 0) > CurTime() then return end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

		if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
			traceEnt:DoorUnlock()
			traceEnt:EmitSound("doors/latchunlocked1.wav")
		end
	end

	ply.nextDoorUnlock = CurTime() + 1
end)