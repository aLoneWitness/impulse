function opsDiscordLog(message)
	local post = {
		content = message,
		username = "ops (open permission system)"
	}

	local struct = {
		failed = function(error) MsgC(Color(255,0,0), "Impulse discord log error: "..error) end,
		method = "post",
		url = "https://discordapp.com***REMOVED***",
		parameters = post,
		type = "application/json; charset=utf-8"
	}

	HTTP(struct)
end