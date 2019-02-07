hook.Add("PhysgunPickup", "opsPhysgunPickup", function(ply, ent)
	if ply:IsAdmin() and ent:IsPlayer() then
		return true
	end
end)