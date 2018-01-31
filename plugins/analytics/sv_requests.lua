-- Get these from Google APIs https://console.developers.google.com

local API_KEY = "AIzaSyAAJaXBlL7-zD4uoHI_NpAAdPfhkUCExUk" -- Keep this secret.
local SHEET_ID = "19K3YK0FmJipMjBD2VRfIr1CjHUTqhtJYTRGhtEmpCw4"
local REQUESTSTRING = "https://sheets.googleapis.com/v4/spreadsheets/"..SHEET_ID"/values/key="..API_KEY.."&Master!{A5:B5:C5:D5:E5:G5}:append?valueInputOption=USER_ENTERED"

local function SendToSheet(sender, playercount,entcount,location,fps,map)

	http.Post(REQUESTSTRING.."A5:append", {
		"range":"Master!A5:B5:C5:D5:E5:G5",
		"majorDimension": "ROWS",
		"values" = {sender:SteamID(), playercount, entcount, location, fps, map}
		]
	})


end

