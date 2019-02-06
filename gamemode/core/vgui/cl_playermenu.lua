local PANEL = {}

function PANEL:Init()
	self:SetSize(770, 580)
	self:Center()
	self:SetTitle("Player menu")
	self:MakePopup()

	local darkOverlay = Color(40, 40, 40, 160)

	self.tabSheet = vgui.Create("DColumnSheet", self)
	self.tabSheet:Dock(FILL)
	self.tabSheet.Navigation:SetWidth(100)

	-- actions
	self.quickActions = vgui.Create("DPanel", self.tabSheet)
	self.quickActions:Dock(FILL)
	function self.quickActions:Paint(w, h)
		return true
	end

	self.modelPreview = vgui.Create("DModelPanel", self.quickActions)
	self.modelPreview:SetPos(373, 0)
	self.modelPreview:SetSize(300, 370)
	self.modelPreview:SetModel(LocalPlayer():GetModel() or "models/error.mdl")
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
	function self.quickActionsInner:Paint(w, h)
		surface.SetDrawColor(darkOverlay)
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

	-- teams
	self.teams = vgui.Create("DPanel", self.tabSheet)
	self.teams:Dock(FILL)
	function self.teams:Paint(w, h)
		return true
	end

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
 	self.descLblT:SetFont("Impulse-Elements16")
 	self.descLblT:SetPos(410, 400)
 	self.descLblT:SetContentAlignment(7)
  	self.descLblT:SetSize(230, 230)

	self.teamsInner = vgui.Create("DPanel", self.teams)
	self.teamsInner:SetSize(400, 580)
	function self.teamsInner:Paint(w, h)
		surface.SetDrawColor(darkOverlay)
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

	local list = vgui.Create("DIconLayout", self.availibleTeamsScroll)
	list:Dock(FILL)
	list:SetSpaceY(5)
	list:SetSpaceX(5)

	for v,k in pairs(impulse.Teams.Data) do
		local teamCard = list:Add("impulseTeamCard")
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
	end


	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.teamsInner)
	self.collapsableOptions:SetLabel("Unavailable teams")
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

	local defaultButton = self:AddSheet("Actions", Material("impulse/icons/banknotes-256.png"), self.quickActions)
	self:AddSheet("Teams", Material("impulse/icons/group-256.png"), self.teams)
	self:AddSheet("Business", Material("impulse/icons/cart-73-256.png"), self.quickActions)
	self:AddSheet("Information", Material("impulse/icons/info-256.png"), self.quickActions)

	--timer.Simple(1, function() self.tabSheet:SetActiveButton(defaultButton) end)
end

function PANEL:AddSheet(name, icon, pnl)
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
	return tab.Button
end

vgui.Register("impulsePlayerMenu", PANEL, "DFrame")