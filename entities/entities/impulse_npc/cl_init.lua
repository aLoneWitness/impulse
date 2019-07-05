include("shared.lua")

ENT.AutomaticFrameAdvance = true

function ENT:Think()
	if ((self.nextAnimCheck or 0) < CurTime()) then
		self:SetAnimation()
		self.nextAnimCheck = CurTime() + 60
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end