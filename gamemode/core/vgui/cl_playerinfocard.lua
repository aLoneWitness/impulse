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
		self.characterPreview = vgui.Create("DModelPanel", self)
		self.characterPreview:SetSize(600,400)
		self.characterPreview:SetPos(200,30)
		self.characterPreview:SetFOV(80)
		self.characterPreview:SetModel(self.Player:GetModel())
		self.characterPreview:MoveToBack()
		self.characterPreview:SetCursor("arrow")
		--local charPreview = self.characterPreview
		function self.characterPreview:LayoutEntity(ent) 
			--ent:SetSequence(ent:LookupSequence("idle"))
			ent:SetAngles(Angle(0,40,0))
			--charPreview:RunAnimation()
		end
		
		-- Steam name
		self.oocName = vgui.Create("DLabel", self)
		self.oocName:SetFont("Impulse-CharacterInfo-NO")
		self.oocName:SetText(self.Player:SteamName())
		self.oocName:SizeToContents()
		self.oocName:SetPos(10,30)

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
		for badgeName, conditionMet in pairs(self.Badges) do
			if conditionMet == true then
				local badge = vgui.Create("DImage", self)
				badge:SetPos(10+xShift,85)
				badge:SetSize(16,16)
				badge:SetMaterial(scoreboardBadgesData[badgeName][1])
				--badge:SetTooltip(scoreboardBadgesData[badgeName][2]) does not seem to work :/
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
		self.playtime:SetText("Playtime: ".."1hr")
		self.playtime:SizeToContents()
		self.playtime:SetPos(10,150)

		-- admin stuff
		self.adminTools = vgui.Create("DCollapsibleCategory", self)
		self.adminTools:SetPos(10,180)
		self.adminTools:SetSize(400, 150)
		self.adminTools:SetExpanded(0)
		self.adminTools:SetLabel("Admin tools (Click to expand)")

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
	end)

end

function PANEL:SetPlayer(player, badges)
	self.Player = player
	self.Badges = badges
end


vgui.Register("impulsePlayerInfoCard", PANEL, "DFrame")