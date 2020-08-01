-- This file contains private info, do NOT publicise.

function opsSlackLog(message)
	if not impulse.YML.apis.slack_webhook then
		return
	end
	
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
		url = impulse.YML.apis.slack_webhook,
		body = util.TableToJSON(post),
		type = "application/json"
	}

	HTTP(struct)
end