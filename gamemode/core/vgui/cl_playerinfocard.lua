local PANEL = {}

local nextSG = 0
local quickTools = {
	{
		name = "Goto",
		icon = "icon16/arrow_right.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /goto "..sid)
		end
	},
	{
		name = "Bring",
		icon = "icon16/arrow_inout.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /bring "..sid)
		end
	},
	{
		name = "Respawn",
		icon = "icon16/arrow_refresh.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /respawn "..sid)
		end
	},
	{
		name = "Unarrest",
		icon = "icon16/lock_open.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /unarrest "..sid)
		end
	},
	{
		name = "Name change",
		icon = "icon16/textfield_rename.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /forcenamechange "..sid)
		end
	},
	{
		name = "Set team",
		icon = "icon16/group_edit.png",
		onRun = function(ply, sid)
			local teams = DermaMenu()
			for v,k in pairs(impulse.Teams.Data) do
				teams:AddOption(k.name, function()
					LocalPlayer():ConCommand("say /setteam "..sid.." "..v)
				end)
			end

			teams:Open()
		end
	},
	{
		name = "View inventory",
		icon = "icon16/magnifier.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /viewinv "..sid)
		end
	},
	{
		name = "View record",
		icon = "icon16/folder_magnify.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /viewrecord "..sid)
		end
	},
	{
		name = "OOC timeout",
		icon = "icon16/sound_add.png",
		onRun = function(ply, sid)
			Derma_StringRequest("impulse", "Enter the timeout length (in minutes):", "10", function(length)
				LocalPlayer():ConCommand("say /ooctimeout "..sid.." "..length)
			end)
		end
	},
	{
		name = "Un-OOC timeout",
		icon = "icon16/sound_delete.png",
		onRun = function(ply, sid)
			LocalPlayer():ConCommand("say /unooctimeout "..sid)
		end
	},
	{
		name = "Screengrab",
		icon = "icon16/camera.png",
		onRun = function(ply, id)
			if nextSG > CurTime() then
				ply:Notify("Slow down!")
				return
			end

			nextSG = CurTime() + 10

			OpenSGMenu()

			LocalPlayer().parts = nil
			LocalPlayer().len = nil
			LocalPlayer().StartTime = nil
			LocalPlayer().gfname = nil
			LocalPlayer().sgtable = nil

			ScreengrabProgressReset()

			timer.Simple(0.1, function()
				net.Start("ScreengrabRequest")
					net.WriteEntity(ply)
					net.WriteUInt(40, 32)
				net.SendToServer()
				LocalPlayer().InProgress = true
			end)
		end
	},
	{
		name = "Cleanup Props",
		icon = "icon16/building_delete.png",
		onRun = function(ply, sid)
			Derma_Query("Are you sure you want to cleanup the props of:\n"..ply:Nick().."("..ply:SteamName()..")?", "ops", "Yes", function()
				LocalPlayer():ConCommand("say /cleanup "..sid)
			end, "No, take me back!")
		end
	},
	{
		name = "Warn",
		icon = "icon16/error_add.png",
		onRun = function(ply, sid)
			Derma_StringRequest("impulse", "Enter the reason:", "", function(reason)
				LocalPlayer():ConCommand("say /warn "..sid.." "..reason)
			end)
		end
	},
	{
		name = "Kick",
		icon = "icon16/user_go.png",
		onRun = function(ply, sid)
			Derma_StringRequest("impulse", "Enter the reason:", "Violation of community guidelines", function(reason)
				LocalPlayer():ConCommand("say /kick "..sid.." "..reason)
			end)
		end
	},
	{
		name = "Ban",
		icon = "icon16/user_delete.png",
		onRun = function(ply, sid)
			Derma_StringRequest("impulse", "Enter the length (in minutes):", "", function(length)
				LocalPlayer():ConCommand("say /ban "..sid.." "..reason)
			end)
		end
	}
}


