impulse.Settings = impulse.Settings or {}

function impulse.DefineSetting(name, settingdata)
	impulse.Settings[name] = settingdata
end

function impulse.GetSetting(name)
	local settingData = impulse.Settings[name]

	if settingData.type == "tickbox" then
		return tobool(setting.value) or settingData.default
	end
	return settingData.value or settingData.default
end

function impulse.LoadSettings()
	for v,k in pairs(impulse.Settings) do
		if k.type == "tickbox" or k.type == "slider" or k.type == "plainint" then
			k.value = cookie.GetNumber("impulse-setting-"..v, k.default) -- Cache the data into a variable instead of sql so its fast
		elseif k.type == "dropdown" or k.type == "textbox" then
			k.value = cookie.GetString("impulse-setting-"..v, k.default)
		end
	end
end

function impulse.SetSetting(name, newValue)
	local settingData = impulse.Settings[name]
	if settingData then
		if type(newValue) == "boolean" then newValue = tonumber(newValue) end -- convert them boolz to intz. it's basically a gang war
		cookie.Set("impulse-setting-"..name, newValue)
		settingData.value = newValue
		return
	end
	return print("[impulse] Error, could not SetSetting. You've probably got the name wrong! Attempted name: "..name)
end

timer.Simple(1, function()
	impulse.LoadSettings()
end)

concommand.Add("impulse_resetsettings", function()
	for v,k in pairs(impulse.Settings) do
		impulse.SetSetting(v, k.default)
	end
	print("[impulse] Settings reset!")
end)
