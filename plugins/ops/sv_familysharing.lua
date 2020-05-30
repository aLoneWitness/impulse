local APIKey = "***REMOVED***" -- this key is private do not share it

local function CheckFamilySharing(ply, sid)
	local s64id = util.SteamIDTo64(sid)
	
	http.Fetch(
	string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
		APIKey,
		s64id
	),

	function(body)
		local body = util.JSONToTable(body)

		if not body or not body.response or not body.response.lender_steamid then
			error(string.format("ops FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
		end

		local lender = body.response.lender_steamid
		if lender != "0" then -- if does not own gmod
			ply:Kick("Sorry, we do not allow Steam accounts that don't own the game fully. For more information goto support.impulse-community.com")
		end
	end,

	function(code)
		error(string.format("ops FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
	end
	)
end
hook.Add("PlayerAuthed", "opsFamilyBlock", CheckFamilySharing)
