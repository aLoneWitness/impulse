concommand.Add("impulse_debug_pos", function(ply)
	local pos = ply:GetPos()

	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ang", function(ply)
	local pos = ply:GetAngles()

	local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_hudtoggle", function(ply)
	impulse_DevHud = !impulse_DevHud
end)