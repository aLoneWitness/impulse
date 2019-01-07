local PANEL = {}

function PANEL:Init()
	self:SetSize(SizeW(900), SizeH(900))
	self:Center()
	self:SetTitle("Scoreboard")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	self:MakePopup()
 	self:MoveToFront()

 	self.scrollPanel = vgui.Create("DScrollPanel", self)
	self.scrollPanel:Dock(FILL)

	for v,k in pairs(player.GetAll()) do
		local playerCard = self.scrollPanel:Add("impulseScoreboardCard")
		playerCard:SetPlayer(k)
		playerCard:SetHeight(60)
		playerCard:Dock(TOP)
		playerCard:DockMargin(0,0,0,0)
	end

end


vgui.Register("impulseScoreboard", PANEL, "DFrame")
