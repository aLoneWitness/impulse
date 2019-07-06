local isValid = IsValid
local mathAbs = math.abs

function IMPULSE:PlayerInitialSpawn(ply)
	local isNew = true

	-- sync players with all other clients/ents
	impulse.Sync.Data[ply:EntIndex()] = {}
	for v,k in pairs(impulse.Sync.Data) do
		local ent = Entity(v)
		if IsValid(ent) then
			ent:Sync(ply)
		end
	end

	local query = mysql:Select("impulse_players")
	query:Select("id")
	query:Select("rpname")
	query:Select("group")
	query:Select("xp")
	query:Select("money")
	query:Select("bankmoney")
	query:Select("model")
	query:Select("skin")
	query:Select("data")
	query:Select("ranks")
	query:Where("steamid", ply:SteamID())
	query:Callback(function(result)
		if IsValid(ply) and type(result) == "table" and #result > 0 then -- if player exists in db
			isNew = false
			hook.Run("SetupPlayer", ply, result[1])
		end
		netstream.Start(ply, "impulseJoinData", isNew)
	end)
	query:Execute()

	timer.Create(ply:UserID().."impulseXP", impulse.Config.XPTime, 0, function()
		if not ply:IsAFK() then
			ply:GiveTimedXP()
			ply:AddTeamTime(impulse.Config.XPTime)
		end
	end)

	if ply:IsDonator() then
		ply.OOCLimit = impulse.Config.OOCLimitVIP
	else
		ply.OOCLimit = impulse.Config.OOCLimit
	end

	timer.Create(ply:UserID().."impulseOOCLimit", 1800, 0, function()
		if ply:IsDonator() then
			ply.OOCLimit = impulse.Config.OOCLimitVIP
		else
			ply.OOCLimit = impulse.Config.OOCLimit
		end
	end)

	timer.Create(ply:UserID().."impulseFullLoad", 0.5, 0, function()
		if IsValid(ply) and ply:GetModel() != "player/default.mdl" then
			hook.Run("PlayerInitialSpawnLoaded", ply)
			timer.Remove(ply:UserID().."impulseFullLoad")
		end
	end)
end

function IMPULSE:PlayerInitialSpawnLoaded(ply) -- called once player is full loaded
	local jailTime = impulse.Arrest.DCRemember[ply:SteamID()]

	if jailTime then
		ply:Arrest()
		ply:Jail(jailTime)
		impulse.Arrest.DCRemember[ply:SteamID()] = nil
	end
end

function IMPULSE:PlayerSpawn(ply)
	local cellID = ply.InJail

	if ply.InJail then
		local pos = impulse.Config.PrisonCells[cellID]
		ply:SetPos(impulse.FindEmptyPos(pos, {self}, 150, 30, Vector(16, 16, 64)))
		ply:SetEyeAngles(impulse.Config.PrisonAngle)

		return
	end

	if ply:GetSyncVar(SYNC_ARRESTED, false) == true then
		ply:SetSyncVar(SYNC_ARRESTED, false, true)
	end

	if ply.beenSetup then
		ply:SetTeam(impulse.Config.DefaultTeam)
		ply:SetLocalSyncVar(SYNC_HUNGER, 100, true)
	end

	ply:SetHunger(100)
	ply.ArrestedWeapons = nil

	--ply:GodEnable()
	ply.SpawnProtection = true
	ply:SetJumpPower(160)

	timer.Simple(10, function()
		if IsValid(ply) then
			ply.SpawnProtection = false
		end
	end)

	hook.Run("PlayerLoadout", ply)
end

