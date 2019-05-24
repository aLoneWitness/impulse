local PANEL = {}

function PANEL:Init()
	self:SetSize(570, 200)
	self:SetPos(0, ScrH() - 220)
	self:CenterHorizontal()
	self:SetTitle("Inventory")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	--self:MakePopup()
 	self:MoveToFront()

 	input.SetCursorPos(ScrW() / 2, ScrH() - 280)

 	self.weight = vgui.Create("DLabel", self)
 	self.weight:SetPos(self:GetWide() - 50, 5)
 	self.weight:SetText("0kg/20kg")
 	self.weight:SizeToContents()

 	self.grid = vgui.Create("DIconLayout", self)
 	self.grid:DockMargin(6, 5, 0, 10)
 	self.grid:Dock(FILL)
 	self.grid:SetSpaceX(5)
 	self.grid:SetSpaceY(5)

 	local panel = self

 	for i = 1, 14 do
 		local box = self.grid:Add("impulseInventoryCard")
 		box:SetSize(74, 74)

 		if impulse.Inventory.Items[i] then
	 		local item = vgui.Create("impulseInventoryItem", box)
	 		item:Dock(FILL)
	 		item:SetItem(impulse.Inventory.Items[i])
	 	end
 	end
end

vgui.Register("impulseInventory", PANEL, "DFrame")
