
impulse.chatCommands = impulse.chatCommands or {}

function impulse.RegisterChatCommand(name, cmdData)
	if not cmdData.adminOnly then cmdData.adminOnly = false end
	if not cmdData.superAdminOnly then cmdData.superAdminOnly = false end
	if not cmdData.description then cmdData.description = "" end
	if not cmdData.requiresArg then cmdData.requiresArg = false end

    impulse.chatCommands[name] = cmdData
end

local oocCol = color_white
local yellCol = Color(255, 140, 0)
local whisperCol = Color(65, 105, 225)
local infoCol = Color(135, 206, 250)

local oocCommand = {
	description = "Talk out of character globally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			k:AddChatText(oocCol, "[OOC] ", ply:SteamName(), rawText)
		end
	end
}

impulse.RegisterChatCommand("/ooc", oocCommand)