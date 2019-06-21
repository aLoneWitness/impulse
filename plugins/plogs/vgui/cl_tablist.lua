local PANEL = {}

function PANEL:Init()
	self.num = 0
	self:SetSkin('impulse')
	self.tablist = vgui.Create('DScrollPanel', self)
end

function PANEL:AddTab(title, tab, active)
	if active then 
		self.CurrentTab = tab 
	else
		tab:SetVisible(false)
	end

	if (tab:GetParent() ~= self) then
		tab:SetParent(self)
		tab:SetSkin(self:GetSkin())
	end

	tab:SetPos(149, 0)
	tab:SetSize(self:GetWide() - 149, self:GetTall())

	local button = vgui.Create('DButton')
	button:SetSize(150, 30)
	button:SetPos(0, 29 * self.num)
	button:SetText(title)
	button:SetSkin('impulse')
	button:SetFont('Impulse-Elements18')
	button.DoClick = function()
		self.CurrentButton.Active = false
		self.CurrentTab:SetVisible(false)
		tab:SetVisible(true)

		self.CurrentTab = tab
		self.CurrentButton = button
		button.Active = true
	end

	if active then
		self.CurrentButton = button
		button.Active = true
		self.CurrentTab = tab
	end

	local oldPaint = button.Paint
	button.Paint = function(button, w, h)
		oldPaint(button)

		if self.CurrentButton and self.CurrentButton == button then
			surface.SetDrawColor(impulse.Config.MainColour)
			surface.DrawRect(0, 0, 5, h)
		end
	end

	self.tablist:AddItem(button)

	self.num = self.num + 1
end

function PANEL:AddButton(title, func)
	local button = vgui.Create('DButton')
	button:SetSize(150, 30)
	button:SetPos(0, 29 * self.num)
	button:SetText(title)
	button:SetSkin('impulse')
	button:SetFont('Impulse-Elements18')
	button.DoClick = function(self)
		func(self)
	end

	button.Paint = function(button, w, h)
		print(button:IsDown())

		if button:IsDown() then
			surface.SetDrawColor(color_white)
			surface.DrawRect(0, 0, w, h)
		end

		derma.SkinHook('Paint', 'TabListButton', button, w, h)
	end


	self.tablist:AddItem(button)

	self.num = self.num + 1
end

function PANEL:PerformLayout()
	self.tablist:SetSize(150, self:GetTall())
	self.tablist:SetPos(0, 0)
end

vgui.Register('plogs_tablist', PANEL, 'Panel')