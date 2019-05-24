local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)

	self:Droppable("impulseInv")
end

function PANEL:Paint()
end

function PANEL:Think()
	if not self.Item then return end

 	local panel = self:GetParent()

 	if not self.model:IsHovered() then
 		self.hoverStart = nil	
 	end

 	if self.hoverStart and self.hoverStart < CurTime() then
 		if self.model:IsHovered() then
 			panel.hover = vgui.Create("impulseInventoryHover")
 			panel.hover:SetItem(self)
 			self.hoverStart = nil
 		end
 	end

 	if self.model:IsHovered() and not self.hoverStart and (not panel.hover or not IsValid(panel.hover)) then
 		self.hoverStart = CurTime() + 0.7
 	end
 end

function PANEL:SetItem(item)
	self.Item = item

	self.model:Dock(FILL)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetFOV(item.FOV or 35)

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()
	self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	self.model:SetLookAt((max + min) / 2)

	local panel = self

	function self.model:OnMousePressed(keycode)
		if keycode != MOUSE_RIGHT then return end

		local popup = DermaMenu(self)
		popup.Inv = panel

		if panel.Item.OnUse then
			popup:AddOption(panel.Item.UseName or "Use")
		end

		if panel.Item.OnEquip then
			popup:AddOption(panel.Item.EqupName or "Equip")
		end

		popup:AddOption("Drop")

		function popup:Think()
			if not IsValid(self.Inv) then
				return self:Remove()
			end
		end

		popup:Open()
	end
end


vgui.Register("impulseInventoryItem", PANEL, "DPanel")