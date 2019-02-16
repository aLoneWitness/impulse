hook.Add("PlayerNoClip", "opsNoclip", function(ply, state)
	if ply:IsAdmin() then
		if SERVER then
			if state then
				impulse.Ops.Cloak(ply)
				ply:GodEnable()
			else
				impulse.Ops.Uncloak(ply)
				ply:GodDisable()
			end
		end

		return true
	end

	return false
end)