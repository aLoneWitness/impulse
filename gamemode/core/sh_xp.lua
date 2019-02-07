function meta:GetXP()
	return self:GetSyncVar(SYNC_XP, 0)
end


if SERVER then
	function meta:SetXP(amount)
		if not self.beenSetup or self.beenSetup == false then return end
		if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end

		local query = mysql:Update("impulse_players")
		query:Update("xp", amount)
		query:Where("steamid", self:SteamID())
		query:Execute()

		return self:SetLocalSyncVar(SYNC_XP, amount)
	end

	function meta:AddXP(amount)
		local setAmount = self:GetXP() + amount

		self:SetXP(setAmount)
	end

	function meta:GiveTimedXP()
		if ply:IsVIP() then
			ply:AddXP(impulse.Config.XPGetVIP)
			ply:Notify("For playing the server for 10 minutes you have recieved 10 XP.")
		else
			ply:AddXP(impulse.Config.XPGet)
			ply:Notify("For playing the server for 10 minutes you have recieved 5 XP.")
		end
	end
end