function meta:GetZone()
	return self.impulseZone
end

function meta:SetZone(id)
	local zoneName = impulse.Config.Zones[id].name
	self.impulseZone = id
end