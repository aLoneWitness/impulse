AddCSLuaFile()


if CLIENT then
	SWEP.PrintName = "Hands"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Author = "vin"

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 0
SWEP.ViewModelFlip = false
SWEP.HoldType = "normal"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.IsAlwaysRaised = true

SWEP.UseHands = false

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:Precache()
	util.PrecacheSound("npc/vort/claw_swing1.wav")
	util.PrecacheSound("npc/vort/claw_swing2.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(false)
	end
end

function SWEP:Holster()
    return true
end

function SWEP:CanCarry(ent)
	local phys = ent:GetPhysicsObject()

	if not IsValid(phys) then
		return false
	end

	if phys:GetMass() > 100 or not phys:IsMoveable() then
		return false
	end

	if IsValid(ent.carrier) or IsValid(self.heldEntity) then
		return false
	end

	return true
end

function SWEP:Pickup(ent)
	self.heldEntity = ent
	self.Owner.heldEntity = ent

	timer.Simple(0.1, function()
		if not IsValid(ent) or ent:IsPlayerHolding() or self.heldEntity != ent then
			self.heldEntity = nil

			return
		end

		self.Owner:PickupObject(ent)
		self.Owner:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 3)..".wav", 75)
	end)
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	local ply = self.Owner

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = {ply, self}

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) then
		if traceEnt:IsDoor() then
			local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

			if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
				traceEnt:DoorLock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			else
				ply:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(90, 110))
			end
		end
	end

	self:SetNextPrimaryFire(CurTime() + 0.75)
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local ply = self.Owner

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) then
		if traceEnt:IsDoor() then
			local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

			if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
				traceEnt:DoorUnlock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			else
				ply:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(90, 110))
			end

			self:SetNextSecondaryFire(CurTime() + 0.5)
			return
		elseif not traceEnt:IsPlayer() and not traceEnt:IsNPC() and self:CanCarry(traceEnt) then
			local phys = traceEnt:GetPhysicsObject()
			phys:Wake()

			self:Pickup(traceEnt)
			self:SetNextSecondaryFire(CurTime() + 0.5)
			return
		elseif IsValid(self.heldEntity) and not self.heldEntity:IsPlayerHolding() then
			self.heldEntity = nil
			ply.heldEntity = nil
			return
		end
	end

	self:SetNextSecondaryFire(CurTime() + 0.75)
end

