plogs.Register('Props', true, Color(50,175,255))

plogs.AddHook('PlayerSpawnProp', function(pl, mdl)
	plogs.PlayerLog(pl, 'Props', pl:NameID() .. ' spawned ' .. mdl, {
		['Name'] 	= pl:Name(),
		['SteamID']	= pl:SteamID()
	})
end)