function IMPULSE:PlayerDisconnected(ply)
	local userID = ply:UserID()
	local steamID = ply:SteamID()
	ply:SyncRemove()

	local dragger = ply.ArrestedDragger
	if IsValid(dragger) then
		impulse.Arrest.Dragged[ply] = nil
		dragger.ArrestedDragging = nil
	end

	timer.Remove(userID.."impulseXP")
	timer.Remove(userID.."impulseOOCLimit")
	if timer.Exists(userID.."impulseFullLoad") then
		timer.Remove(userID.."impulseFullLoad")
	end

	local jailCell = ply.InJail

	if jailCell then
		timer.Remove(userID.."impulsePrison")
		local duration = impulse.Arrest.Prison[jailCell][userID].duration
		impulse.Arrest.Prison[jailCell][userID] = nil
		impulse.Arrest.DCRemember[steamID] = duration
	elseif ply.BeingJailed then
		impulse.Arrest.DCRemember[steamID] = ply.BeingJailed
	end

	if ply.CanHear then
		for v,k in ipairs(player.GetAll()) do
			if not k.CanHear then continue end

			k.CanHear[ply] = nil
		end
	end

	if ply.impulseID then
		impulse.Inventory.Data[ply.impulseID] = nil
	end

	if ply.OwnedDoors then
		for door,k in pairs(ply.OwnedDoors) do
			if IsValid(door) then
				local owners = door:GetSyncVar(SYNC_DOOR_OWNERS, nil, true)

				table.RemoveByValue(owners, ply:EntIndex())

				if owners and table.Count(owners) < 2 then
					owners = nil
				end

				door:SetSyncVar(SYNC_DOOR_OWNERS, owners or nil, true)
				door:DoorUnlock()
			end
		end
	end

	if ply.InvSearching and IsValid(ply.InvSearching) then
		ply.InvSearching:Freeze(false)
	end

	for v,k in pairs(ents.FindByClass("impulse_item")) do
		if k.ItemOwner and k.ItemOwner == ply then
			k.RemoveIn = CurTime() + impulse.Config.InventoryItemDeSpawnTime
		end
	end
end

function IMPULSE:PlayerLoadout(ply)
	ply:SetRunSpeed(impulse.Config.JogSpeed)
	ply:SetWalkSpeed(impulse.Config.WalkSpeed)

	return true
end

function IMPULSE:SetupPlayer(ply, dbData)
	ply:SetSyncVar(SYNC_RPNAME, dbData.rpname, true)
	ply:SetSyncVar(SYNC_XP, dbData.xp, true)

	ply:SetLocalSyncVar(SYNC_MONEY, dbData.money)
	ply:SetLocalSyncVar(SYNC_BANKMONEY, dbData.bankmoney)

	local data = util.JSONToTable(dbData.data)

	ply.impulseData = data
	ply.impulseRanks = util.JSONToTable(dbData.ranks or "[]")
	ply.impulseID = dbData.id

	if dbData.group and dbData.group != "user" then
		ply:SetUserGroup(dbData.group)
	end

	ply.defaultModel = dbData.model
	ply.defaultSkin = dbData.skin
	ply.defaultRPName = dbData.rpname
	ply:SetFOV(90, 0)
	ply:SetTeam(impulse.Config.DefaultTeam)
	ply:AllowFlashlight(true)

	local id = ply.impulseID
	impulse.Inventory.Data[id] = {}
	impulse.Inventory.Data[id][1] = {} -- inv
	impulse.Inventory.Data[id][2] = {} -- storage

	ply.InventoryWeight = 0
	ply.InventoryWeightStorage = 0
	ply.InventoryRegister = {}
	ply.InventoryEquipGroups = {}

	hook.Run("PreEarlyInventorySetup", ply)

	local query = mysql:Select("impulse_inventory")
	query:Select("id")
	query:Select("uniqueid")
	query:Select("ownerid")
	query:Select("storagetype")
	query:Where("ownerid", dbData.id)
	query:Callback(function(result)
		if IsValid(ply) and type(result) == "table" and #result > 0 then
			local userid = ply.impulseID
			local userInv = impulse.Inventory.Data[userid]

			for v,k in pairs(result) do
				local netid = impulse.Inventory.ClassToNetID(k.uniqueid)
				if not netid then continue end -- when items are removed from a live server we will remove them manually in the db, if an item is broken auto doing this would break peoples items

				local storetype = k.storagetype

				if not userInv[storetype] then
					userInv[storetype] = {}
				end
				
				ply:GiveInventoryItem(k.uniqueid, k.storagetype, false, true)
			end
		end

		if IsValid(ply) then
			ply.beenInvSetup = true
			hook.Run("PostInventorySetup", ply)
		end
	end)

	query:Execute()

	ply.beenSetup = true
	hook.Run("PostSetupPlayer", ply)
