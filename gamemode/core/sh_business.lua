/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Business = impulse.Business or {}
impulse.Business.Data = impulse.Business.Data or {}

function impulse.Business.Define(name, buyableData)
    impulse.Business.Data[name] = buyableData
end

function meta:CanBuy(name)
	local buyable = impulse.Business.Data[name]

	if buyable.teams and table.HasValue(buyable.teams, self:Team()) then
		return true
	end

	return false
end