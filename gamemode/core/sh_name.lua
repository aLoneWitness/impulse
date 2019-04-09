if SERVER then
	function meta:SetRPName(name, save)
		if save then
			local query = mysql:Update("impulse_players")
			query:Update("rpname", name)
			query:Where("steamid", self:SteamID())
			query:Execute(true)

			self.SavedRPName = name
		end

		hook.Run("PlayerRPNameChanged", self, self:Name(), name)

		self:SetSyncVar(SYNC_RPNAME, name, true)
	end

	function meta:GetSavedRPName()
		return self.defaultRPName
	end
end

function impulse.CanUseName(name)
	if name:len() >= 24 then
		return false, "Name too long. (max. 24)" 
	end

	name = name:Trim()
	name = impulse.SafeString(name)

	if name:len() <= 6 then
		return false, "Name too short. (min. 6)"
	end

	if name == "" then
		return false, "No name was provided."
	end


	local numFound = string.match(name, "%d") -- no numerics

	if numFound then
		return false, "Name contains numbers."
	end

	return true, name
end