end

function IMPULSE:ShowHelp()
	return
end

local talkCol = Color(255, 255, 100)
local infoCol = Color(135, 206, 250)

function IMPULSE:PlayerSay(ply, text, teamChat, newChat)
	if not ply.beenSetup then return "" end -- keep out players who are not setup yet
	if teamChat == true then return "" end -- disabled team chat

	hook.Run("iPostPlayerSay", ply, text)

	if string.StartWith(text, "/") then
		local args = string.Explode(" ", text)
		local command = impulse.chatCommands[string.lower(args[1])]
		if command then
			if command.cooldown and command.lastRan then
				if command.lastRan + command.cooldown > CurTime() then
					return ""
				end
			end

			if command.adminOnly == true and ply:IsAdmin() == false then
				ply:Notify("You must be an admin to use this command.")
				return ""
			end

			if command.superAdminOnly == true and ply:IsSuperAdmin() == false then
				ply:Notify("You must be an super admin to use this command.")
				return ""
			end

			if command.requiresArg == true and (not args[2] or string.Trim(args[2]) == "") then return "" end
			if command.requiresAlive == true and not ply:Alive() then return "" end

			text = string.sub(text, string.len(args[1]) + 2)

			table.remove(args, 1)
			command.onRun(ply, args, text)
		else
			ply:Notify("The command "..args[1].." does not exist.")
		end
	elseif ply:Alive() then
		text = hook.Run("ProcessICChatMessage", ply, text) or text
		text = hook.Run("ChatClassMessageSend", 1, text, ply) or text

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then
				k:SendChatClassMessage(1, text, ply)
			end
		end

		hook.Run("PostChatClassMessageSend", 1, text, ply)
	end

	return ""
end

local function canHearCheck(listener) -- based on darkrps voice chat optomization this is called every 0.5 seconds in the think hook
	if not IsValid(listener) then return end

	listener.CanHear = listener.CanHear or {}
	local listPos = listener:GetShootPos()
	local voiceDistance = impulse.Config.VoiceDistance ^ 2

	for _,speaker in ipairs(player.GetAll()) do
		listener.CanHear[speaker] = (listPos:DistToSqr(speaker:GetShootPos()) < voiceDistance)
	end
end

function IMPULSE:PlayerCanHearPlayersVoice(listener, speaker)
	if not speaker:Alive() then return false end

	local canHear = listener.CanHear and listener.CanHear[speaker]
	return canHear, true
end

function IMPULSE:UpdatePlayerSync(ply)
	for v,k in pairs(impulse.Sync.Data) do
		local ent = Entity(v)

		if IsValid(ent) then
			for id,conditional in pairs(impulse.Sync.VarsConditional) do
				if ent:GetSyncVar(id) and conditional(ply) then
					ent:SyncSingle(id, ply)
				end
			end
		end
	end
end

