local PANEL = {}

function PANEL:Init()
	self.colour = Color(60,255,105,150)
	self.name = "error"
	self:SetCursor("hand")
end

function PANEL:SetTeam(teamID)
	self.colour = team.GetColor(teamID)
	self.name = team.GetName(teamID)
	self.players = #team.GetPlayers(teamID)
	self.playerCount = self.players
	self.model = LocalPlayer().defaultModel or "models/Humans/Group01/male_02.mdl" 
	self.skin = LocalPlayer().defaultSkin or 0
	self.requirements = ""
	local teamData = impulse.Teams.Data[teamID]

	if teamData.limit then
		if teamData.percentLimit and teamData.percentLimit == true then
			self.playerCount = self.players.."/"..math.ceil((self.players / #player.GetAll()))
		else
			self.playerCount = self.players.."/"..teamData.limit
		end
	end

	if teamData.model then
		self.model = teamData.model
		self.skin = 0
	end

	if teamData.xp > 0 then
		self.requirements = teamData.xp.."XP"
	end

	if teamData.donatorOnly and teamData.donatorOnly == true then
		self.requirements = self.requirements.." (Donator only)"
	end

 	self.modelIcon = vgui.Create("SpawnIcon", self)
	self.modelIcon:SetPos(10,4)
	self.modelIcon:SetSize(52,52)
	self.modelIcon:SetModel(self.model, self.skin)
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
	surface.SetDrawColor(self.colour)
 	surface.SetMaterial(gradient)
 	surface.DrawTexturedRect(1,1,w-1,h-2)
	surface.SetDrawColor(darkCol)
 	surface.DrawTexturedRect(1,1,w-1,h-2)

	-- team name
	surface.SetFont("Impulse-Elements20-Shadow")
	surface.SetTextColor(color_white)
	surface.SetTextPos(65,10)
	surface.DrawText(self.name)

	-- team requirements
	surface.SetTextPos(65,25)
	surface.DrawText(self.requirements)

	 -- team size
	surface.SetTextPos(w-30,10)
	surface.DrawText(self.playerCount)
end

vgui.Register("impulseTeamCard", PANEL, "DPanel")