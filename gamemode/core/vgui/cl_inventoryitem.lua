local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)
	self:SetTall(64)
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

	self.model:SetPos(0, 0)
	self.model:SetSize(64, 64)
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
end

function PANEL:OnMousePressed(keycode)
	if keycode != MOUSE_RIGHT then return end

	local popup = DermaMenu(self)
	popup.Inv = self

	if self.Item.OnUse then
		popup:AddOption(self.Item.UseName or "Use")
	end

	if self.Item.OnEquip then
		popup:AddOption(self.Item.EqupName or "Equip")
	end

	popup:AddOption("Drop")

	function popup:Think()
		if not IsValid(self.Inv) then
			return self:Remove()
		end
	end

	popup:Open()
end

local bodyCol = Color(50, 50, 50, 210)
local restrictedCol = Color(255, 223, 0, 255)
local illegalCol = Color(255, 0, 0, 255)
local equippedCol =  Color(0, 220, 0, 140)
local restrictedMat =  Material("icon16/error.png")
local illegalMat = Material("icon16/exclamation.png")
function PANEL:Paint(w, h)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	local item =  self.Item
	if item then
		surface.SetTextColor(item.Colour or color_white)
		surface.SetFont("Impulse-Elements19-Shadow")
		surface.SetTextPos(65, 10)
		surface.DrawText(item.Name)

		surface.SetTextColor(color_white)
		surface.SetTextPos(65, 30)
		surface.SetFont("Impulse-Elements16")
		surface.DrawText(item.Desc or "")

		draw.SimpleText((item.Weight or 0).."kg", "Impulse-Elements16", w - 10, 10, color_white, TEXT_ALIGN_RIGHT)

		if false then -- if restrict check here
			draw.SimpleText("Restricted", "Impulse-Elements16", w - 34, 30, restrictedCol, TEXT_ALIGN_RIGHT)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(restrictedMat)
			surface.DrawTexturedRect(w - 30, 30, 16, 16)
		elseif item.Illegal then
			draw.SimpleText("Contraband", "Impulse-Elements16", w - 34, 30, illegalCol, TEXT_ALIGN_RIGHT)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(illegalMat)
			surface.DrawTexturedRect(w - 30, 30, 16, 16)
		end

		if true then -- if equipped
			surface.SetDrawColor(equippedCol)
			surface.DrawRect(0, 0, 5, h)
		end
	end
end


vgui.Register("impulseInventoryItem", PANEL, "DPanel")