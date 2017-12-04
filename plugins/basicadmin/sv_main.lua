/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.ops = {} -- Define a table for basic admin
if GExtention th

function impulse.ba.Ban(steamid, reason, time, isGlobal)
    local player = util.playerGetBySteamID(steamid)
    
    if GExtention then
        GExtention.Ban(steamid, reason, time)
    elseif player then
        player:Ban(time, false)
        player:Kick(reason)
    end
end

local APIKey = "***REMOVED***"


--Function to handle those who connect via family shared steam accounts.
local function HandleSharedPlayer(ply, lenderSteamID)
	ply:Kick("Your Steam account does not fully own Garry's Mod. Please buy the game on this account.")
end



local function CheckFamilySharing(ply)
	http.Fetch(
	string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
		APIKey,
		ply:SteamID64()
	),

	function(body)
		--Put the http response into a table.
		local body = util.JSONToTable(body)

		--If the response does not contain the following table items.
		if not body or not body.response or not body.response.lender_steamid then
			error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
		end

		--Set the lender to be the lender in our body response table.
		local lender = body.response.lender_steamid
		--If the lender is not 0 (Would contain SteamID64). Lender will only ever == 0 if the account owns the game.
		if lender ~= "0" then
			--Handle the player that is on a family shared account to decide their fate.
			HandleSharedPlayer(ply, util.SteamIDFrom64(lender))
		end
	end,

	function(code)
		error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
	end
	)
end
hook.Add("PlayerAuthed", "ops-FamilyShare", CheckFamilySharing)
