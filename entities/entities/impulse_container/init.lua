AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl") -- rmv me
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()

		if self.NoMove then
			phys:EnableMotion(false)
		else
			phys:EnableMotion(true)
		end
	end

	self.Users = {}
	self.Authorised = {}
	self.Inventory = {
		["testitem"] = 3,
		["cos_facewrap"] = 1
	}
	self.Weight = {}
	self.Max = 32

	self.Code = 44546 -- rmv me

	self:SetCapacity(4) -- rmv me
	self:SetLoot(true)
end

function ENT:OnTakeDamage(dmg) 
	return false
end

function ENT:SetCode(code)
	self.Authorised = {}
	self.Code = code
end

function ENT:AddItem(itemclass, amount, noUpdate)
	local count = 0

	if self.Inventory[itemclass] then
		count = self.Inventory[itemclass]
	end

	self.Inventory[itemclass] = count + (amount or 1)

	if not noUpdate then
		self:UpdateUsers()
	end
end

function ENT:TakeItem(itemclass, amount, noUpdate)
	local itemCount = self.Inventory[itemclass]
	if itemCount then
		local newCount = itemCount - (amount or 1)

		if newCount < 1 then
			self.Inventory[itemclass] = nil
		else
			self.Inventory[itemclass] = newCount
		end
	end

	if not noUpdate then
		self:UpdateUsers()
	end
end

function ENT:AddAuthorised(ply)
	self.Authorised[ply] = true
end

function ENT:AddUser(ply)
	self.Users[ply] = true

	net.Start("impulseInvContainerOpen")
	net.WriteUInt(table.Count(self.Inventory), 8)

	for v,k in pairs(self.Inventory) do
		local netid = impulse.Inventory.ClassToNetID(v)
		local amount = k

		net.WriteUInt(netid, 10)
		net.WriteUInt(amount, 8)
	end

	net.Send(ply)

	ply.currentContainer = self
end

function ENT:RemoveUser(ply)
	self.Users[ply] = nil
	ply.currentContainer = nil
end

function ENT:UpdateUsers()
	local pos = self:GetPos()

	for v,k in pairs(self.Users) do
		if IsValid(v) and pos:DistToSqr(v:GetPos()) < (230 ^ 2) then
			net.Start("impulseInvContainerUpdate")
			net.WriteUInt(table.Count(self.Inventory), 8)

			for v,k in pairs(self.Inventory) do
				local netid = impulse.Inventory.ClassToNetID(v)
				local amount = k

				net.WriteUInt(netid, 10)
				net.WriteUInt(amount, 8)
			end
			net.Send(v)
		else
			self.Users[v] = nil
		end
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() and activator:Alive() then
		if activator:GetSyncVar(SYNC_ARRESTED, false) then 
			return activator:Notify("You cannot access a container when detained.") 
		end

		if activator:IsCP() and self:GetLoot() then
			return activator:Notify("You cannot access this container as this team.")
		end

		if not self:GetLoot() and self.Code and not self.Authorised[activator] then
			net.Start("impulseInvContainerCodeTry")
			net.Send(activator)

			activator.currentContainerPass = self
			return
		end

		self:AddUser(activator)
	end
end

