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

	local tab = self.tabSheet:AddSheet("Actions", self.quickActions, "icon16/money.png")
	tab.Button:SetFont("Impulse-Elements16")

	local tab = self.tabSheet:AddSheet("Teams", self.quickActions, "icon16/user_suit.png")
	tab.Button:SetFont("Impulse-Elements16")

	local tab = self.tabSheet:AddSheet("Business", self.quickActions, "icon16/cart.png")
	tab.Button:SetFont("Impulse-Elements16")

	local tab = self.tabSheet:AddSheet("Help", self.quickActions, "icon16/information.png")
	tab.Button:SetFont("Impulse-Elements16")

	local tab = self.tabSheet:AddSheet("Rules", self.quickActions, "icon16/delete.png")
	tab.Button:SetFont("Impulse-Elements16")
end


vgui.Register("impulsePlayerMenu", PANEL, "DFrame")