AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    if self.impulseSaveKeyValue then
        local vendorID = self.impulseSaveKeyValue["vendor"]

        if vendorID and impulse.Vendor.Data[vendorID] then
            self.Vendor = impulse.Vendor.Data[vendorID]
        end
    end

    if self.Vendor then
        self:SetModel(self.Vendor.Model)
    else
        self:SetModel("models/Humans/Group01/male_02.mdl")
    end

    self:SetUseType(SIMPLE_USE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:PhysicsInit(SOLID_BBOX)
    self:DrawShadow(false)
    local physObj = self:GetPhysicsObject()

    if (IsValid(physObj)) then
        physObj:EnableMotion(false)
        physObj:Sleep()
    end

    timer.Simple(1, function()
        if IsValid(self) then
            self:DoAnimation()
        end
    end)

    if self.Vendor then
        self:SetVendor(self.Vendor.UniqueID)
    end
end

function ENT:SpawnFunction(ply, trace, class)
    local angles = (trace.HitPos - ply:GetPos()):Angle()
    angles.r = 0
    angles.p = 0
    angles.y = angles.y + 180

    local entity = ents.Create(class)
    entity:SetPos(trace.HitPos)
    entity:SetAngles(angles)
    entity:Spawn()

    return entity
end

function ENT:Use(activator, caller)
    net.Start("impulseVendorUse")
    net.Send(activator)
end

function ENT:Think()
    if self.Vendor and self.Vendor.Think then
        return self.Vendor.Think(self)
    end
end