if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = ""
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.HoldType = "passive"
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "passive"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize() 
	self:SetHoldType("passive") 
end

function SWEP:CanPrimaryAttack() 
	return false
end

function SWEP:SecondaryAttack() 
	return false
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:DrawWorldModel()
end