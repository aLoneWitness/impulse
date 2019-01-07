impulse.Settings = impulse.Settings or {}

function impulse.DefineSetting(settingdata)
	table.insert(impulse.Settings,settingdata)
end

function impulse.GetSetting(name)
	for v,k in pairs(impulse.Settings) do
		if k.name == name then
			return (k.value or k.default)
		end
	end
end

function impulse.LoadSettings()
	for v,k in pairs(impulse.Settings) do
		if k.type == "tickbox" or k.type == "slider" or k.type == "plainint" then
			k.value = cookie.GetNumber("impulse-setting-"..k.name, k.default) -- Cache the data into a variable instead of sql so its fast
		elseif k.type == "dropdown" or k.type == "textbox" then
			k.value = cookie.GetString("impulse-setting-"..k.name, k.default)
		end
	end
end


function impulse.SetSetting(name, value)
	for v,k in pairs(impulse.Settings) do
		if k.name == name then
			return cookie.Set("impulse-setting-"..k.name, value)
		end
	end
	return print("[impulse] Error, could not SetSetting. You've probably got the name wrong!")
end

timer.Simple(1, function()
	impulse.LoadSettings()
end)


concommand.Add("impulse_resetsettings", function()
	for v,k in pairs(impulse.Settings) do
		impulse.SetSetting(k.name, k.default)
	end
	print("[impulse] Settings reset!")
end)
