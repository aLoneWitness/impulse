impulse.Settings = impulse.Settings or {}

function impulse.DefineSetting(name, settingdata)
	impulse.Settings[name] = settingdata
	impulse.LoadSettings()
end

function impulse.GetSetting(name)
	local settingData = impulse.Settings[name]

	if settingData.type == "tickbox" then
		return tobool(settingData.value) or settingData.default
	end
	return settingData.value or settingData.default
end

function impulse.LoadSettings()
	for v,k in pairs(impulse.Settings) do
		if k.type == "tickbox" or k.type == "slider" or k.type == "plainint" then
			local def = k.default
			if k.type == "tickbox" then 
				def = tonumber(k.default) 
			end

			k.value = cookie.GetNumber("impulse-setting-"..v, def) -- Cache the data into a variable instead of sql so its fast
		elseif k.type == "dropdown" or k.type == "textbox" then
			k.value = cookie.GetString("impulse-setting-"..v, k.default)
		end
	end
end

function impulse.SetSetting(name, newValue)
	local settingData = impulse.Settings[name]
	if settingData then
		if type(newValue) == "boolean" then -- convert them boolz to intz. it's basically a gang war
			newValue = newValue and 1 or 0
		end

		cookie.Set("impulse-setting-"..name, newValue)
		settingData.value = newValue
		return
	end
	return print("[impulse] Error, could not SetSetting. You've probably got the name wrong! Attempted name: "..name)
end

concommand.Add("impulse_resetsettings", function()
	for v,k in pairs(impulse.Settings) do
		impulse.SetSetting(v, k.default)
	end
	print("[impulse] Settings reset!")
end)

hook.Run("DefineSettings")