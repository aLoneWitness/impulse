local PANEL = {}

function PANEL:Init()
	local addedCategories = {}
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("Settings")
	self:MakePopup()

	local settingsPages = vgui.Create("DPropertySheet", self)
	settingsPages:Dock(FILL)
	--settingsPages:InvalidateParent(true) -- this is called to sync the new positions and sizes with the dock

	for v,k in pairs(impulse.Settings) do
		if not addedCategories[k.category] then -- If category does not exist, create it
			local settingSheetScroll = vgui.Create("DScrollPanel", settingsPages)
			settingsPages:AddSheet(k.category, settingSheetScroll)
			addedCategories[k.category] = settingSheetScroll
		end

		local settingBase = addedCategories[k.category]:Add("DPanel")
		settingBase:Dock(TOP)
		settingBase:DockMargin(0,0,0,5)
		--settingBase:InvalidateParent(true) -- this is called to sync the new positions and sizes with the dock
		function settingBase:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color( 80, 80, 80, 100 ))
		end

		local settingLabel = vgui.Create("DLabel", settingBase)
		settingLabel:SetText(k.name)
		settingLabel:SetFont("Impulse-Elements18")
		settingLabel:SizeToContents()
		settingLabel:CenterVertical()
		settingLabel:SetPos(5, settingLabel.y)

		local settingType = k.type
		if settingType == "tickbox" then
			local tickbox = vgui.Create("DCheckBox", settingBase)
			tickbox:CenterVertical()
			tickbox:SetPos(590, tickbox.y)
			tickbox:SetValue(k.value)

			function tickbox:OnChange(value)
				impulse.SetSetting(v, value)
			end
		elseif settingType == "plainint" then
			local numberEntry = vgui.Create("DNumberWang", settingBase)
			numberEntry:CenterVertical()
			numberEntry:SetPos(580, numberEntry.y)
			numberEntry:SetSize(30,20)
			numberEntry:SetValue(k.value)
			numberEntry:SetNumeric(true)

			function numberEntry:OnValueChanged(value)
				impulse.SetSetting(v, value)
			end
		elseif settingType == "slider" then
			local numSlider = vgui.Create("DNumSlider", settingBase)
			numSlider:CenterVertical()
			numSlider:SetMin(k.minValue or 0)
			numSlider:SetMax(k.maxValue or 100)
			numSlider:SetDecimals(0)
			numSlider:SetValue(k.value)
			numSlider:SetSize(320,30)
			numSlider:SetPos(310, numSlider.y)

			function numSlider:OnValueChanged(value)
				impulse.SetSetting(v, value)
			end
		elseif settingType == "dropdown" then
			local dropdown = vgui.Create("DComboBox", settingBase)
			dropdown:SetSize(150, 20)
			dropdown:CenterVertical()
			dropdown:SetPos(460, dropdown.y)
			dropdown:SetValue(k.value)
			dropdown:SetSortItems(false)
			for _, option in pairs(k.options) do
				dropdown:AddChoice(option)
			end

			function dropdown:OnSelect(index, value)
				impulse.SetSetting(v, value)
			end
		end
	end
end


vgui.Register("impulseSettings", PANEL, "DFrame")