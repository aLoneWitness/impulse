local PANEL = {}

function PANEL:Init()
	self:SetSize(770, 580)
	self:Center()
	self:SetTitle("Player menu")
	self:MakePopup()

	local darkOverlay = Color(40, 40, 40, 160)

	self.tabSheet = vgui.Create("DColumnSheet", self)
	self.tabSheet:Dock(FILL)
	self.tabSheet.Navigation:SetWidth(100)

	self.quickActions = vgui.Create("DPanel", self.tabSheet)
	self.quickActions:Dock(FILL)

	function self.quickActions:Paint(w, h)
		surface.SetDrawColor(darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.quickActions)
	self.collapsableOptions:SetLabel("Actions")
	self.collapsableOptions:Dock(TOP)
	function self.collapsableOptions:Paint()
		self:SetBGColor(color_green)
	end

	self.collapsableOptionsScroll = vgui.Create("DScrollPanel", self.collapsableOptions)
	self.collapsableOptionsScroll:Dock(FILL)
	self.collapsableOptions:SetContents(self.collapsableOptionsScroll)

	self.list = vgui.Create("DIconLayout", self.collapsableOptionsScroll)
	self.list:Dock(FILL)
	self.list:SetSpaceY(5)
	self.list:SetSpaceX(5)

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("cowabunga")

	local defaultButton = self:AddSheet("Actions", Material("impulse/icons/banknotes-256.png"), self.quickActions)
	self:AddSheet("Teams", Material("impulse/icons/group-256.png"), self.quickActions)
	self:AddSheet("Business", Material("impulse/icons/cart-73-256.png"), self.quickActions)
	self:AddSheet("Information", Material("impulse/icons/info-256.png"), self.quickActions)

	--timer.Simple(1, function() self.tabSheet:SetActiveButton(defaultButton) end)
end

function PANEL:AddSheet(name, icon, pnl)
	local tab = self.tabSheet:AddSheet(name, pnl)
	local panel = self
	tab.Button:SetSize(120, 130)
	function tab.Button:Paint(w, h)
		if panel.tabSheet.ActiveButton == self then
			surface.SetDrawColor(impulse.Config.MainColour)
		else
			surface.SetDrawColor(color_white)
		end
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(0, 0, w-10, h-40)

		draw.DrawText(name, "Impulse-Elements18", (w-10)/2, 95, color_white, TEXT_ALIGN_CENTER)

		return true
	end
	return tab.Button
end

vgui.Register("impulsePlayerMenu", PANEL, "DFrame")