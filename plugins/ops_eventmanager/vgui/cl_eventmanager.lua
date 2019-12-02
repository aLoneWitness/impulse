local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 810)
	self:Center()
	self:SetTitle("ops event manager")
	self:MakePopup()

	self.sheet = vgui.Create("DColumnSheet", self)
	self.sheet:Dock(FILL)

	self.seqEdit = vgui.Create("DPanel", self.sheet)
	self.seqEdit:Dock(FILL)

	self.sheet:AddSheet("Seq. Editor", self.seqEdit, "icon16/arrow_branch.png")

	self.seqEdit.menu = vgui.Create("DMenuBar", self.seqEdit)
	self.seqEdit.menu:Dock(TOP)

	local menuFile = self.seqEdit.menu:AddMenu("File")
	menuFile:AddOption("New sequence", function()
		Derma_StringRequest("impulse ops",
			"Enter sequence name:",
			nil, 
			function(text)
				impulse.Ops.EventManager.Sequences[text] = {Name = text, Events = {}, FileName = text}
				self:ReloadSequences()
			end, nil, "Create", "Cancel")
	end)
	menuFile:AddOption("Load sequence")
	menuFile:AddOption("Save all")
	menuFile:AddOption("Close all")

	self:ReloadSequences()

	local seqPlayer = vgui.Create("DPanel", self.sheet)
	seqPlayer:Dock(FILL)
	self.sheet:AddSheet("Seq. Player", seqPlayer, "icon16/control_play_blue.png")

	local scnEdit = vgui.Create("DPanel", self.sheet)
	scnEdit:Dock(FILL)
	self.sheet:AddSheet("Scene Editor", scnEdit, "icon16/camera_go.png")
end

function PANEL:ReloadSequences()
	if self.seqScroll and IsValid(self.seqScroll) then
		self.seqScroll:Remove()
	end

	self.seqScroll = vgui.Create("DScrollPanel", self.seqEdit)
	self.seqScroll:Dock(FILL)

	self.Sequences = {}

	for v,k in pairs(impulse.Ops.EventManager.Sequences) do
		local seqPanel = self.seqScroll:Add("impulseSequenceCard")
		seqPanel:SetSequence(v, k)
		seqPanel:DockMargin(0, 0, 0, 3)
		seqPanel:Dock(TOP)
		seqPanel.Dad = self
	end
end

vgui.Register("impulseEventManager", PANEL, "DFrame")