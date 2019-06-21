plogs.Register('Connections', true, Color(0,255,0))

plogs.AddHook('PlayerInitialSpawn', function(pl)
	plogs.PlayerLog(pl, 'Connections', pl:NameID() .. ' has connected', {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})

	if plogs.cfg.EnableMySQL then
		plogs.sql.LogIP(pl:SteamID64(), pl:IPAddress())
	end
end)

plogs.AddHook('PlayerDisconnected', function(pl)
	plogs.PlayerLog(pl, 'Connections', pl:NameID() .. ' has disconnected', {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)