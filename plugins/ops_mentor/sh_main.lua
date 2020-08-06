function PLUGIN:CreateSyncVars()
	SYNC_MENTOR = impulse.Sync.RegisterVar(SYNC_BOOL)
end

if CLIENT then
	impulse.Badges.mentor = {Material("icon16/group.png"), "This player is a community mentor.", function(ply) return ply:GetSyncVar(SYNC_MENTOR, false) end}
end
impulse.MentorRequests = impulse.MentorRequests or {}

local helpCommand = {
	description = "Contacts a mentor for help.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		impulse.MentorRequests[ply:SteamID()] = impulse.MentorRequests[ply:SteamID()] or {}

		for v,k in pairs(player.GetAll()) do
			if k:GetSyncVar(SYNC_MENTOR, false) then
				k:SendChatClassMessage(61, rawText, ply)
			end
		end
	end
}

impulse.RegisterChatCommand("/mentor", helpCommand)


--impulse.RegisterChatCommand("/mclaim", )
--impulse.RegisterChatCommand("/mreply", )
--impulse.RegisterChatCommand("/mclose", )