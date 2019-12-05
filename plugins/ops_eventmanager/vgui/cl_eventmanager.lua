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

	local panel = self

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
	menuFile:AddOption("Load sequence", function()
		local fb = vgui.Create("DFrame")
		fb:SetSize(500, 200)
		fb:SetSizable(true)
		fb:Center()
		fb:MakePopup()
		fb:SetTitle("ops event manager load sequence")

		local browser = vgui.Create("DFileBrowser", fb)
		browser:Dock(FILL)
		browser:SetPath("DATA")
		browser:SetBaseFolder("impulse/ops/eventmanager")
		browser:SetOpen(true)
		browser:SetCurrentFolder("impulse/ops/eventmanager")
		browser:SetFileTypes("*.json")
		browser:SetSearch(true)

		function browser:OnSelect(path)
			local result, msg = impulse.Ops.EventManager.SequenceLoad(path)

			if not result then
				surface.PlaySound("common/bugreporter_failed.wav")
				LocalPlayer():Notify(msg)
				return
			end

			panel:ReloadSequences()

			fb:Remove()
		end
	end)
	menuFile:AddOption("Save all", function()
		for v,k in pairs(impulse.Ops.EventManager.Sequences) do
			impulse.Ops.EventManager.SequenceSave(v)
		end

		LocalPlayer():Notify("All sequences saved.")
	end)
	menuFile:AddOption("Close all", function()
		impulse.Ops.EventManager.Sequences = {}
		panel:ReloadSequences()

		LocalPlayer():Notify("All sequences closed.")
	end)

	self:ReloadSequences()

	self.seqPlayer = vgui.Create("DPanel", self.sheet)
	self.seqPlayer:Dock(FILL)
	self.sheet:AddSheet("Seq. Player", self.seqPlayer, "icon16/control_play_blue.png")

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

function PANEL:SetupPlayer(sequences)
	local scroll = vgui.Create("DScrollPanel", self.seqPlayer)
	scroll:Dock(FILL)

	for v,k in pairs(sequences) do
		local sequence = scroll:Add("DPanel")
		sequence:SetTall(35)
		sequence:Dock(TOP)
		sequence:DockMargin(0, 0, 0, 3)

		local normal = Color(90, 90, 90, 255)
		function sequence:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, normal)

			if impulse.Ops.EventManager.GetSequence() == self:GetText() then
				draw.SimpleText("LIVE", "ChatFont", 6, 16, Color(255, 0, 0))
			end
		end

		local name = vgui.Create("DLabel", sequence)
		name:SetText(k)
		name:SizeToContents()
		name:SetPos(5, 5)

		local play = vgui.Create("DButton", sequence)
		play:SetPos(500, 0)
		play:SetSize(150, 35)
		play:SetText("PLAY")
	end
end

vgui.Register("impulseEventManager", PANEL, "DFrame")