function IMPULSE:DoPlayerDeath(ply)
	local vel = ply:GetVelocity()

	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetSkin(ply:GetSkin())
	ragdoll.DeadPlayer = ply
	ragdoll.CanConstrain = false
	ragdoll.NoCarry = true

	for v,k in pairs(ply:GetBodyGroups()) do
		ragdoll:SetBodygroup(k.id, ply:GetBodygroup(k.id))
	end

	ragdoll:Spawn()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)

	for x=0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObject(x)

		if bone and bone:IsValid() then
			local pos, ang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(x))
			bone:SetPos(pos)
			bone:SetAngles(ang)
			bone:AddVelocity(vel)
		end
	end

	timer.Simple(impulse.Config.BodyDeSpawnTime, function()
		if ragdoll and IsValid(ragdoll) then
			ragdoll:Remove()
		end
	end)

	timer.Simple(0.1, function()
		if IsValid(ragdoll) and IsValid(ply) then
			net.Start("impulseRagdollLink")
			net.WriteEntity(ragdoll)
			net.Send(ply)
		end
	end)

	return true
end

function IMPULSE:PlayerDeath(ply)
	local wait = impulse.Config.RespawnTime

	if ply:IsDonator() then
		wait = impulse.Config.RespawnTimeDonator
	end

	ply.respawnWait = CurTime() + wait

	local money = ply:GetMoney()

	if money > 0 then
		ply:SetMoney(0)
		impulse.SpawnMoney(ply:GetPos(), money)
	end
end

function IMPULSE:PlayerDeathThink(ply)
	if ply.respawnWait < CurTime() then
		ply:Spawn()
	end

	return true
end

function IMPULSE:PlayerDeathSound()
	return true
end

function IMPULSE:CanPlayerSuicide()
	return false
end

function IMPULSE:OnPlayerChangedTeam() -- get rid of it logging team changes to console
end

function IMPULSE:SetupPlayerVisibility(ply)
	if ply.extraPVS then
		AddOriginToPVS(ply.extraPVS)
	end
end

function IMPULSE:KeyPress(ply, key)
	if ply:IsAFK() then
		ply:UnMakeAFK()	
	end

	ply.AFKTimer = CurTime() + impulse.Config.AFKTime

	if key == IN_RELOAD then
		timer.Create("impulseRaiseWait"..ply:SteamID(), 1, 1, function()
			if IsValid(ply) then
				ply:ToggleWeaponRaised()
			end
		end)
	elseif key == IN_USE and not ply:InVehicle() then
		local trace = {}
		trace.start = ply:GetShootPos()
		trace.endpos = trace.start + ply:GetAimVector() * 96
		trace.filter = ply

		local entity = util.TraceLine(trace).Entity

		if IsValid(entity) and entity:IsPlayer() then
			if ply:CanArrest(entity) then
				if not entity.ArrestedDragger then
					ply:DragPlayer(entity)
				else
					entity:StopDrag()
				end
			end
		end
	end
end

function IMPULSE:PlayerUse(ply, entity)
	if (ply.useNext or 0) > CurTime() then return false end
	ply.useNext = CurTime() + 0.3

	local btnKey = entity.ButtonCheck

	if btnKey and impulse.Config.Buttons[btnKey] then
		local btnData = impulse.Config.Buttons[btnKey]

		if btnData.customCheck and not btnData.customCheck(ply, entity) then
			ply.useNext = CurTime() + 1
			return false
		end

		if btnData.doorgroup then
			local teamDoorGroups = impulse.Teams.Data[ply:Team()].doorGroup

			if not teamDoorGroups or not table.HasValue(teamDoorGroups, doorGroup) then
				ply.useNext = CurTime() + 1
				ply:Notify("You don't have access to use this button.")
				return false
			end
		end
	end
end

function IMPULSE:KeyRelease(ply, key)
	if key == IN_RELOAD then
		timer.Remove("impulseRaiseWait"..ply:SteamID())
	end
end

local function LoadButtons()
	for a,button in pairs(ents.FindByClass("func_button")) do
		for v,k in pairs(impulse.Config.Buttons) do
			if k.pos:DistToSqr(button:GetPos()) < (9 ^ 2) then -- getpos client/server innaccuracy
				button.ButtonCheck = v
			end
		end
	end
end

