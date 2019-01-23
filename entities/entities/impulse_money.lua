AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Category = "impulse"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "MoneyVal")
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props/cs_assault/money.mdl")
    	self:PhysicsInit(SOLID_VPHYSICS)
    	self:SetMoveType(MOVETYPE_VPHYSICS)
    	self:SetSolid(SOLID_VPHYSICS)
    	self:SetUseType(SIMPLE_USE)
    	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    	local physObj = self:GetPhysicsObject()
    	self.nodupe = true

		physObj:Wake()
	end

	function ENT:SetMoney(amount)
		self:SetMoneyVal(amount)
		self.money = amount
	end

	function ENT:Use(activator)
		if activator:IsPlayer() then
			self:GiveMoney(self.money)
			self:Notify("You have picked up $"..self.money)
		end
	end
else
	local valueCol = Color(20, 20, 20, 180)

	function ENT:Draw()
		self:DrawModel()

		local pos = self:GetPos()
		local ang = self:GetAngles()

		surface.SetFont("Impulse-Elements18-Shadow")
		local value = "$"..self:GetMoneyVal() or "$0"
		local wide = surface.GetTextSize(value)

		cam.Start3D2D(pos + ang:Up() * 0.82, ang, 0.1)
			draw.WordBox(4, -wide * 0.5, -10, value, "Impulse-Elements18-Shadow", valueCol, color_white)
		cam.End3D2D()

		ang:RotateAroundAxis(ang:Right(), 180)

		cam.Start3D2D(pos, ang, 0.1)
			draw.WordBox(4, -wide * 0.5, -10, value, "Impulse-Elements18-Shadow", valueCol, color_white)
		cam.End3D2D()
	end

end

	