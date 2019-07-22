AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Bench.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

	self:SetBenchType(self.Bench.Class)

	local phys = self:GetPhysicsObject()
	phys:Wake()
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end

function ENT:SetBench(bench)
	self.Bench = bench
end

function ENT:OnTakeDamage(dmg) 
	return false
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() and activator:Alive() then
		if activator:GetSyncVar(SYNC_ARRESTED, false) then 
			return activator:Notify("You cannot access your storage when detained.") 
		end

		if self.Bench.Illegal and activator:IsCP() then
			return activator:Notify("You cannot access your storage as this team.")
		end

		activator.currentBench = self
	end
end

