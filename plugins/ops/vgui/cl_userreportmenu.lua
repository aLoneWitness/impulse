local PANEL = {}

function PANEL:Init()
	self:SetSize(605, 470)
	self:Center()
	self:SetTitle("Reports")
	self:MakePopup()

	self:SetupUI()
end

function PANEL:SetupUI()
	self.title = vgui.Create("DLabel", self)
	self.title:SetFont("Impulse-Elements27-Shadow")
	self.title:SetPos(10, 30)
	self.title:SetText("Submit a report")
	self.title:SizeToContents()

	self.log = vgui.Create("DScrollPanel", self)
	self.log:SetPos(10, 60)
	self.log:SetSize(585, 290)
	self.log:GetVBar():AnimateTo(1000000, 0)

	for i=0, 100 do
		local DButton = self.log:Add( "DButton" )
		DButton:SetText( "Button #" .. i )
		DButton:Dock( TOP )
		DButton:DockMargin( 0, 0, 0, 5 )
	end

	local lbl = vgui.Create("DLabel", self)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetPos(10, 355)
	lbl:SetText("Message:")
	lbl:SizeToContents()

	self.entry = vgui.Create("DTextEntry", self)
	self.entry:SetPos(10, 375)
	self.entry:SetSize(585, 50)
	self.entry:SetMultiline(true)
	self.entry:SetEnterAllowed(false)
	self.entry:SetFont("Impulse-Elements16")

	self.sendBtn = vgui.Create("DButton", self)
	self.sendBtn:SetPos(10, 430)
	self.sendBtn:SetSize(130, 30)
	self.sendBtn:SetText("Submit")
end

vgui.Register("impulseUserReportMenu", PANEL, "DFrame")