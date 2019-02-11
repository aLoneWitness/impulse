local PANEL = {}

function PANEL:Init()
	self:SetSize(770, 580)
	self:Center()
	self:SetTitle("Player menu")
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.tabSheet = vgui.Create("DColumnSheet", self)
	self.tabSheet:Dock(FILL)
	self.tabSheet.Navigation:SetWidth(100)

	-- actions
	self.quickActions = vgui.Create("DPanel", self.tabSheet)
	self.quickActions:Dock(FILL)
	function self.quickActions:Paint(w, h)
		return true
	end

	-- teams
	self.teams = vgui.Create("DPanel", self.tabSheet)
	self.teams:Dock(FILL)
	function self.teams:Paint(w, h)
		return true
	end

	-- business
	self.business = vgui.Create("DPanel", self.tabSheet)
	self.business:Dock(FILL)
	function self.business:Paint()
		return true
	end

	-- info
	self.info = vgui.Create("DPanel", self.tabSheet)
	self.info:Dock(FILL)
	function self.info:Paint(w, h)
		return true
	end

	local defaultButton = self:AddSheet("Actions", Material("impulse/icons/banknotes-256.png"), self.quickActions, self.QuickActions)
	self:AddSheet("Teams", Material("impulse/icons/group-256.png"), self.teams, self.Teams)
	self:AddSheet("Business", Material("impulse/icons/cart-73-256.png"), self.business, self.Business)
	self:AddSheet("Information", Material("impulse/icons/info-256.png"), self.info, self.Info)

	self.tabSheet:SetActiveButton(defaultButton)
	defaultButton.loaded = true
	self:QuickActions()
	self.tabSheet.ActiveButton.Target:SetVisible(true)
	self.tabSheet.Content:InvalidateLayout()
end

function PANEL:QuickActions()
	local model = LocalPlayer().defaultModel or "models/Humans/Group01/male_02.mdl"
	local skin = LocalPlayer().defaultSkin or 0

	if impulse.Teams.Data[LocalPlayer():Team()].model then
		model = LocalPlayer():GetModel()
		skin = LocalPlayer():GetSkin()
	end
	self.modelPreview = vgui.Create("DModelPanel", self.quickActions)
	self.modelPreview:SetPos(373, 0)
	self.modelPreview:SetSize(300, 370)
	self.modelPreview:SetModel(model)
	self.modelPreview.Entity:SetSkin(skin)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")
	self.modelPreview:SetFOV(self.modelPreview:GetFOV() - 19)
 	function self.modelPreview:LayoutEntity(ent)
 		ent:SetAngles(Angle(0, 43, 0))
 		--ent:SetSequence(ACT_IDLE)
 		--self:RunAnimation()
 	end

 	self.classLbl = vgui.Create("DLabel", self.quickActions)
 	self.classLbl:SetText("Class: ".."error")
 	self.classLbl:SetFont("Impulse-Elements18")
 	self.classLbl:SizeToContents()
 	self.classLbl:SetPos(420, 380)

  	self.rankLbl = vgui.Create("DLabel", self.quickActions)
 	self.rankLbl:SetText("Rank: ".."error")
 	self.rankLbl:SetFont("Impulse-Elements18")
 	self.rankLbl:SizeToContents()
 	self.rankLbl:SetPos(420, 400)

	self.quickActionsInner = vgui.Create("DPanel", self.quickActions)
	self.quickActionsInner:SetSize(400, 580)

	local panel = self
	function self.quickActionsInner:Paint(w, h)
		surface.SetDrawColor(panel.darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.quickActionsInner)
	self.collapsableOptions:SetLabel("Actions")
	self.collapsableOptions:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.collapsableOptions:Paint()
		self:SetBGColor(colInv)
	end

	self.collapsableOptionsScroll = vgui.Create("DScrollPanel", self.collapsableOptions)
	self.collapsableOptionsScroll:Dock(FILL)
	self.collapsableOptions:SetContents(self.collapsableOptionsScroll)

	self.list = vgui.Create("DIconLayout", self.collapsableOptionsScroll)
	self.list:Dock(FILL)
	self.list:SetSpaceY(5)
	self.list:SetSpaceX(5)

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("Drop money")
	function btn:DoClick()
		Derma_StringRequest("impulse", "Enter amount of money to drop:", nil, function(amount)
			LocalPlayer():ConCommand("say /dropmoney "..amount)
		end)
	end

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("Drop weapon")
	function btn:DoClick()
		LocalPlayer():ConCommand("say /dropweapon")
	end

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("Write a letter")
	function btn:DoClick()
		Derma_StringRequest("impulse", "Write letter content:", nil, function(text)
			LocalPlayer():ConCommand("say /write "..text)
		end)
	end

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("Change RP name")

	local btn = self.list:Add("DButton")
	btn:Dock(TOP)
	btn:SetText("Sell all doors")

	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.quickActionsInner)
	self.collapsableOptions:SetLabel(team.GetName(LocalPlayer():Team()).." options")
	self.collapsableOptions:Dock(TOP)
	local colTeam = team.GetColor(LocalPlayer():Team())
	function self.collapsableOptions:Paint()
		self:SetBGColor(colTeam)
	end

	self.collapsableOptionsScroll = vgui.Create("DScrollPanel", self.collapsableOptions)
	self.collapsableOptionsScroll:Dock(FILL)
	self.collapsableOptions:SetContents(self.collapsableOptionsScroll)

	self.list = vgui.Create("DIconLayout", self.collapsableOptionsScroll)
	self.list:Dock(FILL)
	self.list:SetSpaceY(5)
	self.list:SetSpaceX(5)
