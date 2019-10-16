-- This file contains private info, do NOT publicise.

function opsDiscordLog(message)
--[[ 	return -- discord FUCKED IT UP
	
	local post = {
		content = message,
		username = "impulse (ops)"
	}

	local struct = {
		failed = function(error) MsgC(Color(255,0,0), "Impulse discord log error: "..error) end,
		method = "post",
		url = impulse.Config.DiscordProxyURL.."***REMOVED***",
		parameters = post,
		type = "application/json; charset=utf-8"
	}

	HTTP(struct)--]] 
end