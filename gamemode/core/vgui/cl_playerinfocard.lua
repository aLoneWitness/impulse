local PANEL = {}

local quickTools = {
	{name="Goto", command="test", icon="icon16/shield.png"}
}


function PANEL:Init()
	timer.Simple(0, function() -- Time to allow SetPlayer to catch up
		self:SetSize(600, 400)
		self:Center()
		self:SetTitle("Player Information")
		self:MakePopup()

		-- 3d model
		self.characterPreview = vgui.Create("impulseModelPanel", self)
		self.characterPreview:SetSize(600,400)
		self.characterPreview:SetPos(200,30)
		self.characterPreview:SetFOV(80)
		self.characterPreview:SetModel(self.Player:GetModel(), self.Player:GetSkin())
		self.characterPreview:MoveToBack()
		self.characterPreview:SetCursor("arrow")
		--local charPreview = self.characterPreview
		function self.characterPreview:LayoutEntity(ent) 
			--ent:SetSequence(ent:LookupSequence("idle"))
			ent:SetAngles(Angle(0,40,0))
			--charPreview:RunAnimation()
		end
		
		timer.Simple(0, function()
			if not IsValid(self.characterPreview) then
				return
			end

			local ent = self.characterPreview.Entity

			if IsValid(ent) and IsValid(self.Player) then
				for v,k in pairs(self.Player:GetBodyGroups()) do
					ent:SetBodygroup(k.id, self.Player:GetBodygroup(k.id))
				end
			end
		end)

		-- Steam name
		self.oocName = vgui.Create("DLabel", self)
		self.oocName:SetFont("Impulse-CharacterInfo-NO")
		self.oocName:SetText(self.Player:SteamName())
		self.oocName:SizeToContents()
		self.oocName:SetPos(10,30)

		if LocalPlayer():IsAdmin() then
			self.rpName = vgui.Create("DLabel", self)
			self.rpName:SetFont("Impulse-Elements18")
			self.rpName:SetText(self.Player:Name())
			self.rpName:SizeToContents()
			self.rpName:SetPos(self.oocName:GetWide() + 15, 42)
		end

		-- team name
		self.teamName = vgui.Create("DLabel", self)
		self.teamName:SetFont("Impulse-Elements23")
		self.teamName:SetText(team.GetName(self.Player:Team()))
		self.teamName:SetTextColor(team.GetColor(self.Player:Team()))
		self.teamName:SizeToContents()
		self.teamName:SetPos(10,60)

		-- buttons
		self.profileButton = vgui.Create("DButton", self)
		self.profileButton:SetText("Steam Profile")
		self.profileButton:SetPos(10,105)
		self.profileButton:SetSize(100,20)
		self.profileButton.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/"..self.Player:SteamID64())
		end

		self.sidButton = vgui.Create("DButton", self)
		self.sidButton:SetText("Copy Steam ID")
		self.sidButton:SetPos(115,105)
		self.sidButton:SetSize(100,20)
		self.sidButton.DoClick = function()
			SetClipboardText(self.Player:SteamID())
		end

		self.forumButton = vgui.Create("DButton", self)
		self.forumButton:SetText("Forum Profile")
		self.forumButton:SetPos(220,105)
		self.forumButton:SetSize(100,20)
		self.forumButton.DoClick = function()
			print("WIP")
		end

		-- badges
		local xShift = 0
		for badgeName, badgeData in pairs(impulse.Badges) do
			if badgeData[3](self.Player) then
				local badge = vgui.Create("DImageButton", self)
				badge:SetPos(10 + xShift, 85)
				badge:SetSize(16, 16)
				badge:SetMaterial(badgeData[1])
				badge.info = badgeData[2]

				function badge:DoClick()
					Derma_Message(badge.info, "impulse", "Close")
				end

				xShift = xShift + 20
	  		end
		end 

		-- usergroup
		self.rank = vgui.Create("DLabel", self)
		self.rank:SetFont("Impulse-Elements18")
		self.rank:SetText("Usergroup: "..self.Player:GetUserGroup())
		self.rank:SizeToContents()
		self.rank:SetPos(10,130)

		-- xp/playtime
		self.playtime = vgui.Create("DLabel", self)
		self.playtime:SetFont("Impulse-Elements18")
		self.playtime:SetText("XP: "..self.Player:GetXP())
		self.playtime:SizeToContents()
		self.playtime:SetPos(10,150)

		-- admin stuff
		if LocalPlayer():IsAdmin() then
			self.adminTools = vgui.Create("DCollapsibleCategory", self)
			self.adminTools:SetPos(10,180)
			self.adminTools:SetSize(400, 150)
			self.adminTools:SetExpanded(0)
			self.adminTools:SetLabel("Admin tools (Click to expand)")

			local colInv = Color(0, 0, 0, 0)
			function self.adminTools:Paint()
				self:SetBGColor(colInv)
			end

			self.adminList = vgui.Create("DIconLayout", self.adminTools)
			self.adminList:Dock(FILL)
			self.adminList:SetSpaceY(5)
			self.adminList:SetSpaceX(5)
		 
		 	for v,k in pairs(quickTools) do
		 		local action = self.adminList:Add("DButton")
			 	action:SetSize(100,30)
			 	action:SetText(k.name)
			 	action.DoClick = function()
			 		LocalPlayer():ConCommand(k.command)
			 	end
				action:SetIcon(k.icon)
			end
		end
	end)

end

function PANEL:SetPlayer(player, badges)
	self.Player = player
	self.Badges = badges
end


vgui.Register("impulsePlayerInfoCard", PANEL, "DFrame")