hook.Add("PlayerNoClip", "opsNoclip", function(ply, state)
	return ply:IsAdmin()
end)