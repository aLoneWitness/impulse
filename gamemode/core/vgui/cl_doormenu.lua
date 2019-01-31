local PANEL = {}

function PANEL:Init()
	self:SetSize(200, 600)
	self:Center()
	self:SetTitle("Door Interaction")
	self:MakePopup()

	self.addY = 0
end

function PANEL:AddAction(icon, name, onClick)
	self.btn = vgui.Create("DImageButton", self)
	self.btn:SetSize(90, 90)
	self.btn:SetPos(55, 40 + self.addY)
	self.btn:SetImage(icon)

	function self.btn:Paint()
		if self:IsHovered() then
			self:SetColor(impulse.Config.MainColour)
		else
			self:SetColor(color_white)
		end
	end

	self.btn.DoClick = onClick

	self.iconLbl = vgui.Create("DLabel", self)
	self.iconLbl:SetText(name)
	self.iconLbl:SetFont("Impulse-Elements18")
	self.iconLbl:SizeToContents()
	self.iconLbl:SetPos(100-(self.iconLbl:GetWide()/2), self.addY+140)

	self.addY = self.addY + 125
end

function PANEL:SetDoor(door, data)
	print(door:EntIndex())
	PrintTable(data or {})
	if data and data.owners and data.owners[LocalPlayer()] then
		self:AddAction("impulse/icons/padlock-2-256.png", "Unlock")
		self:AddAction("impulse/icons/padlock-256.png", "Lock")
	end

	if not data then
		self:AddAction("impulse/icons/banknotes-256.png", "Buy", function()
			print(door:EntIndex())
			netstream.Start("impulseDoorBuy", door:EntIndex())
		end)
	end

	if data and data.owners and data.owners[LocalPlayer()] then
		self:AddAction("impulse/icons/group-256.png", "Permissions")
	end
end


vgui.Register("impulseDoorMenu", PANEL, "DFrame")