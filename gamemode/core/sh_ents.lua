local entityMeta = FindMetaTable("Entity")

function entityMeta:IsDoor()
	return self:GetClass():find("door")
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