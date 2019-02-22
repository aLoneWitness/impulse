hook.Add("PhysgunPickup", "opsPhysgunPickup", function(ply, ent)
	if ply:IsAdmin() and ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_NONE)
		return true
	end
end)

hook.Add("PhysgunDrop", "opsPhysgunDrop", function(ply, ent)
	if ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_WALK)
	end
end)

local adminChatCol = Color(34, 88, 216)
local adminChatCommand = {
    description = "Respawns the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        for v,k in pairs(player.GetAll()) do
        	if k:IsAdmin() then
        		k:AddChatText("[ADMIN CHAT] ", adminChatCol, ply:SteamName()..": "..rawText)
        	end
        end
    end
}

impulse.RegisterChatCommand("/ac", adminChatCommand)