function IMPULSE:InitPostEntity()
	impulse.Doors.Load()

	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt or k.IsZoneTrigger then
			k:Remove()
		end
	end

	LoadSaveEnts()

	for v,k in pairs(impulse.Config.Zones) do
		local zone = ents.Create("impulse_zone")
		zone:SetBounds(k.pos1, k.pos2)
		zone.Zone = v
	end

	if impulse.Config.BlacklistEnts then
		for v,k in pairs(ents.GetAll()) do
			if impulse.Config.BlacklistEnts[k:GetClass()] then
	            k:Remove()
	        end
	    end
	end

	LoadButtons()
end

LoadButtons()

function IMPULSE:PostCleanupMap()
	IMPULSE:InitPostEntity()
end

function IMPULSE:GetFallDamage(ply, speed)
	return (speed / 8)
end

local lastAFKScan
function IMPULSE:Think()
	for v,k in pairs(player.GetAll()) do
		if not k.nextHungerUpdate then k.nextHungerUpdate = CurTime() + impulse.Config.HungerTime end

		if k:Alive() and k.nextHungerUpdate < CurTime() then
			k:FeedHunger(-1)
			if k:GetSyncVar(SYNC_HUNGER, 100) < 1 then
				k:TakeDamage(1, k, k)
				k.nextHungerUpdate = CurTime() + 1
			else
				k.nextHungerUpdate = CurTime() + impulse.Config.HungerTime
			end
		end

		if not k.nextHearUpdate or k.nextHearUpdate < CurTime() then -- optomized version of canhear hook based upon darkrp
			canHearCheck(k)
			k.nextHearUpdate = CurTime() + 0.65
		end
	end

	for v,k in pairs(impulse.Arrest.Dragged) do
		if not IsValid(v) then
			impulse.Arrest.Dragged[v] = nil
			continue
		end

		local dragger = v.ArrestedDragger

		if IsValid(dragger) then
			if (dragger:GetPos() - v:GetPos()):LengthSqr() >= (175 ^ 2) then
				v:StopDrag()
			end
		else
			v:StopDrag()
		end
	end

	if (lastAFKScan or 0) < CurTime() then
		lastAFKScan = CurTime() + 2

		for v,k in pairs(player.GetAll()) do
			if k.AFKTimer and k.AFKTimer < CurTime() and not k:IsAFK() then
				k:MakeAFK()
			end
		end
	end
end

function IMPULSE:PlayerCanPickupWeapon(ply)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	return true
end

