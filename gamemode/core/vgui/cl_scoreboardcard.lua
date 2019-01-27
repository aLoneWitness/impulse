local PANEL = {}

scoreboardBadgesData = {
	staff = {Material("icon16/shield.png"), "This player is a staff member."},
	donator = {Material("icon16/coins.png"), "This player is a donator."},
	dev = {Material("icon16/cog.png"), "This player is a developer."}
}

function PANEL:Init()
	self.Colour = Color(60,255,105,150)
	self.Name = "Connecting..."
	self.Ping = 0
	self:SetCursor("hand")
	self:SetTooltip("Left click to open info card. Right click to copy SteamID.")
end

function PANEL:SetPlayer(player)
	self.Colour = team.GetColor(player:Team()) -- Store colour and name micro optomization, other things can be calculated on the go.
	self.Name = player:Nick()
	self.Player = player
	self.Badges = {
		staff = player:IsAdmin(),
		donator = player:IsDonator(),
		dev = player:IsDeveloper()
 	}

 	self.modelIcon = vgui.Create("SpawnIcon", self)
	self.modelIcon:SetPos(10,4)
	self.modelIcon:SetSize(52,52)
	self.modelIcon:SetModel(player:GetModel(), player:GetSkin())
	self.modelIcon:SetTooltip(false)
	self.modelIcon:SetDisabled(true)
	self.modelIcon:SetDrawBorder(false)
	function self.modelIcon:PaintOver() -- remove that mouse hover effect
		return false
	end
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

	 -- OOC/IC name
	 surface.SetFont("Impulse-Elements20-Shadow")
	 surface.SetTextColor(color_white)
	 surface.SetTextPos(65,10)

	 local icName = ""
	 if LocalPlayer():IsAdmin() then 
	 	icName = " ("..self.Player:Name()..")"
	 end
	 surface.DrawText(self.Player:SteamName()..icName)

	 -- Ping
	 surface.SetTextPos(w-30,10)
	 surface.DrawText(self.Player:Ping())

	 -- Team name
	 surface.SetFont("Impulse-Elements18-Shadow")
	 surface.SetTextPos(65,30)
	 surface.DrawText(team.GetName(self.Player:Team()))
	 
	 -- Badges 
	 surface.SetDrawColor(color_white)

	local xShift = 0
	for badgeName, conditionMet in pairs(self.Badges) do
		if conditionMet == true then
			surface.SetMaterial(scoreboardBadgesData[badgeName][1])
			surface.DrawTexturedRect(w-34-xShift,30,16,16)
			xShift = xShift + 20
	  end
	end 
end
function PANEL:OnMousePressed()
	local infoCard = vgui.Create("impulsePlayerInfoCard")
	infoCard:SetPlayer(self.Player, self.Badges)
end

vgui.Register("impulseScoreboardCard", PANEL, "DPanel")