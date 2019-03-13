ENT.Type = "anim"
ENT.PhysgunDisable = true
ENT.PhysgunDisabled = true

function ENT:SetAnimation()
	for v,k in ipairs(self:GetSequenceList()) do
		if (k:lower():find("idle") and v != "idlenoise") then
			return self:ResetSequence(v)
		end
	end

	self:ResetSequence(4)
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "npcid")
end