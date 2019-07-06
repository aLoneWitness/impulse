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
util.AddNetworkString("impulseDoorAdd")
util.AddNetworkString("impulseDoorRemove")
util.AddNetworkString("impulseSceneFOV")
util.AddNetworkString("impulseScenePVS")
util.AddNetworkString("impulseQuizSubmit")
util.AddNetworkString("impulseQuizForce")
util.AddNetworkString("impulseSellAllDoors")
util.AddNetworkString("impulseInvGive")
util.AddNetworkString("impulseInvGiveSilent")
util.AddNetworkString("impulseInvRemove")
util.AddNetworkString("impulseInvUpdateStorage")
util.AddNetworkString("impulseInvUpdateEquip")
util.AddNetworkString("impulseInvUpdateData")
util.AddNetworkString("impulseInvDoEquip")
util.AddNetworkString("impulseInvDoDrop")
util.AddNetworkString("impulseInvDoUse")
util.AddNetworkString("impulseInvDoSearch")
util.AddNetworkString("impulseInvDoSearchConfiscate")
util.AddNetworkString("impulseCharacterCreate")
util.AddNetworkString("impulseInvStorageOpen")
util.AddNetworkString("impulseInvMove")
util.AddNetworkString("impulseInvDoMove")
util.AddNetworkString("impulseRagdollLink")
util.AddNetworkString("impulseUpdateOOCLimit")
util.AddNetworkString("impulseChangeRPName")

net.Receive("impulseCharacterCreate", function(len, ply)
	if (ply.NextCreate or 0) > CurTime() then return end
	ply.NextCreate = CurTime() + 10

	local charName = net.ReadString()
	local charModel = net.ReadString()
	local charSkin = net.ReadUInt(8)

	local plyID = ply:SteamID()
	local plyGroup = ply:GetUserGroup()
	local timestamp = math.floor(os.time())

	local canUseName, filteredName = impulse.CanUseName(charName)

	if canUseName then
		charName = filteredName
	else
		return
	end

	local skinBlacklist = impulse.Config.DefaultSkinBlacklist[charModel]

	if skinBlacklist and table.HasValue(skinBlacklist, charSkin) then
		return
	end

	local query = mysql:Select("impulse_players")
	query:Where("steamid", plyID)
	query:Callback(function(result)
		if (type(result) == "table" and #result > 0) then return end -- if ply already exists; halt
		
		local insertQuery = mysql:Insert("impulse_players")
		insertQuery:Insert("rpname", charName)
		insertQuery:Insert("steamid", plyID)
		insertQuery:Insert("group", "vip") -- testing value normal: plyGroup
		insertQuery:Insert("xp", 0)
		insertQuery:Insert("money", impulse.Config.StartingMoney)
		insertQuery:Insert("bankmoney", impulse.Config.StartingBankMoney)
		insertQuery:Insert("model", charModel)
		insertQuery:Insert("skin", charSkin)
		insertQuery:Insert("firstjoin", timestamp)
		insertQuery:Insert("data", "[]")
		insertQuery:Insert("ranks", "[]")
		insertQuery:Callback(function(result, status, lastID)
			if IsValid(ply) then
				local setupData = {
					id = lastID,
					rpname = charName,
					steamid = plyID,
					group = "vip", -- testing value normal: plyGroup
					xp = 0,
					money = impulse.Config.StartingMoney,
					bankmoney = impulse.Config.StartingBankMoney,
					model = charModel,
					data = "[]",
					skin = charSkin
				}

				print("[impulse] "..plyID.." has been submitted to the database. RP Name: ".. charName)
				hook.Run("SetupPlayer", ply, setupData)

				ply.extraPVS = nil
			end
		end)
		insertQuery:Execute()
	end)
	query:Execute()
end)

net.Receive("impulseSceneFOV", function(len, ply)
	if ply:Team() != 0 then return end

	local fov = net.ReadUInt(8)
	local time = net.ReadUInt(8)

	if fov == 0 then fov = 70 end
	ply:SetFOV(fov, time)
end)

net.Receive("impulseScenePVS", function(len, ply)
	if ply:Team() != 0 then return end

	local stage = net.ReadUInt(8)

	if impulse.Config.IntroScenes[stage] then
		ply.extraPVS = impulse.Config.IntroScenes[stage].pos
	end
end)

net.Receive("impulseChatMessage", function(len, ply) -- should implement a check on len here instead of string.len
	if (ply.nextChat or 0) < CurTime() then
		if len > 15000 then
			ply.nextChat = CurTime() + 1 
			return
		end

		local text = net.ReadString()
		ply.nextChat = CurTime() + 0.3 + math.Clamp(#text / 300, 0, 4)
		
		text = string.sub(text, 1, 1024)
		hook.Run("PlayerSay", ply, text, false, true)
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

			if impulse.Teams.Data[teamID].quiz then
				local data = ply:GetData()

				if not data.quiz or not data.quiz[teamID] then
					if ply.nextQuiz and ply.nextQuiz > CurTime() then
						ply:Notify("Wait"..string.NiceTime(math.ceil(CurTime() - ply.nextQuiz)).." before attempting to retry the quiz.")
						return
					end

					ply.quizzing = true
					net.Start("impulseQuizForce")
					net.WriteUInt(teamID, 8)
					net.Send(ply)
					return
				end
			end

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

		if state != isTyping then
			ply:SetSyncVar(SYNC_TYPING, isTyping, true)
		end

		ply.nextChatState = CurTime() + .1
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
			ply:TakeMoney(impulse.Config.DoorPrice)
			ply:SetDoorMaster(traceEnt)

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

	if IsValid(traceEnt) and ply:IsDoorOwner(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil)) and traceEnt:GetDoorMaster() == ply and hook.Run("CanEditDoor", ply, traceEnt) != false then
		ply:RemoveDoorMaster(traceEnt)
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

net.Receive("impulseDoorAdd", function(len, ply)
	if (ply.nextDoorChange or 0) > CurTime() then return end
	ply.nextDoorChange = CurTime() + 0.5

	local target = net.ReadEntity()

	if not IsValid(target) or not target:IsPlayer() or not ply.beenSetup then
		return
	end

	local cost = math.ceil(impulse.Config.DoorPrice / 2)

	if not ply:CanAfford(cost) then
		return ply:Notify("You cannot afford to add a player to this door.")
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity
	local owners = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil)

	if IsValid(traceEnt) and ply:IsDoorOwner(owners) and traceEnt:GetDoorMaster() == ply then
		if target == ply then
			return
		end

		if target.OwnedDoors and target.OwnedDoors[traceEnt] then
			return
		end

		if table.Count(owners) > 9 then
			return ply:Notify("Door user limit reached (9).")
		end

		ply:TakeMoney(cost)
		target:SetDoorUser(traceEnt)

		ply:Notify("You have added "..target:Nick().." to this door for "..impulse.Config.CurrencyPrefix..cost..".")
	end
end)

net.Receive("impulseDoorRemove", function(len, ply)
	if (ply.nextDoorChange or 0) > CurTime() then return end
	ply.nextDoorChange = CurTime() + 0.5

	local target = net.ReadEntity()

	if not IsValid(target) or not target:IsPlayer() or not ply.beenSetup then
		return
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and ply:IsDoorOwner(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil)) and traceEnt:GetDoorMaster() == ply then
		if target == ply then
			return
		end

		if not target.OwnedDoors or not target.OwnedDoors[traceEnt] then
			return
		end

		if traceEnt:GetDoorMaster() == target then
			return ply:Notify("The door's master cannot be removed.")
		end

		target:RemoveDoorUser(traceEnt)

		ply:Notify("You have removed "..target:Nick().." from this door.")
	end
end)

