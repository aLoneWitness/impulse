local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)
	self:SetTall(64)

	self:SetCursor("hand")
end

function PANEL:Paint()
end

function PANEL:SetItem(netitem, wide)
	local item = impulse.Inventory.Items[netitem.id]
	self.Item = item
	self.IsEquipped = netitem.equipped or false
	self.IsRestricted = netitem.restricted or false
	self.Weight = item.Weight or 0
	self.Count = 1

	local panel = self

	self.model:SetPos(0, 0)
	self.model:SetSize(64, 64)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetFOV(item.FOV or 35)

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))

		if not item.NoCenter then
			self:SetLookAt(ent:OBBCenter())
		end
	end

	function self.model:DoClick()
		panel:OnMousePressed()
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()
	self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	self.model:SetLookAt((max + min) / 2)

	self.desc = vgui.Create("DLabel", self)
	self.desc:SetPos(65, 30)
	self.desc:SetSize(wide - 530, 30)

	if wide < 800 then -- small resolutions have trouble with 16
		self.desc:SetFont("Impulse-Elements14")
	else
		self.desc:SetFont("Impulse-Elements16")
	end

	self.desc:SetText(item.Desc or "")
	self.desc:SetContentAlignment(7)
	self.desc:SetWrap(true)

	self.count = vgui.Create("DLabel", self)
	self.count:SetPos(38, 38)
	self.count:SetText("")
	self.count:SetTextColor(impulse.Config.MainColour)
	self.count:SetFont("Impulse-Elements19-Shadow")
	self.count:SetSize(30, 20)

	function self.count:Think()
		if panel.Count > 1 and panel.Count != self.lastCount then
			self:SetText("x"..panel.Count)
			self.lastCount = panel.Count
			panel.Weight = panel.Count * panel.Item.Weight
		end
	end
end

function PANEL:OnMousePressed(keycode)
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

		draw.SimpleText(self.Weight.."kg", "Impulse-Elements16", w - 10, 10, color_white, TEXT_ALIGN_RIGHT)

		if self.IsRestricted then -- if restrict check here
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

		if self.IsEquipped then -- if equipped
			surface.SetDrawColor(equippedCol)
			surface.DrawRect(0, 0, 5, h)
		end
	end
end


vgui.Register("impulseInventoryItem", PANEL, "DPanel")