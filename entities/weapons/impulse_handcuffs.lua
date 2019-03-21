AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Handcuffs"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
end

SWEP.Author = "vin"

SWEP.ViewModel = "models/katharsmodels/handcuffs/handcuffs-2.mdl"
SWEP.WorldModel = "models/katharsmodels/handcuffs/handcuffs-1.mdl"

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.HoldType = "grenade"

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

function SWEP:Initialize()
	self:SetWeaponHoldType("grenade")
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	self.Weapon:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)

	if CLIENT then return end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = {ply, self}

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsPlayer() and ply:CanArrest(traceEnt) then
		if traceEnt:GetSyncVar(SYNC_ARRESTED, false) then
			traceEnt:UnArrest()

			ply:Notify("You have released "..traceEnt:Name()..".")
			traceEnt:Notify("You have been released by"..ply:Name()..".")
		else
			timer.Simple(0.5, function()
				if IsValid(self) and IsValid(self.Weapon) and IsValid(ply) and IsValid(traceEnt) and ply:CanArrest(traceEnt) then
					traceEnt:Arrest()
					
					ply:Notify("You have detained "..traceEnt:Name()..".")
					traceEnt:Notify("You have been detained by "..ply:Name()..".")
				end
			end)
		end
	end
end

if CLIENT then
	function SWEP:GetViewModelPosition(pos, ang)
		ang:RotateAroundAxis(ang:Forward(), 0)
		ang:RotateAroundAxis(ang:Up(), 180)
		ang:RotateAroundAxis(ang:Right(), 0)
		pos = pos + ang:Forward() * -20
		pos = pos + ang:Right() * -10
		pos = pos + ang:Up() * -8
		
		return pos, ang
	end 
	
	function SWEP:DrawWorldModel()
		if not IsValid(self.Owner) then
			return
		end

		local boneindex = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if boneindex then
			local HPos, HAng = self.Owner:GetBonePosition(boneindex)

			local offset = HAng:Right() * 1.5 + HAng:Forward() * 4 + HAng:Up() * -1

			HAng:RotateAroundAxis(HAng:Right(), 0)
			HAng:RotateAroundAxis(HAng:Forward(),  0)
			HAng:RotateAroundAxis(HAng:Up(), 90)
			
			self:SetRenderOrigin(HPos + offset)
			self:SetRenderAngles(HAng)

			self:DrawModel()
		end
	end
end