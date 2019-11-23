
impulse.chatCommands = impulse.chatCommands or {}
impulse.chatClasses = impulse.chatClasses or {}

function impulse.RegisterChatCommand(name, cmdData)
	if not cmdData.adminOnly then cmdData.adminOnly = false end
	if not cmdData.superAdminOnly then cmdData.superAdminOnly = false end
	if not cmdData.description then cmdData.description = "" end
	if not cmdData.requiresArg then cmdData.requiresArg = false end
	if not cmdData.requiresAlive then cmdData.requiresAlive = false end

    impulse.chatCommands[name] = cmdData
end

if SERVER then
	util.AddNetworkString("impulseChatNetMessage")
	function meta:SendChatClassMessage(id, message, target)
		net.Start("impulseChatNetMessage")
		net.WriteUInt(id, 8)
		net.WriteString(message)
		if target then
			net.WriteUInt(target:EntIndex(), 8)
		end
		net.Send(self)
	end
else
	function impulse.RegisterChatClass(id, onReceive)
		impulse.chatClasses[id] = onReceive
	end
end

local oocCol = color_white
local oocTagCol = Color(200, 0, 0)
local yellCol = Color(255, 140, 0)
local whisperCol = Color(65, 105, 225)
local infoCol = Color(135, 206, 250)
local talkCol = Color(255, 255, 100)
local radioCol = Color(55, 146, 21)
local pmCol = Color(45, 154, 6)

local oocCommand = {
	description = "Talk out of character globally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		if impulse.OOCClosed then
			return ply:Notify("OOC chat has been suspsended by the game moderators and will return shortly.")	
		end

		local timeout = impulse.OOCTimeouts[ply:SteamID()]
		if timeout then
			return ply:Notify("You have an active OOC timeout that will remain for "..string.NiceTime(timeout - CurTime())..".")
		end

		ply.OOCLimit = ply.OOCLimit or ((ply:IsDonator() and impulse.Config.OOCLimitVIP) or impulse.Config.OOCLimit)
		local timeLeft = timer.TimeLeft(ply:UserID().."impulseOOCLimit")

		if ply.OOCLimit < 1 and not ply:IsAdmin() then
			return ply:Notify("You have ran out of OOC messages. Wait "..string.NiceTime(timeLeft).." for more.")
		end

		for v,k in pairs(player.GetAll()) do
			k:SendChatClassMessage(2, rawText, ply)
		end

		ply.OOCLimit = ply.OOCLimit - 1

		net.Start("impulseUpdateOOCLimit")
		net.WriteUInt(timeLeft, 16)
		net.Send(ply)

		hook.Run("ProcessOOCMessage", rawText)
	end
}

impulse.RegisterChatCommand("/ooc", oocCommand)
impulse.RegisterChatCommand("//", oocCommand)

local loocCommand = {
	description = "Talk out of character locally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		if ply.hasOOCTimeout then
			return ply:Notify("You have an active OOC timeout that will remain for "..string.NiceTime(ply.hasOOCTimeout - CurTime())..".")
		end

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:SendChatClassMessage(3, rawText, ply)
			end
		end

		hook.Run("ProcessOOCMessage", rawText)
	end
}

impulse.RegisterChatCommand("/looc", loocCommand)
impulse.RegisterChatCommand("//.", loocCommand)

local pmCommand = {
	description = "Directly messages the player specified.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		local name = arg[1]
		local message = string.sub(rawText, (string.len(name) + 2))
		message = string.Trim(message)

		if not message or message == "" then
			return ply:Notify("Invalid argument.")
		end

		local plyTarget = impulse.FindPlayer(name)

		if plyTarget and ply != plyTarget then
			plyTarget:SendChatClassMessage(4, message, ply)
			ply:SendChatClassMessage(5, message, ply)
			plyTarget:SurfacePlaySound("buttons/blip1.wav")
			ply:SurfacePlaySound("buttons/blip1.wav")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
	end
}

impulse.RegisterChatCommand("/pm", pmCommand)

