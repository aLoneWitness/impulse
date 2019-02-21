function IMPULSE:PlayerInitialSpawn(ply)
	local isNew = true

	-- sync players with all other clients
	impulse.Sync.Data[ply:EntIndex()] = {}
	for v,k in pairs(impulse.Sync.Data) do
		local ent = Entity(v)
		if IsValid(ent) then
			ent:Sync(ply)
		end
	end

	-- sync players with all other doors
	for doorID, doorData in pairs(impulse.Doors.Data) do
		for key, value in pairs(doorData) do
			netstream.Start(ply, "iDoorU", doorID, key, value)
		end
	end

	local query = mysql:Select("impulse_players")
	query:Select("rpname")
	query:Select("group")
	query:Select("xp")
	query:Select("money")
	query:Select("bankmoney")
	query:Select("model")
	query:Select("skin")
	query:Select("data")
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
		ply:GiveTimedXP()
	end)
end

function IMPULSE:PlayerSpawn(ply)
	if ply.beenSetup then
		ply:SetTeam(impulse.Config.DefaultTeam)
	end

	ply:SetHunger(100)

	ply:GodEnable()
	ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetColor(Color(200, 200, 200, 100))

	timer.Simple(10, function()
		if IsValid(ply) then
			ply:GodDisable()
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:SetColor(color_white)
		end
	end)

	hook.Run("PlayerLoadout", ply)
end

function IMPULSE:PlayerDisconnected(ply)
	ply:SyncRemove()

	for doorID, doorData in pairs(impulse.Doors.Data) do -- remove player from owned doors on disconnect
		local door = Entity(doorID)
		local owners = doorData.owners
		if IsValid(door) and owners and owners[ply:UserID()] then
			if #owners <= 1 then
				owners = nil
			else
				owners[ply:UserID()] = nil
			end
			door:DoorDataUpdate("owners", owners)
		end
	end

	timer.Remove(ply:UserID().."impulseXP")
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

	ply.impulseData = util.JSONToTable(dbData.data or "[]")

	ply.defaultModel = dbData.model
	ply.defaultSkin = dbData.skin
	ply:SetFOV(90, 0)
	ply:SetTeam(impulse.Config.DefaultTeam)
	ply:AllowFlashlight(true)
	ply.beenSetup = true

	hook.Run("PostSetupPlayer", ply)
end

function IMPULSE:ShowHelp()
	return
end

local talkCol = Color(255, 255, 100)
local infoCol = Color(135, 206, 250)

function IMPULSE:PlayerSay(ply, text, teamChat)
	if not ply.beenSetup or ply.beenSetup == false then return "" end -- keep out players who are not setup yet
	if teamChat == true then return "" end -- disabled team chat

	if string.StartWith(text, "/") then
		local args = string.Explode(" ", text)
		local command = impulse.chatCommands[string.lower(args[1])]
		if command then
			if command.adminOnly == true and ply:IsAdmin() == false then 
				ply:AddChatText(infoCol, "You must be an admin to use this command.")
				return "" 
			end
			if command.superAdminOnly == true and ply:IsSuperAdmin() == false then 
				ply:AddChatText(infoCol, "You must be an super admin to use this command.")
				return "" 
			end
			if command.requiresArg == true and (not args[2] or string.Trim(args[2]) == "") then return "" end
			if command.requiresAlive == true and not ply:Alive() then return "" end

			text = string.sub(text, string.len(args[1]) + 2)

			table.remove(args, 1)
			command.onRun(ply, args, text)
		else
			ply:AddChatText(infoCol, "The command "..args[1].." does not exist.")
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

function IMPULSE:PlayerCanHearPlayersVoice(listener, speaker)
	if listener:GetPos():DistToSqr(speaker:GetPos()) > impulse.Config.VoiceDistance ^ 2 then
		return false, false
	end 

	return true, true
end

function IMPULSE:PlayerDeath(ply)
	local wait = impulse.Config.RespawnTime

	if ply:IsDonator() then
		wait = impulse.Config.RespawnTimeDonator
	end

	ply.respawnWait = CurTime() + wait
end

function IMPULSE:PlayerDeathThink(ply)
	if ply.respawnWait < CurTime() then
		ply:Spawn()
	end

	return true
end

function IMPULSE:PlayerDeathSound()
	return false
end

function IMPULSE:SetupPlayerVisibility(ply)
	if ply.extraPVS then
		AddOriginToPVS(ply.extraPVS)
	end
end

function IMPULSE:KeyPress(ply, key)
	if key == IN_RELOAD then
		timer.Create("impulseRaiseWait"..ply:SteamID(), 1, 1, function()
			if IsValid(ply) then
				ply:ToggleWeaponRaised()
			end
		end)
	elseif key == IN_USE then
		local trace = {}
		trace.start = ply:GetShootPos()
		trace.endpos = trace.start + ply:GetAimVector() * 96
		trace.filter = ply

		local entity = util.TraceLine(trace).Entity

		if IsValid(entity) and entity:IsDoor() or entity:IsPlayer() then
			hook.Run("PlayerUse", ply, entity)
		end
	end
end

function IMPULSE:KeyRelease(ply, key)
	if key == IN_RELOAD then
		timer.Remove("impulseRaiseWait"..ply:SteamID())
	end
end

function IMPULSE:InitPostEntity()
	impulse.Doors.Load()

	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			k:Remove()
		end
	end

	LoadSaveEnts()
end

function IMPULSE:GetFallDamage(ply, speed)
	return (speed / 8)
end

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
	end
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

function IMPULSE:PlayerSpawnNPC(ply)
	return ply:IsAdmin()
end

function IMPULSE:PlayerSpawnProp(ply, model)
	if not ply.beenSetup then
		return false
	end

	return self.BaseClass:PlayerSpawnProp(ply, model)
end

function IMPULSE:PlayerSpawnVehicle(ply, model)
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

	if ply:CanAffordBank(price) then
		ply:TakeBankMoney(price)
		ply:Notify("You have purchased a prop for "..impulse.Config.CurrencyPrefix..price.." (deducted from bank account).")
	else
		ply:Notify("You need "..impulse.Config.CurrencyPrefix..price.." to spawn this prop.")
		SafeRemoveEntity(ent)
		return false
	end
end
