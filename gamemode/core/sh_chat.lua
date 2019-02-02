
impulse.chatCommands = impulse.chatCommands or {}

function impulse.RegisterChatCommand(name, cmdData)
	if not cmdData.adminOnly then cmdData.adminOnly = false end
	if not cmdData.superAdminOnly then cmdData.superAdminOnly = false end
	if not cmdData.description then cmdData.description = "" end
	if not cmdData.requiresArg then cmdData.requiresArg = false end

    impulse.chatCommands[name] = cmdData
end

function impulse.FindPlayer(searchKey)
	if not searchKey or searchKey == "" then return nil end
	local searchPlayers = player.GetAll()
	local lowerKey = string.lower(tostring(searchKey))

	for k = 1, #searchPlayers do
		local v = searchPlayers[k]

		if searchKey == v:SteamID() then
			return v
		end

        if string.find(string.lower(v:Name()), lowerKey, 1, true) ~= nil then
            return v
        end

        if string.find(string.lower(v:SteamName()), lowerKey, 1, true) ~= nil then
            return v
		end
	end
	return nil
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
		for v,k in pairs(player.GetAll()) do
			k:AddChatText(oocTagCol, "[OOC] ", ply:SteamName(), oocCol, ":", rawText)
		end
	end
}

impulse.RegisterChatCommand("/ooc", oocCommand)
impulse.RegisterChatCommand("//", oocCommand)

local loocCommand = {
	description = "Talk out of character locally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:AddChatText(oocTagCol, "[LOOC] ", ply:SteamName(), (team.GetColor(ply:Team())), " (", ply:Name(), ")", oocCol, ":",  rawText)
			end
		end
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
			plyTarget:AddChatText(pmCol, "[PM] ", ply:SteamName(), (team.GetColor(ply:Team())), " (", ply:Name(), ")", pmCol, ": ", message)
			ply:AddChatText(pmCol, "[PM SENT] ", ply:SteamName(), (team.GetColor(ply:Team())), " (", ply:Name(), ")", pmCol, ": ", message)
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
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.YellDistance ^ 2) then 
				k:AddChatText(ply, yellCol, " yells:", rawText)
			end
		end
	end
}

impulse.RegisterChatCommand("/y", yellCommand)

local whisperCommand = {
	description = "Whisper in character.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.WhisperDistance ^ 2) then 
				k:AddChatText(ply, whisperCol, " whispers:", rawText)
			end
		end
	end
}

impulse.RegisterChatCommand("/w", whisperCommand)

local radioCommand = {
	description = "Send a radio message to all units.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		if not ply:IsCP() then return end
		for v,k in pairs(player.GetAll()) do
			if k:IsCP() then 
				k:AddChatText(radioCol, "[RADIO] ", ply:Name(), ":", rawText)
			end
		end
	end
}

impulse.RegisterChatCommand("/radio", radioCommand)
impulse.RegisterChatCommand("/r", radioCommand)

local meCommand = {
	description = "Preform an action in character.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:AddChatText(talkCol, ply:Name(), rawText)
			end
		end
	end
}

impulse.RegisterChatCommand("/me", meCommand)

local itCommand = {
	description = "Perform an action from a third party.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:AddChatText(infoCol, "**", rawText)
			end
		end
	end
}

impulse.RegisterChatCommand("/it", itCommand)

local rollCommand = {
	description = "Generate a random number between 0 and 100.",
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then 
				k:AddChatText(ply, yellCol, " rolled ", tostring(math.random(1,100)))
			end
		end
	end
}

impulse.RegisterChatCommand("/roll", rollCommand)

local dropMoneyCommand = {
	description = "Drops the specified amount of money on the floor.",
	requiresArg = true,
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