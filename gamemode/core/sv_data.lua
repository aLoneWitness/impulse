function meta:GetData()
	return self.impulseData or {}
end

function meta:SaveData()	
	local query = mysql:Update("impulse_players")
	query:Update("data", util.TableToJSON(self.impulseData))
	query:Where("steamid", self:SteamID())
	query:Execute(true) -- queued query
end