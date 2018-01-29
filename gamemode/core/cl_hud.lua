/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true

function IMPULSE:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

local vignette = Material("impulse/vignette.png")
local vig_alpha_normal = Color(10,10,10,180)

function IMPULSE:HUDPaint()
	surface.SetDrawColor(vig_alpha_normal)
	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end
