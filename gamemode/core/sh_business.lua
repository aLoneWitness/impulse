/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Business = impulse.Business or {}
impulse.Business.Data = impulse.Business.Data or {}
impulse.Business.DataRef = impulse.Business.DataRef or {}

local busID = 0

function impulse.Business.Define(name, buyableData)
	busID = busID + 1
    impulse.Business.Data[name] = buyableData
    impulse.Business.DataRef[busID] = name
end

function meta:CanBuy(name)
	local buyable = impulse.Business.Data[name]

	if buyable.teams and not table.HasValue(buyable.teams, self:Team()) then
		return false
	end

	if buyable.classes and not table.HasValue(buyable.classes, self:GetTeamClass()) then
		return false
	end

	return true
end

function impulse.SpawnBuyable(pos, buyable)
	local spawnedBuyable = ents.Create(buyable.entity)

	if buyable.model then
		spawnedBuyable:SetModel(buyable.model)
	end

	if buyable.food then
		spawnedBuyable.food = buyable.food
	end
	
	spawnedBuyable:SetPos(pos)
	spawnedBuyable:Spawn()
end