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
 		box:SetMouseInputEnabled(true)

 		function box:Think()
 			if not self:IsHovered() then
 				self.hoverStart = nil	
 			end

 			if self.hoverStart and self.hoverStart < CurTime() then
 				if self:IsHovered() then
 					panel.hover = vgui.Create("impulseInventoryHover")
 					panel.hover:SetItem(self)
 					self.hoverStart = nil
 				end
 			end

 			if self:IsHovered() and not self.hoverStart and (not panel.hover or not IsValid(panel.hover)) then
 				self.hoverStart = CurTime() + 0.7
 			end
 		end
 	end
end

vgui.Register("impulseInventory", PANEL, "DFrame")