end

function PANEL:Teams()
	self.modelPreview = vgui.Create("DModelPanel", self.teams)
	self.modelPreview:SetPos(373, 0)
	self.modelPreview:SetSize(300, 370)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")
	self.modelPreview:SetFOV(self.modelPreview:GetFOV() - 19)
 	function self.modelPreview:LayoutEntity(ent)
 		ent:SetAngles(Angle(0, 43, 0))
 		--ent:SetSequence(ACT_IDLE)
 		--self:RunAnimation()
 	end

 	self.descLbl = vgui.Create("DLabel", self.teams)
 	self.descLbl:SetText("Description:")
 	self.descLbl:SetFont("Impulse-Elements18")
 	self.descLbl:SizeToContents()
 	self.descLbl:SetPos(410, 380)

  	self.descLblT = vgui.Create("DLabel", self.teams)
 	self.descLblT:SetText("")
 	self.descLblT:SetFont("Impulse-Elements14")
 	self.descLblT:SetPos(410, 400)
 	self.descLblT:SetContentAlignment(7)
  	self.descLblT:SetSize(230, 230)

	self.teamsInner = vgui.Create("DPanel", self.teams)
	self.teamsInner:SetSize(400, 580)
	local panel = self
	function self.teamsInner:Paint(w, h)
		surface.SetDrawColor(panel.darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.availibleTeams = vgui.Create("DCollapsibleCategory", self.teamsInner)
	self.availibleTeams:SetLabel("Available teams")
	self.availibleTeams:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.availibleTeams:Paint()
		self:SetBGColor(colInv)
	end

	self.availibleTeamsScroll = vgui.Create("DScrollPanel", self.availibleTeams)
	self.availibleTeamsScroll:Dock(FILL)
	self.availibleTeams:SetContents(self.availibleTeamsScroll)

	local availibleList = vgui.Create("DIconLayout", self.availibleTeamsScroll)
	availibleList:Dock(FILL)
	availibleList:SetSpaceY(5)
	availibleList:SetSpaceX(5)

	self.unavailibleTeams = vgui.Create("DCollapsibleCategory", self.teamsInner)
	self.unavailibleTeams:SetLabel("Unavailable teams")
	self.unavailibleTeams:Dock(TOP)
	function self.unavailibleTeams:Paint()
		self:SetBGColor(colInv)
	end

	self.unavailibleTeamsScroll = vgui.Create("DScrollPanel", self.unavailibleTeams)
	self.unavailibleTeamsScroll:Dock(FILL)
	self.unavailibleTeams:SetContents(self.unavailibleTeamsScroll)

	local unavailibleList = vgui.Create("DIconLayout", self.unavailibleTeamsScroll)
	unavailibleList:Dock(FILL)
	unavailibleList:SetSpaceY(5)
	unavailibleList:SetSpaceX(5)

	for v,k in pairs(impulse.Teams.Data) do
		local selectedList

		if (k.xp > LocalPlayer():GetXP()) or (k.donatorOnly and k.donatorOnly == true and LocalPlayer():IsDonator() == false) then
			selectedList = unavailibleList
		else
			selectedList = availibleList
		end

		local teamCard = selectedList:Add("impulseTeamCard")
		teamCard:SetTeam(v)
		teamCard.team = v
		teamCard:Dock(TOP)
		teamCard:SetHeight(60)
		teamCard:SetMouseInputEnabled(true)
		
		local realSelf = self

		function teamCard:OnCursorEntered()
			local model = impulse.Teams.Data[self.team].model
			local skin = impulse.Teams.Data[self.team].skin or 0
			local desc = impulse.Teams.Data[self.team].description
			local bodygroups = impulse.Teams.Data[self.team].bodygroups

			if not model then
				model = LocalPlayer().defaultModel or "models/Humans/Group01/male_02.mdl" 
				skin = LocalPlayer().defaultSkin or 0
			end

			realSelf.modelPreview:SetModel(model)
			realSelf.modelPreview.Entity:SetSkin(skin)

			if bodygroups then
				for v, bodygroupData in pairs(bodygroups) do
					realSelf.modelPreview.Entity:SetBodygroup(bodygroupData[1], (bodygroupData[2] or 0))
				end
			end

			realSelf.descLblT:SetText(desc)
			realSelf.descLblT:SetWrap(true)
		end

		function teamCard:OnMousePressed()
			net.Start("impulseTeamChange")
			net.WriteUInt(self.team, 8)
			net.SendToServer()

			realSelf:Remove()
		end
	end
end

function PANEL:Business()
	self.buyableItems = vgui.Create("DCollapsibleCategory", self.business)
	self.buyableItems:SetLabel("Available items")
	self.buyableItems:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.buyableItems:Paint()
		self:SetBGColor(colInv)
	end

	self.buyableItemsScroll = vgui.Create("DScrollPanel", self.availibleTeams)
	self.buyableItemsScroll:Dock(FILL)
	self.buyableItems:SetContents(self.buyableItemsScroll)

	local availibleList = vgui.Create("DIconLayout", self.buyableItemsScroll)
	availibleList:Dock(FILL)
	availibleList:SetSpaceY(5)
	availibleList:SetSpaceX(5)

	for name,k in pairs(impulse.Business.Data) do
		if not LocalPlayer():CanBuy(name) then
			continue
		end

		local item = availibleList:Add("SpawnIcon")
		item:SetModel(k.model)
		item:SetSize(58,58)
		item:SetTooltip(name.." \n"..impulse.Config.CurrencyPrefix..k.price)

		local costLbl = vgui.Create("DLabel", item)
		costLbl:SetPos(5,35)
		costLbl:SetFont("Impulse-Elements20-Shadow")
		costLbl:SetText(impulse.Config.CurrencyPrefix..k.price)
		costLbl:SizeToContents()
	end
end

function PANEL:Info()
	self.infoSheet = vgui.Create("DPropertySheet", self.info)
	self.infoSheet:Dock(FILL)

	local webRules = vgui.Create("DHTML", self.infoSheet)
	webRules:OpenURL(impulse.Config.RulesURL)

	self.infoSheet:AddSheet("Rules", webRules)

	local webTutorial = vgui.Create("DHTML", self.infoSheet)
	webTutorial:OpenURL(impulse.Config.TutorialURL)

	self.infoSheet:AddSheet("Help & Tutorials", webTutorial)

	local credits = vgui.Create("DLabel")
	credits:SetText([[impulse framework:
		Jake Green - vin - framework creator

		impulse Half-Life 2 Roleplay schema:
		Jake Green - vin - schema creator
		Sander van Dinteren - aLoneWitness - contributor

		Third-party modules:
		Alex Grist - MySQL wrapper and netstream2
		thelastpenguin - pON
		Cat.jpeg - some string functions
		Kyle Smith - UTF-8 module
		rebel1324 and Chessnut - animations base

		Early testing (and feedback) team:
		confused
		Bwah
		KTG
		Law
		Oscar Holmes
		Lefton
		Y Tho
		Morgan



		Find out how impulse was made at www.vingard.ovh/category/impulse
		Copyright Jake Green 2019]])
	credits:SetContentAlignment(7)
	credits:SetFont("Impulse-Elements18")
	credits:SetPos(5,5)

	self.infoSheet:AddSheet("Credits", credits)

	local gdpr = vgui.Create("DLabel")
	gdpr:SetText([[What information impulse stores:
		Your SteamID
		A unique ID code for your account
		Your RP name
		Your group
		Your RP group
		Your XP
		Your money and bank money
		Your inventory
		Your ranks
		Your model
		Your skin
		Misc. cosmetic data
		UNIX epoch of first join
		Misc. data that can be stored by plugins or the schema
		Chat logs (including private messages)

		If you have any issues or wish for your data to be removed, 
		please contact admin@impulse-community.com. Please note, we
		reserve the right to refuse to remove your data as none of
		it is personal. Your data will never be sold to a third-party.

		Please do not use impulse as a method for private communitcation,
		all communication data is stored and reviewed.

		All log data will be deleted after 30 days automatically, however
		the data may be stored idefinitely if it violates server rules.]])
	gdpr:SetContentAlignment(7)
	gdpr:SetFont("Impulse-Elements18")
	gdpr:SetPos(5,5)

	self.infoSheet:AddSheet("Privacy", gdpr)
end

function PANEL:AddSheet(name, icon, pnl, loadFunc)
	local tab = self.tabSheet:AddSheet(name, pnl)
	local panel = self
	tab.Button:SetSize(120, 130)

	function tab.Button:Paint(w, h)
		if panel.tabSheet.ActiveButton == self then
			surface.SetDrawColor(impulse.Config.MainColour)
		else
			surface.SetDrawColor(color_white)
		end
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(0, 0, w-10, h-40)

		draw.DrawText(name, "Impulse-Elements18", (w-10)/2, 95, color_white, TEXT_ALIGN_CENTER)

		return true
	end

	local oldClick = tab.Button.DoClick
	function tab.Button:DoClick()
		oldClick()

		if loadFunc and not self.loaded then
			loadFunc(panel)
			self.loaded = true
		end
	end
	return tab.Button
end

vgui.Register("impulsePlayerMenu", PANEL, "DFrame")