
include("shared.lua")

ENT.AutomaticFrameAdvance = true
function ENT:Initialize()
	self:CreateBubble()
end

function ENT:CreateBubble()
	self.bubble = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
	self.bubble:SetPos(self:GetPos() + Vector(0, 0, 84))
	self.bubble:SetModelScale(0.6, 0)
end

function ENT:Draw()
	local realTime = RealTime()

	self:FrameAdvance(realTime - (self.lastTick or realTime))
	self.lastTick = realTime
	
	local bubble = self.bubble
	
	if (IsValid(bubble)) and LocalPlayer():GetPos():Distance(self:GetPos()) < 1000 then
		bubble:SetNoDraw(false)
		local realTime = RealTime()

		bubble:SetRenderOrigin(self:GetPos() + Vector(0, 0, 84 + math.sin(realTime * 3) * 0.75))
		bubble:SetRenderAngles(Angle(0, realTime * 100, 0))
	elseif IsValid(bubble) then
		bubble:SetNoDraw(true)
	end

	self:DrawModel()
end

function ENT:Think()
	if (!IsValid(self.bubble)) then
		self:createBubble()
	end

	if ((self.nextAnimCheck or 0) < CurTime()) then
		self:SetAnimation()
		self.nextAnimCheck = CurTime() + 60
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end

function ENT:OnRemove()
	if (IsValid(self.bubble)) then
		self.bubble:Remove()
	end
end