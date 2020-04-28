--- Allows the creation, updating and reading of persistent settings
-- @module Setting

impulse.Settings = impulse.Settings or {}

--- A collection of data that defines how a setting will behave
-- @realm client
-- @string name The pretty name for the setting (we'll see this in the settings menu)
-- @string category The category the setting will belong to
-- @string type tickbox, dropdown, slider, plainint
-- @param default The default value of the setting
-- @int[opt] minValue Minimum value (slider only)
-- @int[opt] maxValue Maximum value (slider only)
-- @param options A table of string options (dropdown only)
-- @func[opt] onChanged Called when setting is changed
-- @table SettingData

--- Defines a new setting for use
-- @realm client
-- @string name Setting class name
-- @param settingData A table containg setting data (see below)
-- @see SettingData
function impulse.DefineSetting(name, settingdata)
	impulse.Settings[name] = settingdata
	impulse.LoadSettings()
end

--- Gets the value of a setting
-- @realm client
-- @string name Setting class name
-- @return Setting value
function impulse.GetSetting(name)
	local settingData = impulse.Settings[name]

	if settingData.type == "tickbox" then
		return tobool(settingData.value)
	end
	return settingData.value or settingData.default
end

--- Loads the settings from the clientside database
-- @realm client
-- @internal
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

		if k.onChanged then
			k.onChanged(k.value)
		end
	end
end

--- Sets a setting to a specified value
-- @realm client
-- @string name Setting class name
-- @param value New value
function impulse.SetSetting(name, newValue)
	local settingData = impulse.Settings[name]
	if settingData then
		if type(newValue) == "boolean" then -- convert them boolz to intz. it's basically a gang war
			newValue = newValue and 1 or 0
		end

		cookie.Set("impulse-setting-"..name, newValue)
		settingData.value = newValue

		if settingData.onChanged then
			settingData.onChanged(newValue)
		end

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