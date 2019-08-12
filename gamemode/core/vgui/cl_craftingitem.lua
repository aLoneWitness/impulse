local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetTall(86)
end

function PANEL:SetMix(mix)
	local wide = self:GetWide()
	local class = mix.Output
	local id = impulse.Inventory.ClassToNetID(class)
	local item = impulse.Inventory.Items[id]

	self.Item = item
	self.Mix = mix

	local panel = self

	self.model:SetPos(0, 0)
	self.model:SetSize(80, 80)
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

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()

	if item.CamPos then
		self.model:SetCamPos(item.CamPos)
	else
		self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	end

	self.model:SetLookAt((max + min) / 2)

	self.craftBtn = vgui.Create("DButton", self)
	self.craftBtn:Dock(RIGHT)
	self.craftBtn:SetText("Craft")
	self.craftBtn:SetFont("Impulse-Elements17")
	self.craftBtn:SetDisabled(true)

	function self.craftBtn:DoClick()
		panel.dad:DoCraft(panel.Item, panel.Mix)
	end

	local canCraft = true

	function self.craftBtn:Think()
		local level = LocalPlayer():GetSkillLevel("craft")

		if panel.Mix.Level > level and canCraft then
			self:SetDisabled(true)
		else
			self:SetDisabled(false)
		end
	end

	local required = "<font=Impulse-Elements17>"

	for v,k in pairs(mix.Input) do
		local id = impulse.Inventory.ClassToNetID(v)

		if id then
			local name = impulse.Inventory.Items[id].Name
			local has, amount = LocalPlayer():HasInventoryItem(id)
			local need = k.take or 1
			amount = amount or 0

			if amount < need then
				required = required.."<colour=120, 120, 120, 255>"
				canCraft = false
			else
				required = required.."<colour=255, 255, 255, 255>"
			end

			required = required..name.." ("..amount.."/"..need..") "

			required = required.."</colour>"
		end
	end

	required = required.."</font>"

	if canCraft then
		self.craftBtn:SetDisabled(false)
	end

	self.requiredMarkup = markup.Parse(required, 620)
end

local bodyCol = Color(50, 50, 50, 210)
local secCol = Color(209, 209, 209, 255)
local noCol = Color(215, 40, 40, 255)
function PANEL:Paint(w, h)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	local item = self.Item
	local mix = self.Mix
	local level = LocalPlayer():GetSkillLevel("craft")

	if item then
		surface.SetTextColor(item.Colour or color_white)
		surface.SetFont("Impulse-Elements19-Shadow")
		surface.SetTextPos(82, 10)
		surface.DrawText(item.Name)

		if mix.Level > level then
			surface.SetTextColor(noCol)
		else
			surface.SetTextColor(secCol)
		end

		surface.SetFont("Impulse-Elements16")
		surface.SetTextPos(82, 25)
		surface.DrawText("Level: "..mix.Level)

		if self.requiredMarkup then
			self.requiredMarkup:Draw(82, 44, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
end


vgui.Register("impulseCraftingItem", PANEL, "DPanel")