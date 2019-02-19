local allowed = {
	["STEAM_0:1:95921723"] = true,
	["STEAM_0:1:52175298"] = true,
	["STEAM_0:0:147881902"] = true,
	["STEAM_0:1:83204982"] = true,
	["STEAM_0:0:77822354"] = true,
	["STEAM_0:1:177753756"] = true,
	["STEAM_0:0:3514307"] = true,
	["STEAM_0:1:175014750"] = true,
	["STEAM_0:0:98663097"] = true,
	["STEAM_0:1:199354868"] = true,
	["STEAM_0:0:24607430"] = true,
	["STEAM_0:1:102639297"] = true,
	["STEAM_0:0:73272856"] = true,
	["STEAM_0:0:-2121362474"] = true,
	["STEAM_0:0:26121174"] = true,
	["STEAM_0:0:45444861"] = true,
	["STEAM_0:1:46764713"] = true
}

hook.Add("CheckPassword", "access_whitelist", function( steamID64 )
	if not allowed[util.SteamIDFrom64(steamID64)] then
		return false, "impulse is currently in closed testing. Contact vin for more info."
	end
end)