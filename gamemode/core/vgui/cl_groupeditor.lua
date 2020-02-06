local PANEL = {}

function PANEL:Init()
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("Group Menu")
	self:MakePopup()

	local panel = self

	local darkText = Color(150, 150, 150, 210)
	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("You are not a member of a group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(60)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Once you get invited to a group you'll be able to accept the invite here.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Create a new group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(90)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Creating a new group will cost "..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost.." and will require at least "..impulse.Config.GroupXPRequirement.."XP.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local newGroup = vgui.Create("DButton", self)
	newGroup:SetTall(25)
	newGroup:SetWide(300)
	newGroup:SetText("Create new group ("..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost..")")
	newGroup:DockMargin(160, 0, 160, 0)
	newGroup:Dock(TOP)
end


vgui.Register("impulseGroupEditor", PANEL, "DFrame")