function IMPULSE:PlayerSpawnRagdoll(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerSpawnSENT(ply)
	return ply:IsSuperAdmin()
end

function IMPULSE:PlayerSpawnSWEP(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerGiveSWEP(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerSpawnedEffect(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerSpawnNPC(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerSpawnProp(ply, model)
	if not ply:Alive() or not ply.beenSetup or ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	return self.BaseClass:PlayerSpawnProp(ply, model)
end

function IMPULSE:PlayerSpawnVehicle(ply, model)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	if ply:IsDonator() and model:find("chair") or model:find("seat") or model:find("pod") then
		return true
	else
		return ply:IsSuperAdmin()
	end
end

function IMPULSE:PlayerSpawnedProp(ply, model, ent)
	--self.BaseClass:PlayerSpawnedProp(ply, model, ent)

	if ply:IsAdmin() then
		return
	end

	local price = impulse.Config.PropPrice

	if ply:IsDonator() then
		price = impulse.Config.PropPriceDonator
	end

	if ply:CanAfford(price) then
		ply:TakeMoney(price)
		ply:Notify("You have purchased a prop for "..impulse.Config.CurrencyPrefix..price..".")
	else
		ply:Notify("You need "..impulse.Config.CurrencyPrefix..price.." to spawn this prop.")
		SafeRemoveEntity(ent)
		return false
	end
end

function IMPULSE:CanDrive()
	return false
end

function IMPULSE:CanProperty()
	return false
end

local bannedTools = {
	["duplicator"] = true,
	["physprop"] = true,
	["dynamite"] = true,
	["eyeposer"] = true,
	["faceposer"] = true,
	["fingerposer"] = true,
	["inflator"] = true,
	["trails"] = true,
	["paint"] = true,
	["wire_explosive"] = true,
	["wire_simple_explosive"] = true,
	["wire_turret"] = true,
	["wire_user"] = true
}

local dupeBannedTools = {
	["weld"] = true,
	["weld_ez"] = true,
	["spawner"] = true,
	["duplicator"] = true,
	["adv_duplicator"] = true
}

local donatorTools = {
	["wire_expression2"] = true,
	["wire_spu"] = true,
	["wire_egp"] = true
}

function IMPULSE:CanTool(ply, tr, tool)
	if not ply:IsAdmin() and tool == "spawner" then
		return false
	end

	if bannedTools[tool] then
		return false
	end

	if donatorTools[tool] and not ply:IsDonator() then
		ply:Notify("This tool is restricted to donators only.")
		return false
	end

    local ent = tr.Entity

    if IsValid(ent) then
        if ent.onlyremover then
            if tool == "remover" then
                return ply:IsAdmin() or ply:IsSuperAdmin()
            else
                return false
            end
        end

        if ent.nodupe and dupeBannedTools[tool] then
            return false
        end
	end

	return true
end

local bannedDupeEnts = {
	["gmod_wire_explosive"] = true,
	["gmod_wire_simple_explosive"] = true,
	["gmod_wire_turret"] = true,
	["gmod_wire_user"] = true
}

local donatorDupeEnts = {
	["gmod_wire_expression2"] = true,
	["gmod_wire_spu"] = true,
	["prop_vehicle_prisoner_pod"] = true,
	["gmod_wire_epg"] = true
}

local whitelistDupeEnts = {
	["gmod_wheel"] = true,
	["gmod_lamp"] = true,
	["gmod_emitter"] = true,
	["gmod_button"] = true,
	["gmod_cameraprop"] = true,
	["prop_dynamic"] = true,
	["prop_physics"] = true,
	["gmod_light"] = true,
	["prop_door_rotating"] = true -- door tool
}

function IMPULSE:ADVDupeIsAllowed(ply, class, entclass) -- adv dupe 2 can be easily exploited, you must have the impulse version of AD2 for this to work
	if bannedDupeEnts[class] then
		return false
	end

	if donatorDupeEnts[class] then
		if ply:IsDonator() then
			return true
		else
			ply:Notify("This entity is restricted to donators only.")
			return false
		end
	end

	if whitelistDupeEnts[class] or string.sub(class, 1, 9) == "gmod_wire" then
		return true
	end

	return false
end

function IMPULSE:SetupMove(ply, mvData)
	if ply:GetSyncVar(SYNC_ARRESTED, false) and ply.ArrestedDragger then
		mvData:SetMaxClientSpeed(mvData:GetMaxClientSpeed() / 3)
	elseif isValid(ply.ArrestedDragging) then
		mvData:SetMaxClientSpeed(mvData:GetMaxClientSpeed() / 3)
	end
end

function IMPULSE:CanPlayerEnterVehicle(ply, veh)
	if ply:GetSyncVar(SYNC_ARRESTED, false) or ply.ArrestedDragging then
		return false
	end

	return true
end

function IMPULSE:CanExitVehicle(veh, ply)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	return true
end

function IMPULSE:PlayerSetHandsModel(ply, hands)
	local handModel = impulse.Teams.Data[ply:Team()].handModel

	if handModel then
		hands:SetModel(handModel)
		return
	end

	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)

	if info then
		hands:SetModel(info.model)
		hands:SetSkin(info.skin)
		hands:SetBodyGroups(info.body)
	end
end

function IMPULSE:PlayerSpray()
	return true
end

function IMPULSE:PlayerShouldTakeDamage(ply, attacker)
	if ply.SpawnProtection then
		return false
	end

	return true
end