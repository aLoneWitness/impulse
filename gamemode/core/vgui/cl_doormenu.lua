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

function PANEL:SetDoor(door)
	local panel = self
	local doorOwners = door:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
	local doorGroup =  door:GetSyncVar(SYNC_DOOR_GROUP, nil)
	local doorBuyable = door:GetSyncVar(SYNC_DOOR_BUYABLE, true)

	if LocalPlayer():CanLockUnlockDoor(doorOwners, doorGroup) then
		self:AddAction("impulse/icons/padlock-2-256.png", "Unlock", function()
			netstream.Start("impulseDoorUnlock")
			panel:Remove()
		end)
		self:AddAction("impulse/icons/padlock-256.png", "Lock", function()
			netstream.Start("impulseDoorLock")
			panel:Remove()
		end)
	end

	if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) then
		self:AddAction("impulse/icons/banknotes-256.png", "Buy", function()
			netstream.Start("impulseDoorBuy")
			panel:Remove()
		end)
	end

	if LocalPlayer():IsDoorOwner(doorOwners) then
		self:AddAction("impulse/icons/group-256.png", "Permissions", function()
			chat.AddText("Permissions are coming to doors near you soon.")
		end)
		self:AddAction("impulse/icons/banknotes-256.png", "Sell", function()
			netstream.Start("impulseDoorSell")
			panel:Remove()
		end)
	end

	hook.Run("DoorMenuAddOptions", self, door, doorOwners, doorGroup, doorBuyable)
end


vgui.Register("impulseDoorMenu", PANEL, "DFrame")