function PANEL:Init()
	self:Hide()
	timer.Simple(0, function() -- Time to allow SetPlayer to catch up
		self:Show()
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

		self.profileImage = vgui.Create("AvatarImage", self)
		self.profileImage:SetSize(70, 70)
		self.profileImage:SetPos(10, 30)
		self.profileImage:SetPlayer(self.Player, 64)

		-- Steam name
		self.oocName = vgui.Create("DLabel", self)
		self.oocName:SetFont("Impulse-CharacterInfo-NO")
		self.oocName:SetText(self.Player:SteamName())
		self.oocName:SizeToContents()
		self.oocName:SetPos(86,30)

		if LocalPlayer():IsAdmin() then
			self.rpName = vgui.Create("DLabel", self)
			self.rpName:SetFont("Impulse-Elements18")
			self.rpName:SetText(self.Player:Name())
			self.rpName:SizeToContents()
			self.rpName:SetPos(self.oocName:GetWide() + 88, 42)
		end

		-- team name
		self.teamName = vgui.Create("DLabel", self)
		self.teamName:SetFont("Impulse-Elements23")
		self.teamName:SetText(team.GetName(self.Player:Team()))
		self.teamName:SetTextColor(team.GetColor(self.Player:Team()))
		self.teamName:SizeToContents()
		self.teamName:SetPos(86,60)

		-- buttons
		self.profileButton = vgui.Create("DButton", self)
		self.profileButton:SetText("Steam Profile")
		self.profileButton:SetPos(10,105)
		self.profileButton:SetSize(90,20)
		self.profileButton.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/"..self.Player:SteamID64())
		end

		self.sidButton = vgui.Create("DButton", self)
		self.sidButton:SetText("Copy Steam ID")
		self.sidButton:SetPos(105,105)
		self.sidButton:SetSize(90,20)
		self.sidButton.DoClick = function()
			SetClipboardText(self.Player:SteamID())
		end

		self.forumButton = vgui.Create("DButton", self)
		self.forumButton:SetText("Panel Profile")
		self.forumButton:SetPos(200,105)
		self.forumButton:SetSize(90,20)
		self.forumButton.DoClick = function()
			gui.OpenURL("https://panel.impulse-community.com/index.php?t=user&id="..self.Player:SteamID64())
		end

		self.whitelistButton = vgui.Create("DButton", self)
		self.whitelistButton:SetText("Whitelists")
		self.whitelistButton:SetPos(295, 105)
		self.whitelistButton:SetSize(90, 20)
		self.whitelistButton.DoClick = function()
			if not IsValid(self.Player) then
				return
			end

			if (LocalPlayer().nextWhitelistReq or 0) > CurTime() then return LocalPlayer():Notify("Please wait 5 seconds before making another whitelist request.") end
			LocalPlayer().nextWhitelistReq = CurTime() + 5

			impulse_WhitelistReqTarg = self.Player

			net.Start("impulseRequestWhitelists")
			net.WriteUInt(self.Player:EntIndex(), 8)
			net.SendToServer()
		end

		-- badges
		local xShift = 0
		for badgeName, badgeData in pairs(impulse.Badges) do
			if badgeData[3](self.Player) then
				local badge = vgui.Create("DImageButton", self)
				badge:SetPos(86 + xShift, 84)
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
		self.rank:SetFont("Impulse-Elements18-Shadow")
		self.rank:SetText("Usergroup: "..self.Player:GetUserGroup())
		self.rank:SizeToContents()
		self.rank:SetPos(10,130)

		-- xp/playtime
		self.playtime = vgui.Create("DLabel", self)
		self.playtime:SetFont("Impulse-Elements18-Shadow")
		self.playtime:SetText("XP: "..self.Player:GetXP())
		self.playtime:SizeToContents()
		self.playtime:SetPos(10,150)

		-- admin stuff
		if LocalPlayer():IsAdmin() then
			self.adminTools = vgui.Create("DCollapsibleCategory", self)
			self.adminTools:SetPos(10,180)
			self.adminTools:SetSize(400, 250)
			self.adminTools:SetExpanded(0)
			self.adminTools:SetLabel("Admin tools (click to expand)")

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
			 	action:SetSize(125,30)
			 	action:SetText(k.name)
			 	action:SetIcon(k.icon)

			 	action.runFunc = k.onRun
				local target = self.Player
			 	function action:DoClick()
			 		if not IsValid(target) then return LocalPlayer():Notify("This player has disconnected.") end
			 		self.runFunc(target, target:SteamID())
			 	end
			end
		end
	end)

end

function PANEL:SetPlayer(player, badges)
	self.Player = player
	self.Badges = badges
end


vgui.Register("impulsePlayerInfoCard", PANEL, "DFrame")