function IMPULSE:PlayerInitialSpawn(ply)
	local isNew = true

	impulse.Sync.Data[ply:UserID()] = {}
	for v,k in pairs(player.GetAll()) do
		k:Sync(ply)
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
end

function IMPULSE:PlayerSpawn(ply)
	if ply.beenSetup then
		ply:SetTeam(impulse.Config.DefaultTeam)
	end

	hook.Run("PlayerLoadout", ply)
end

function IMPULSE:PlayerDisconnected(ply)
	ply:SyncRemove()
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
	ply:SetTeam(impulse.Config.DefaultTeam)
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

function IMPULSE:SetupPlayerVisibility(ply)
	if ply.extraPVS then
		AddOriginToPVS(ply.extraPVS)
	end
end