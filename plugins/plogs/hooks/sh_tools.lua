plogs.Register('Tools', false)

plogs.AddHook('CanTool', function(pl, trace, tool) -- Shame there isn't a better hook
	if (not plogs.cfg.ToolBlacklist[tool]) then
		plogs.PlayerLog(pl, 'Tools', pl:NameID() .. ' attempted to use tool ' .. tool, {
			['Name'] 	= pl:Name(),
			['SteamID']	= pl:SteamID()
		})
	end
end)