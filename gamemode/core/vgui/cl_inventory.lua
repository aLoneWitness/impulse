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

 	local className = LocalPlayer():GetTeamClassName()
 	local rankName = LocalPlayer():GetTeamRankName()

 	if className != "Default" then
	 	self.infoClassRank = vgui.Create("DLabel", self)
	 	self.infoClassRank:SetPos(15, 80)
	 	self.infoClassRank:SetFont("Impulse-Elements19-Shadow")
	 	self.infoClassRank:SetText(className)
	 	self.infoClassRank:SetColor(team.GetColor(lpTeam))
	 	self.infoClassRank:SizeToContents()
	end

 	local model = LocalPlayer():GetModel()
 	local skin = LocalPlayer():GetSkin()

 	self.modelPreview = vgui.Create("impulseModelPanel", self)
	self.modelPreview:SetPos(0, 70)
	self.modelPreview:SetSize(270, h * .75)
	self.modelPreview:SetModel(model, skin)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")
	self.modelPreview:SetFOV((324 / ScrH()) * 100) -- a incredible equation that makes the model fit onto the ui, patent by professor vin

	function self.modelPreview:LayoutEntity(ent)
		ent:SetAngles(Angle(-1, 45, 0))
		ent:SetPos(Vector(0, 0, 2.5))
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

 	self.invName = vgui.Create("DLabel", self)
 	self.invName:SetPos(270, 35)
 	self.invName:SetText("Inventory")
 	self.invName:SetFont("Impulse-Elements24-Shadow")
 	self.invName:SizeToContents()

 	self:SetupItems(w, h)
end

function PANEL:SetupItems()
	local w, h = self:GetSize()
	
	if self.invScroll and IsValid(self.invScroll) then
		self.invScroll:Remove()
	end

	self.invScroll = vgui.Create("DScrollPanel", self)
 	self.invScroll:SetPos(270, 65)
 	self.invScroll:SetSize(w - 270, h - 65)
	self.items = {}
 	local weight = 0
 	local localInv = impulse.Inventory.Data[0][1]

 	if impulse.GetSetting("inv_sortbyweight") then
 		table.sort(localInv, function(a, b)
 			if not b then
 				return true
 			end

 			local aWeight = (impulse.Inventory.Items[a.id].Weight or 0)
 			local bWeight = (impulse.Inventory.Items[b.id].Weight or 0)

 			return aWeight > bWeight
 		end)
 	end

 	if localInv and #localInv > 0 then
	 	for v,k in pairs(localInv) do -- 01 is player 0 (localplayer) and storage 1 (local inv)
	 		local otherItem = self.items[k.id]
	 		local itemX = impulse.Inventory.Items[k.id]

	 		if itemX.CanStack and otherItem then
	 			otherItem.Count = (otherItem.Count or 1) + 1
	 		else
				self.items[v] = self.invScroll:Add("impulseInventoryItem")
				local item = self.items[v]
				item:Dock(TOP)
				item:DockMargin(0, 0, 15, 5)
				item:SetItem(k, w)
				item.InvID = v
				self.items[k.id] = item
			end

			weight =  weight + (itemX.Weight or 0)
		end
	else
		self.empty = self.invScroll:Add("DLabel", self)
		self.empty:SetContentAlignment(5)
		self.empty:Dock(TOP)
		self.empty:SetText("Empty")
		self.empty:SetFont("Impulse-Elements19-Shadow")
	end

	self.invWeight = weight
end

function PANEL:FindItemPanelByID(id)
	return self.items[id]
end

local grey = Color(209, 209, 209)
function PANEL:PaintOver(w, h)
	draw.SimpleText(self.invWeight.."kg/"..impulse.Config.InventoryMaxWeight.."kg", "Impulse-Elements18-Shadow", w - 18, 40, grey, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

vgui.Register("impulseInventory", PANEL, "DFrame")
