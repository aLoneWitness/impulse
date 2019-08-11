local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)
	self:SetTall(74)

	self:SetCursor("hand")
end

function PANEL:SetMix(mix)
	local wide = self:GetWide()
	local class = mix.Output
	local id = impulse.Inventory.ClassToNetID(class)
	local item = impulse.Inventory.Items[id]

	self.Item = item

	local panel = self

	self.model:SetPos(0, 0)
	self.model:SetSize(64, 64)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetSkin(item.Skin or 0)
	self.model:SetFOV(item.FOV or 35)

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))

		if panel.Item.Material then
			ent:SetMaterial(panel.Item.Material)
		end

		if not item.NoCenter then
			self:SetLookAt(Vector(0, 0, 0))
		end
	end

	function self.model:DoClick()
		panel:OnMousePressed()
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()

	if item.CamPos then
		self.model:SetCamPos(item.CamPos)
	else
		self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	end

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
end

function PANEL:OnMousePressed(keycode)
	
end

local bodyCol = Color(50, 50, 50, 210)
function PANEL:Paint(w, h)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	local item = self.Item
	if item then
		surface.SetTextColor(item.Colour or color_white)
		surface.SetFont("Impulse-Elements19-Shadow")
		surface.SetTextPos(65, 10)
		surface.DrawText(item.Name)
	end
end


vgui.Register("impulseCraftingItem", PANEL, "DPanel")