net.Receive("impulseQuizSubmit", function(len, ply)
	if not ply.quizzing then return end
	ply.quizzing = false

	local teamID = net.ReadUInt(8)
	if not impulse.Teams.Data[teamID] or not impulse.Teams.Data[teamID].quiz then return end

	local quizPassed = net.ReadBool()

	if not quizPassed then
		ply.nextQuiz = CurTime() + (impulse.Config.QuizWaitTime * 60)
		return ply:Notify("Quiz failed. You may retry the quiz in "..impulse.Config.QuizWaitTime.." minutes.")
	end

	ply.impulseData.quiz = ply.impulseData.quiz or {}
	ply.impulseData.quiz[teamID] = true
	ply:SaveData()

	ply:Notify("You have passed the quiz. You will not need to retake it again.")

	if ply:CanBecomeTeam(teamID, true) then
		ply:SetTeam(teamID)
		ply:Notify("You have changed your team to "..team.GetName(teamID)..".")
	else
		ply:Notify(team.GetName(teamID).." cannot be joined right now. However, you have still passed the quiz. Rejoin the team when it is available to play again.")
	end
end)

net.Receive("impulseSellAllDoors", function(len, ply)
	if (ply.nextSellAllDoors or 0) > CurTime() then return end
	ply.nextSellAllDoors = CurTime() + 5
	if not ply.OwnedDoors or table.Count(ply.OwnedDoors) == 0 then return end

	local sold = 0
	for v,k in pairs(ply.OwnedDoors) do
		if IsValid(v) then
			if v:GetDoorMaster() == ply then
				local noUnlock = v.NoDCUnlock or false
				ply:RemoveDoorMaster(v, noUnlock)
				sold = sold + 1
			else
				ply:RemoveDoorUser(ply)
			end
		end
	end

	ply.OwnedDoors = {}

	local amount = sold * (impulse.Config.DoorPrice - 2)
	ply:GiveMoney(amount)
	ply:Notify("You have sold all your doors for "..impulse.Config.CurrencyPrefix..amount..".")
end)

