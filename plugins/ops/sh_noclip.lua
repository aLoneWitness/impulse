hook.Add("PlayerNoClip", "opsNoclip", function(ply, state)
	return ply:IsAdmin()
end)


if CLIENT then
	hook.Add("PlayerBindPress", "opsDoubleNoclip", function(ply, bind, pressed)
		if ply:IsAdmin() and bind == "noclip" then
			if not ply.lastNoclipTap or ply.lastNoclipTap + 1 < CurTime() and ply:GetMoveType() == 2 then
				ply:Notify("Press your noclip key again.")
				ply.lastNoclipTap = CurTime()
				return true
			end
		end
	end)
end