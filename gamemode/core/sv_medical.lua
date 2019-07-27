function meta:BreakLegs()
	self:SetSyncVar(SYNC_BROKENLEGS, true, true)
	self.BrokenLegs = true
end

function meta:HasBrokenLegs()
	return self:GetSyncVar(SYNC_BROKENLEGS, false)
end

function meta:FixLegs()
	self:SetSyncVar(SYNC_BROKENLEGS, false, true)
	self.BrokenLegs = false
end

function meta:StartBleeding()
	self:SetSyncVar(SYNC_BLEEDING, true, true)
	self.BleedStage = 1
end

function meta:StopBleeding()
	self:SetSyncVar(SYNC_BLEEDING, false, true)
	self.BleedStage = nil
end