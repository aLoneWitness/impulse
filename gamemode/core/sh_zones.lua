function meta:InArea(area)
	local pos = self:GetPos() + self:OBBCenter()

	return pos:WithinAABox(area.Pos1, area.Pos2)
end

function meta:GetArea()
	return self.impulseArea
end

local function ZoneTick()
	for v,k in pairs(player.GetAll()) do
		local currentArea = k:GetArea()

		if k:Alive() then
			for a,b in pairs(impulse.Config.Areas) do
				local name = b.name

				if k:InArea(b) then
					if name != currentArea then
						k.impulseArea = name
					end
				end
			end
		end
	end
end

timer.Create("impulseZoneTick", 0.33, 0, ZoneTick)