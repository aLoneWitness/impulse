local entityMeta = FindMetaTable("Entity")


local propDoors = {
	["models/props_doors/doorklab01.mdl"] = true,
	["models/props_lab/elevatordoor.mdl"] = true,
	["models/props_combine/combine_door01.mdl"] = true,
	["models/combine_gate_vehicle.mdl"] = true,
	["models/combine_gate_citizen.mdl"] = true
}

function entityMeta:IsDoor()
	return self:GetClass():find("door")
end

function entityMeta:IsPropDoor()
	if not IsValid(self) then
		return
	end
	
	if not self.GetModel or not propDoors[self:GetModel()] then
		return false
	end

	if (self:CPPIGetOwner() and IsValid(self:CPPIGetOwner())) and self:CPPIGetOwner():IsPlayer() then
		return true
	end

	if (self:CPPIGetOwner() and IsValid(self:CPPIGetOwner())) and self:CPPIGetOwner() == Entity(0) then
		if SERVER then
			if self:MapCreationID() == -1 then
				return true
			else
				return false
			end
		end

		return true
	end

	return false
end

function entityMeta:IsButton()
	return (self:GetClass():find("button") or self:GetClass() == ("class C_BaseEntity"))
end

function entityMeta:IsDoorLocked()
	return self:GetSaveTable().m_bLocked
end

local chairs = {}

for k, v in pairs(list.Get("Vehicles")) do
	if v.Category == "Chairs" then
		chairs[v.Model] = true
	end
end

function entityMeta:IsChair()
	return chairs[self.GetModel(self)]
end

function entityMeta:CanBeCarried()
	local phys = self:GetPhysicsObject()

	if not IsValid(phys) then
		return false
	end

	if phys:GetMass() > 100 or not phys:IsMoveable() then
		return false
	end

	return true
end

local ADJUST_SOUND = SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or ""

function entityMeta:EmitQueuedSounds(sounds, delay, spacing, volume, pitch)
	delay = delay or 0
	spacing = spacing or 0.1

	for k, v in ipairs(sounds) do
		local postSet, preSet = 0, 0

		if (type(v) == "table") then
			postSet, preSet = v[2] or 0, v[3] or 0
			v = v[1]
		end

		local length = SoundDuration(ADJUST_SOUND..v)
		delay = delay + preSet

		timer.Simple(delay, function()
			if (IsValid(self)) then
				self:EmitSound(v, volume, pitch)
			end
		end)

		delay = delay + length + postSet + spacing
	end

	return delay
end

if SERVER then
	util.AddNetworkString("impulseBudgetSound")
	util.AddNetworkString("impulseBudgetSoundExtra")
	function entityMeta:EmitBudgetSound(sound, range, level, pitch)
		local range = range or 600
		local pos = self:GetPos()
		local entIndex = self:EntIndex()
		local range = range ^ 2

		local recipFilter = RecipientFilter()

		for v,k in pairs(player.GetAll()) do
			if k:GetPos():DistToSqr(pos) < range then
				recipFilter:AddPlayer(k)
			end
		end

		if level or pitch then
			net.Start("impulseBudgetSoundExtra")
			net.WriteUInt(entIndex, 16)
			net.WriteString(sound)
			net.WriteUInt(level or 0, 8)
			net.WriteUInt(pitch or 0, 8)
		else
			net.Start("impulseBudgetSound")
			net.WriteUInt(entIndex, 16)
			net.WriteString(sound)
		end

		net.Send(recipFilter)
	end
end