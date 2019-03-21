AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	phys:Wake()
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end


function ENT:Use(activator)
	activator:Give(self.class)
	local weapon = activator:GetWeapon(self.class)

	if self.clip1 then
		weapon:SetClip1(self.clip1)
		weapon:SetClip2(self.clip2 or 0)
	end

	if self.ammo then
		activator:SetAmmo(self.ammo, weapon:GetPrimaryAmmoType())
	end

	self:Remove()
end
