/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

local start = 0

hook.Add("HUDPaint", "IMPULSE-MEDICAL-HUD", function()
	surface.SetDrawColor(255,255,255,255)
	start = 0
	for v,k in pairs(impulse.medical.InflictedConditions) do
		surface.SetMaterial(impulse.medical.Conditions[k].icon)
		surface.DrawTexturedRect(SizeW(1844), SizeH(700)+start, SizeW(72), SizeH(72))
		start = start + SizeH(72)
	end
end)