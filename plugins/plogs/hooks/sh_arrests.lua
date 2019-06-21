plogs.Register('Arrests', false)

plogs.AddHook("PlayerArrested", function(ply, detainer)
	plogs.PlayerLog(ply, 'Arrests', ply:NameID().." was detained by "..detainer:NameID(), {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID(),
		["Detainer Name"] = detainer:Name(),
		["Detainer SteamID"] = detainer:SteamID()
	})
end)

plogs.AddHook("PlayerUnArrested", function(ply, detainer)
	plogs.PlayerLog(ply, 'Arrests', ply:NameID().." was un-detained by "..detainer:NameID(), {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID(),
		["Detainer Name"] = detainer:Name(),
		["Detainer SteamID"] = detainer:SteamID()
	})
end)

plogs.AddHook("PlayerJailed", function(ply, detainer, time, charges)
	local charges = table.ToString(charges)
	plogs.PlayerLog(ply, 'Arrests', ply:NameID().." was jailed by "..detainer:NameID().." for "..time.." seconds. Charges: "..charges, {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID(),
		["Detainer Name"] = detainer:Name(),
		["Detainer SteamID"] = detainer:SteamID(),
		["Charges"] = charges
	})
end)

plogs.AddHook("PlayerUnJailed", function(ply)
	local charges = table.ToString(charges)
	plogs.PlayerLog(ply, 'Arrests', ply:NameID().." was unjailed."..charges, {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID()
	})
end)