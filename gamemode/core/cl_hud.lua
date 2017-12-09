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
