local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * .58, ScrH() * .7)
	self:Center()
	self:CenterHorizontal()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	--self:MakePopup()
 	self:MoveToFront()

 	local w, h = self:GetSize()

 	self.invBtn = vgui.Create("DButton", self)
 	self.invBtn:SetSize(100, 25)
 	self.invBtn:SetPos(0, 0)
 	self.invBtn:SetText("Inventory")

 	self.craftBtn = vgui.Create("DButton", self)
 	self.craftBtn:SetSize(100, 25)
 	self.craftBtn:SetPos(100, 0)
 	self.craftBtn:SetText("Crafting")

 	self.infoName = vgui.Create("DLabel", self)
 	self.infoName:SetPos(15, 40)
 	self.infoName:SetText(LocalPlayer():Nick())
 	self.infoName:SetFont("Impulse-Elements24-Shadow")
 	self.infoName:SizeToContents()

 	if self.infoName:GetWide() > 250 then
 		self.infoName:SetFont("Impulse-Elements19-Shadow")
 	end

 	local lpTeam = LocalPlayer():Team()
  	self.infoTeam = vgui.Create("DLabel", self)
 	self.infoTeam:SetPos(15, 60)
 	self.infoTeam:SetText(team.GetName(lpTeam))
 	self.infoTeam:SetFont("Impulse-Elements19-Shadow")
 	self.infoTeam:SetColor(team.GetColor(lpTeam))
 	self.infoTeam:SizeToContents()

 	self.invScroll = vgui.Create("DScrollPanel", self)
 	self.invScroll:SetPos(270, 25)
 	self.invScroll:SetSize(w - 270, h - 25)

 	for i=0, 100 do
	local DButton = self.invScroll:Add( "DButton" )
		DButton:SetText( "Button #" .. i )
		DButton:Dock( TOP )
		DButton:DockMargin( 0, 0, 0, 5 )
	end
end

vgui.Register("impulseInventory", PANEL, "DFrame")
