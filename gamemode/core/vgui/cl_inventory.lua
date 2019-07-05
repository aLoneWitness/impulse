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

 	self.infoName = vgui.Create("DLabel", self)
 	self.infoName:SetPos(15, 40)
 	self.infoName:SetText(LocalPlayer():Nick())
 	self.infoName:SetFont("Impulse-Elements24-Shadow")
 	self.infoName:SizeToContents()

 	if self.infoName:GetWide() > 245 then
 		self.infoName:SetFont("Impulse-Elements19-Shadow")
 	end

 	local lpTeam = LocalPlayer():Team()
  	self.infoTeam = vgui.Create("DLabel", self)
 	self.infoTeam:SetPos(15, 64)
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
	self.modelPreview:SetPos(0, 80)
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
	self.itemsPanels = {}
 	local weight = 0
 	local realInv = impulse.Inventory.Data[0][1]
 	local localInv = table.Copy(impulse.Inventory.Data[0][1]) or {}
 	local reccurTemp = {}
 	local equipTemp = {}

 	for v,k in pairs(localInv) do -- fix for fucking table.sort desyncing client/server itemids!!!!!!!
 		k.realKey = v

 		reccurTemp[k.id] = (reccurTemp[k.id] or 0) + (impulse.Inventory.Items[k.id].Weight or 0)
 		k.sortWeight = reccurTemp[k.id]
 	end

 	--if impulse.GetSetting("inv_sortbyweight") then -- super messy sorting systems for the tables below
 	--	localInv = SortedPairsByMemberValue(localInv, "sortWeight")
 	--end

 	-- if impulse.GetSetting("inv_sortequippablesattop") then
 	-- 	local ridTemp = {} -- temp table 

 	-- 	for v,k in pairs(localInv) do 
 	-- 		if impulse.Inventory.Items[k.id].OnEquip then
 	-- 			table.insert(ridTemp, v) -- add to destroy tbl
 	-- 			table.insert(equipTemp, k) -- add to table to merge with localInv copy
 	-- 		end
 	-- 	end

 	-- 	local take = 0
 	-- 	for v,k in pairs(ridTemp) do -- im doing this because i cant table.remove on the go because it destroys the loop
 	-- 		table.remove(localInv, k - take) --looks shit and hacky but it needs to be
 	-- 		take = take + 1
 	-- 	end

 	-- 	table.Add(equipTemp, localInv) -- put localinv on the end of eqiuptemp
 	-- 	localInv = equipTemp -- filp them around lol
 	-- end

 	if localInv and table.Count(localInv) > 0 then
	 	for v,k in SortedPairsByMemberValue(localInv, "sortWeight", true) do -- 01 is player 0 (localplayer) and storage 1 (local inv)
	 		local otherItem = self.items[k.id]
	 		local itemX = impulse.Inventory.Items[k.id]

	 		if itemX.CanStack and otherItem then
	 			otherItem.Count = (otherItem.Count or 1) + 1
	 		else
	 			local item = self.invScroll:Add("impulseInventoryItem")
				item:Dock(TOP)
				item:DockMargin(0, 0, 15, 5)
				item:SetItem(k, w)
				item.InvID = k.realKey
				item.InvPanel = self
				self.items[k.id] = item
				self.itemsPanels[k.realKey] = item
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
	return self.itemsPanels[id]
end

local grey = Color(209, 209, 209)
function PANEL:PaintOver(w, h)
	draw.SimpleText(self.invWeight.."kg/"..impulse.Config.InventoryMaxWeight.."kg", "Impulse-Elements18-Shadow", w - 18, 40, grey, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

vgui.Register("impulseInventory", PANEL, "DFrame")
