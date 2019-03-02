if SERVER then
	function meta:SetHunger(amount)
		self:SetLocalSyncVar(SYNC_HUNGER, math.Clamp(amount, 0, 100))
	end

	function meta:FeedHunger(amount)
		self:SetHunger(amount + self:GetSyncVar(SYNC_HUNGER, 100))
	end
end