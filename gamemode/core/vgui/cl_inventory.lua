local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * .58, ScrH() * .7)
	self:Center()
	self:CenterHorizontal()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	--self:MakePopup()
 	self:MoveToFront()

 	local w, h = self:GetSize()

 	self.invBtn = vgui.Create("DButton", self)
 	self.invBtn:SetSize(100, 25)
 	self.invBtn:SetPos(0, 0)
 	self.invBtn:SetText("Inventory")

 	self.craftBtn = vgui.Create("DButton", self)
 	self.craftBtn:SetSize(100, 25)
 	self.craftBtn:SetPos(100, 0)
 	self.craftBtn:SetText("Crafting")

 	self.infoName = vgui.Create("DLabel", self)
 	self.infoName:SetPos(15, 40)
 	self.infoName:SetText(LocalPlayer():Nick())
 	self.infoName:SetFont("Impulse-Elements24-Shadow")
 	self.infoName:SizeToContents()

 	if self.infoName:GetWide() > 250 then
 		self.infoName:SetFont("Impulse-Elements19-Shadow")
 	end

 	local lpTeam = LocalPlayer():Team()
  	self.infoTeam = vgui.Create("DLabel", self)
 	self.infoTeam:SetPos(15, 60)
 	self.infoTeam:SetText(team.GetName(lpTeam))
 	self.infoTeam:SetFont("Impulse-Elements19-Shadow")
 	self.infoTeam:SetColor(team.GetColor(lpTeam))
 	self.infoTeam:SizeToContents()

 	local model = LocalPlayer():GetModel()
 	local skin = LocalPlayer():GetSkin()

 	self.modelPreview = vgui.Create("impulseModelPanel", self)
	self.modelPreview:SetPos(0, 50)
	self.modelPreview:SetSize(270, h * .73)
	self.modelPreview:SetModel(model, skin)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")
	self.modelPreview:SetFOV(self.modelPreview:GetFOV() - 20)

	function self.modelPreview:LayoutEntity(ent)
		ent:SetAngles(Angle(-1, 45, 0))
		ent:SetPos(Vector(20, 15, 6))
		self:RunAnimation()
	end

 	timer.Simple(0, function()
		if not IsValid(self.modelPreview) then
			return
		end

		local ent = self.modelPreview.Entity

		if IsValid(ent) then
			for v,k in pairs(LocalPlayer():GetBodyGroups()) do
				ent:SetBodygroup(k.id, LocalPlayer():GetBodygroup(k.id))
			end
		end
	end)

 	self.invScroll = vgui.Create("DScrollPanel", self)
 	self.invScroll:SetPos(270, 25)
 	self.invScroll:SetSize(w - 270, h - 25)

 	for i=0, 100 do
	local DButton = self.invScroll:Add( "DButton" )
		DButton:SetText( "Button #" .. i )
		DButton:Dock( TOP )
		DButton:DockMargin( 0, 0, 0, 5 )
	end
end

vgui.Register("impulseInventory", PANEL, "DFrame")
