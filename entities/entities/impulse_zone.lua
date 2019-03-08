if SERVER then
	ENT.Base = "base_brush"
	ENT.Type = "brush"
	ENT.Zone = 1
	ENT.IsZoneTrigger =  true

	-- Updates the bounds of this collision box
	function ENT:SetBounds(min, max)
	    self:SetSolid(SOLID_BBOX)
	    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) -- no collisions
	    self:SetCollisionBoundsWS(min, max)
	    self:SetTrigger(true)
	end

	-- Run when any entity starts touching our trigger
	function ENT:StartTouch(ply)
	    if ply:IsPlayer() then
	        ply.impulseZone = self.Zone
	    end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_NEVER
	end
end