concommand.Add("impulse_debug_pos", function(ply)
	local pos = ply:GetPos()

	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ang", function(ply)
	local pos = ply:EyeAngles()

	local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ent_ang", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	local pos = traceEnt:GetAngles()
	local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
	chat.AddText(traceEnt)
	chat.AddText(output)
	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ent_pos", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	local pos = traceEnt:GetPos()
	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(traceEnt)
	chat.AddText(output)
	SetClipboardText(output)
end)

concommand.Add("impulse_debug_hudtoggle", function(ply)
	impulse_DevHud = !impulse_DevHud
end)

concommand.Add("impulse_debug_iconeditor", function(ply)
	if ply:IsSuperAdmin() or ply:IsDeveloper() then
		vgui.Create("impulseIconEditor")
	end
end)

concommand.Add("impulse_debug_wtl", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	if impulse_DebugTargPos then
		local pos = traceEnt:WorldToLocal(impulse_DebugTargPos)
		local ang = traceEnt:WorldToLocalAngles(impulse_DebugTargAng)

		chat.AddText("Base entity selected. World-To-Local output below and in console:")

		local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
		chat.AddText(output)

		local output = "Angle("..ang.p..", "..ang.y..", "..ang.r..")"
		chat.AddText(output)
		
		impulse_DebugTargAng = nil
		impulse_DebugTargPos = nil
		return
	end

	impulse_DebugTargPos = traceEnt:GetPos()
	impulse_DebugTargAng = traceEnt:GetAngles()
	chat.AddText("Target entity selected as "..tostring(traceEnt)..". Please run the command looking at the child entity for output.")
end)