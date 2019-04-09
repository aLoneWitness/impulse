local PANEL = {}

function PANEL:Init()
	self:SetSize(770, 300)
	self:SetPos(0, ScrH() - 320)
	self:CenterHorizontal()
	self:SetTitle("Inventory")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:MakePopup()
 	self:MoveToFront()

 	self.grid = vgui.Create("DIconLayout", self)
 	self.grid:Dock(FILL)
 	self.grid:SetSpaceX(5)
 	self.grid:SetSpaceY(5)

 	for i = 1, 27 do
 		local item = self.grid:Add("impulseInventoryCard")
 		item:SetSize(80, 80)
 	end
end


vgui.Register("impulseInventory", PANEL, "DFrame")
