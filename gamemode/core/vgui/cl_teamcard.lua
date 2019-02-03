local PANEL = {}

function PANEL:Init()
	self.Colour = Color(60,255,105,150)
	self.Name = "error"
	self:SetCursor("hand")
end

function PANEL:SetTeam(teamID)
	self.Colour = team.GetColor(teamID)
	self.Name = team.GetName(teamID)
	self.Players = #team.GetPlayers(teamID)
	self.PlayerCount = self.Players
	self.Model = LocalPlayer():GetModel()
	self.Skin = LocalPlayer():GetSkin()
	local teamData = impulse.Teams.Data[teamID]

	if teamData.limit then
		if teamData.percentLimit and teamData.percentLimit == true then
			self.PlayerCount = self.Players.."/"..(self.Players / #player.GetAll())
		else
			self.PlayersCount = self.Players.."/"..teamData.limit
		end
	end

	if teamData.model then
		self.Model = teamData.model
		self.Skin = 0
	end

 	self.modelIcon = vgui.Create("SpawnIcon", self)
	self.modelIcon:SetPos(10,4)
	self.modelIcon:SetSize(52,52)
	self.modelIcon:SetModel(self.Model, self.Skin)
	self.modelIcon:SetTooltip(false)
	self.modelIcon:SetDisabled(true)
	self.modelIcon:SetDrawBorder(false)
end

local gradient = Material("vgui/gradient-l")
local outlineCol = Color(190,190,190,240)
local darkCol = Color(30,30,30,200)

function PANEL:Paint(w,h)
	-- Frame
	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0,0,w, h)
	surface.SetDrawColor(self.Colour)
 	surface.SetMaterial(gradient)
 	surface.DrawTexturedRect(1,1,w-1,h-2)
	surface.SetDrawColor(darkCol)
 	surface.DrawTexturedRect(1,1,w-1,h-2)

	-- team name
	surface.SetFont("Impulse-Elements20-Shadow")
	surface.SetTextColor(color_white)
	surface.SetTextPos(65,10)
	surface.DrawText(self.Name)

	 -- team size
	surface.SetTextPos(w-30,10)
	surface.DrawText(self.PlayerCount)
end

vgui.Register("impulseTeamCard", PANEL, "DPanel")