net.Receive("impulseInvDoEquip", function(len, ply)
	if not ply.beenInvSetup or (ply.nextInvEquip or 0) > CurTime() then return end
	ply.nextInvEquip = CurTime() + 0.5

	local invid = net.ReadUInt(10)
	local equipState = net.ReadBool()

	local hasItem, item = ply:HasInventoryItemSpecific(invid)

	if hasItem then
		ply:SetInventoryItemEquipped(invid, equipState or false)
	end
end)

net.Receive("impulseInvDoDrop", function(len, ply)
	if not ply.beenInvSetup or (ply.nextInvDrop or 0) > CurTime() then return end
	ply.nextInvDrop = CurTime() + 0.5

	local invid = net.ReadUInt(10)

	local hasItem, item = ply:HasInventoryItemSpecific(invid)

	if hasItem then
		ply:DropInventoryItem(invid)
	end
end)

net.Receive("impulseInvDoUse", function(len, ply)
	if not ply.beenInvSetup or (ply.nextInvUse or 0) > CurTime() then return end
	ply.nextInvUse = CurTime() + 0.5

	local invid = net.ReadUInt(10)

	local hasItem, item = ply:HasInventoryItemSpecific(invid)

	if hasItem then
		ply:UseInventoryItem(invid)
	end
end)

net.Receive("impulseInvDoSearchConfiscate", function(len, ply)
	if not ply:IsCP() then return end
	if (ply.nextInvConf or 0) > CurTime() then return end
	ply.nextInfConf = CurTime() + 2

	local targ = ply.InvSearching
	if not IsValid(targ) or not ply:CanArrest(targ) then return end

	local count = net.ReadUInt(8) or 0

	if count > 0 then
		for i=1,count do
			local netid = net.ReadUInt(10)
			local item = impulse.Inventory.Items[netid]

			if not item then continue end

			if item.Illegal and targ:HasInventoryItem(item.UniqueID) then
				targ:TakeInventoryItemClass(item.UniqueID, 1)

				hook.Run("PlayerConfiscateItem", ply, targ, item.UniqueID)
			end
		end

		ply:Notify("You have confiscated "..count.." items.")
		targ:Notify("The search has been completed and "..count.." items have been confiscated.")
	else
		targ:Notify("The search has been completed.")
	end

	ply.InvSearching = nil
	targ:Freeze(false)
end)

net.Receive("impulseInvDoMove", function(len, ply)
	if (ply.nextInvMove or 0) > CurTime() then return end
	ply.nextInvMove = CurTime() + 0.5

	if not ply.currentStorage or not IsValid(ply.currentStorage) then return end
	if ply.currentStorage:GetPos():DistToSqr(ply:GetPos()) > (100 ^ 2) then return end
	if ply:GetSyncVar(SYNC_ARRESTED, false) or not ply:Alive() then return end

	local itemid = net.ReadUInt(10)
	local from = net.ReadUInt(4)
	local to = 1

	if from != 1 and from != 2 then
		return
	end

	if from == 1 then
		to = 2
	end

	local hasItem, item = ply:HasInventoryItemSpecific(itemid, from)

	if not hasItem then
		return
	end

	if item.restricted then
		return ply:Notify("You cannot store a restricted item.")
	end

	if from == 2 and not ply:CanHoldItem(item.class) then
		return ply:Notify("Item is too heavy to hold.")
	end

	if from == 1 and not ply:CanHoldItemStorage(item.class) then
		return ply:Notify("Item is too heavy to store.")
	end

	ply:MoveInventoryItem(itemid, from, to)
end)

net.Receive("impulseChangeRPName", function(len, ply)
	if not ply.beenSetup then return end
	if (ply.nextRPNameTry or 0) > CurTime() then return end
	ply.nextRPNameTry = CurTime() + 2

	if (ply.nextRPNameChange or 0) > CurTime() then 
		return ply:Notify("You must wait "..string.NiceTime(ply.nextRPNameChange - CurTime()).." before changing your name again.")
	end

	local name = net.ReadString()

	if ply:CanAfford(impulse.Config.RPNameChangePrice) then
		local canUseName, output = impulse.CanUseName(name)

		if canUseName then
			ply:SetRPName(output, true)
			ply.nextRPNameChange = CurTime() + 240
			ply:Notify("You have changed your name to "..output.." successfully.")
		else
			ply:Notify("Name rejected: "..output)
		end
	else
		ply:Notify("You cannot afford to change your name.")
	end
end)