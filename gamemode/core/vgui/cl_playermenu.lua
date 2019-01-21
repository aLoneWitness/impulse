local PANEL = {}

function PANEL:Init()
	self:SetSize(770, 580)
	self:Center()
	self:SetTitle("Player menu")
	self:MakePopup()

	self.tabSheet = vgui.Create("DColumnSheet", self)
	self.tabSheet:Dock(FILL)

	self.quickActions = vgui.Create("DPanel", self.tabSheet)
	self.quickActions:Dock(FILL)

	self.tabSheet:AddSheet("Actions", self.quickActions, "icon16/money.png")
end


vgui.Register("impulsePlayerMenu", PANEL, "DFrame")