local yellCommand = {
	description = "Yell in character.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 6, rawText, ply) or rawText

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.YellDistance ^ 2) then 
				k:SendChatClassMessage(6, rawText, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/y", yellCommand)

local whisperCommand = {
	description = "Whisper in character.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 7, rawText, ply) or rawText

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.WhisperDistance ^ 2) then 
				k:SendChatClassMessage(7, rawText, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/w", whisperCommand)

local radioCommand = {
	description = "Send a radio message to all units.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 8, rawText, ply) or rawText

		if ply:IsCP() then
			for v,k in pairs(player.GetAll()) do
				if k:IsCP() then 
					k:SendChatClassMessage(8, rawText, ply)
				end
			end
		else
			hook.Run("RadioMessageFallback", ply, rawText)
		end
	end
}

impulse.RegisterChatCommand("/radio", radioCommand)
impulse.RegisterChatCommand("/r", radioCommand)

local meCommand = {
	description = "Preform an action in character.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:SendChatClassMessage(9, rawText, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/me", meCommand)

local itCommand = {
	description = "Perform an action from a third party.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:SendChatClassMessage(10, rawText, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/it", itCommand)

local advertCommand = {
	description = "Broadcasts the advert provided.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		if not impulse.Teams.Data[ply:Team()].canAdvert or impulse.Teams.Data[ply:Team()].canAdvert == false then 
			return ply:Notify("Your team cannot make an advert.") 
		end


		timer.Simple(15, function()
			if IsValid(ply) and ply:IsPlayer() then
				for v,k in pairs(player.GetAll()) do
					k:SendChatClassMessage(12, rawText, ply)
				end
			end
		end)

		ply:Notify("Your advert has been sent and will be broadcast shortly.")
	end
}

impulse.RegisterChatCommand("/advert", advertCommand)

local rollCommand = {
	description = "Generate a random number between 0 and 100.",
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		local rollResult = (tostring(math.random(1,100)))

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:SendChatClassMessage(11, rollResult, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/roll", rollCommand)

local dropMoneyCommand = {
	description = "Drops the specified amount of money on the floor.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		if arg[1] and tonumber(arg[1]) then
			local value = math.floor(tonumber(arg[1]))
			if ply:CanAfford(value) and value > 0 then
				ply:TakeMoney(value)

				local trace = {}
				trace.start = ply:EyePos()
				trace.endpos = trace.start + ply:GetAimVector() * 85
				trace.filter = ply

				local tr = util.TraceLine(trace)
				impulse.SpawnMoney(tr.HitPos, value)
				hook.Run("PlayerDropMoney")
				ply:Notify("You have dropped "..impulse.Config.CurrencyPrefix..value..".")
			else
				return ply:Notify("You cannot afford to drop that amount of money.")
			end
		else
			return ply:Notify("Invalid argument.")
		end
	end
}

impulse.RegisterChatCommand("/dropmoney", dropMoneyCommand)

local writeCommand = {
	description = "Writes a letter with the text specified.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, args, text)
		if ply.letterCount and ply.letterCount > impulse.Config.MaxLetters then
			ply:Notify("You have reached the max amount of letters.")
			return
		end

		if string.len(text) > 900 then
			ply:Notify("Letter max character limit reached. (900)")
			return
		end

		text = impulse.SafeString(text)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local letter = ents.Create("impulse_letter")
		letter:SetPos(tr.HitPos)
		letter:SetText(text)
		letter:SetPlayerOwner(ply)
		letter:Spawn()

		undo.Create("letter")
		undo.AddEntity(letter)
		undo.SetPlayer(ply)
		undo.Finish()
	end
}

impulse.RegisterChatCommand("/write", writeCommand)

local searchCommand = {
	description = "Searches a players inventory.",
	requiresArg = false,
	requiresAlive = true,
	onRun = function(ply, args, text)
		if not ply:IsCP() then return end
		if ply.InvSearching and IsValid(ply.InvSearching) then return end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 50
		trace.filter = ply

		local tr = util.TraceLine(trace)
		local targ = tr.Entity

		if targ and IsValid(targ) and targ:IsPlayer() and targ:OnGround() then
			if not targ.beenInvSetup then return end

			if not ply:CanArrest(targ) then
				return ply:Notify("You cannot search this player.")
			end

			if not targ:GetSyncVar(SYNC_ARRESTED, false) then
				return ply:Notify("You must detain a player before searching them.")
			end

			targ:Freeze(true)
			targ:Notify("You are currently being searched.")
			ply:Notify("You have started searching "..targ:Nick()..".")
			ply.InvSearching = targ
			hook.Run("DoInventorySearch", ply, targ)

			local inv = targ:GetInventory(1)
			net.Start("impulseInvDoSearch")
			net.WriteUInt(targ:EntIndex(), 8)
			net.WriteUInt(table.Count(inv), 16)
			for v,k in pairs(inv) do
				local netid = impulse.Inventory.ClassToNetID(k.class)
				net.WriteUInt(netid, 10)
			end
			net.Send(ply)
		else
			ply:Notify("No player in search range.")
		end
	end
}

impulse.RegisterChatCommand("/invsearch", searchCommand)

local eventCommand = {
	description = "Sends a global chat message to all players. Only for use in events.",
	adminOnly = true,
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			k:SendChatClassMessage(14, rawText, ply)
		end
	end
}

impulse.RegisterChatCommand("/event", eventCommand)



if CLIENT then
	local talkCol = Color(255, 255, 100)
	local infoCol = Color(135, 206, 250)
	local oocCol = color_white
	local oocTagCol = Color(200, 0, 0)
	local yellCol = Color(255, 140, 0)
	local whisperCol = Color(65, 105, 225)
	local infoCol = Color(135, 206, 250)
	local talkCol = Color(255, 255, 100)
	local radioCol = Color(55, 146, 21)
	local pmCol = Color(45, 154, 6)
	local advertCol = Color(255, 174, 66)
	local acCol = Color(0, 235, 0, 255)
	local eventCol = Color(255, 69, 0)
	local fallbackRankCol = Color(211, 211, 211)
	local rankCols = {}
	rankCols["superadmin"] = Color(201, 15, 12)
	rankCols["admin"] = Color(34, 88, 216)
	rankCols["moderator"] = Color(34, 88, 216)
	rankCols["donator"] = Color(212, 185, 9)

	impulse.RegisterChatClass(1, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message

		chat.AddText(speaker, talkCol, " says: ", message)
	end)

	impulse.RegisterChatClass(2, function(message, speaker)
		chat.AddText(oocTagCol, "[OOC] ", (rankCols[speaker:GetUserGroup()] or fallbackRankCol), speaker:SteamName(), oocCol, ": ", message)
	end)

	impulse.RegisterChatClass(3, function(message, speaker)
		chat.AddText(oocTagCol, "[LOOC] ", (rankCols[speaker:GetUserGroup()] or fallbackRankCol), speaker:SteamName(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", oocCol, ": ",  message)
	end)

	impulse.RegisterChatClass(4, function(message, speaker)
		chat.AddText(pmCol, "[PM] ", speaker:SteamName(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", pmCol, ": ", message)
	end)

	impulse.RegisterChatClass(5, function(message, speaker)
		chat.AddText(pmCol, "[PM SENT] ", speaker:SteamName(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", pmCol, ": ", message)
	end)

	impulse.RegisterChatClass(6, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message

		impulse.customChatFont = "Impulse-ChatLarge"
		chat.AddText(speaker, yellCol, " yells: ", message)
	end)

	impulse.RegisterChatClass(7, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message
		
		impulse.customChatFont = "Impulse-ChatSmall"
		chat.AddText(speaker, whisperCol, " whispers: ", message)
	end)

	impulse.RegisterChatClass(8, function(message, speaker)
		impulse.customChatFont = "Impulse-ChatRadio" 
		chat.AddText(radioCol, "[RADIO] ", speaker:Name(), ": ", message)
	end)

	impulse.RegisterChatClass(9, function(message, speaker)
		chat.AddText(talkCol, speaker:Name(), " ", message)
	end)

	impulse.RegisterChatClass(10, function(message, speaker)
		chat.AddText(infoCol, "** ", message)
	end)

	impulse.RegisterChatClass(11, function(message, speaker)
		chat.AddText(speaker, yellCol, " rolled ", message)
	end)

	impulse.RegisterChatClass(12, function(message, speaker)
		chat.AddText(advertCol, "[ADVERT] ", speaker:Name(), ": ", message)
	end)

	impulse.RegisterChatClass(13, function(message, speaker)
		chat.AddText(acCol, "[Admin Chat] ", speaker:SteamName(), ": ", acCol, message)
	end)

	impulse.RegisterChatClass(14, function(message, speaker)
		chat.AddText(eventCol, "[EVENT] ", message)
	end)
end