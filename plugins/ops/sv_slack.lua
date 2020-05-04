-- This file contains private info, do NOT publicise.

function opsSlackLog(message)
	local isPreview = GetConVar("impulse_ispreview"):GetBool()

	if isPreview then
		return	
	end

	local post = {
		text = message
	}

	local struct = {
		failed = function(error) MsgC(Color(255,0,0), "Impulse Slack log error: "..error) end,
		method = "post",
		url = "***REMOVED***",
		body = util.TableToJSON(post),
		type = "application/json"
	}

	HTTP(struct)
end