function meta:SetRPName(name, save)
	if save then
		local query = mysql:Update("impulse_players")
		query:Update("rpname", name)
		query:Where("steamid", self:SteamID())
		query:Execute(true)
	end

	hook.Run("PlayerRPNameChanged", self, self:Name(), name)

	self:SetSyncVar(SYNC_RPNAME, name, true)
end