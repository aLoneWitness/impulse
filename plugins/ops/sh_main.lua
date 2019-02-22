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