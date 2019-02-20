local PANEL = {}

function PANEL:Init()
	if IsValid(impulse.MainMenu) then
		impulse.MainMenu:Remove()
	end
	impulse.MainMenu = self
	impulse.hudEnabled = false

	self:SetPos(0,0)
	self:SetSize(ScrW(), ScrH())
	self:MakePopup()
	self:SetPopupStayAtBack(true)

	local button = vgui.Create("DButton", self)
	button:SetPos(100,200)
	button:SetFont("Impulse-Elements48")
	button:SetText("Play")
	button:SizeToContents()

	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	local selfPanel = self
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	function button:DoClick()
		surface.PlaySound("ui/buttonclick.wav")
		if impulse_isNewPlayer == true then
			vgui.Create("impulseCharacterCreator", selfPanel)
		elseif not impulse.MainMenu.popup then
			LocalPlayer():ScreenFade(SCREENFADE.OUT, color_black, 1, .6)
			impulse.MainMenu:AlphaTo(0, .5)
			LocalPlayer().defaultModel = LocalPlayer():GetModel()
			LocalPlayer().defaultSkin = LocalPlayer():GetSkin()
			timer.Simple(1.5, function()
    			LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 4, 0)
    			selfPanel:Remove()
				impulse.hudEnabled = true
			end)
		else
			selfPanel:Remove()
			impulse.hudEnabled = true
		end
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,250)
	button:SetFont("Impulse-Elements32")
	button:SetText("Settings")
	button:SizeToContents()

	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	function button:DoClick()
		surface.PlaySound("ui/buttonclick.wav")
		vgui.Create("impulseSettings", selfPanel)
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,280)
	button:SetFont("Impulse-Elements32")
	button:SetText("Community")
	button:SizeToContents()

	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,310)
	button:SetFont("Impulse-Elements32")
	button:SetText("Donate")
	button:SizeToContents()

	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	local goldCol = Color(218, 165, 32)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(goldCol)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,ScrH()-200)
	button:SetFont("Impulse-Elements32")
	button:SetText("Disconnect")
	button:SizeToContents()

	local normalCol = button:GetColor()
	local highlightCol = Color(240, 0, 0)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	function button:DoClick()
		print("Bye. :(")
		LocalPlayer():ConCommand("disconnect")
	end

	local year = os.date("%Y", os.time())
	local copyrightLabel = vgui.Create("DLabel", self)
	copyrightLabel:SetFont("Impulse-Elements14")
	copyrightLabel:SetText("Powered by impulse\nCopyright vin "..year.."\nimpulse version: "..IMPULSE.Version)
	copyrightLabel:SizeToContents()
	copyrightLabel:SetPos(ScrW()-copyrightLabel:GetWide(), ScrH()-copyrightLabel:GetTall()-5)

	local schemaLabel = vgui.Create("DLabel", self)
	schemaLabel:SetFont("Impulse-Elements32")
	schemaLabel:SetText(impulse.Config.SchemaName)
	--schemaLabel:SetTextColor(Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)) not sure if i like this
	schemaLabel:SizeToContents()
	schemaLabel:SetPos(100,140)

	local newsLabel = vgui.Create("DLabel", self)
	newsLabel:SetFont("Impulse-Elements32")
	newsLabel:SetText("News")
	newsLabel:SizeToContents()
	newsLabel:SetPos(self:GetWide()-530, 60)

	local newsfeed = vgui.Create("impulseNewsfeed", self)
	newsfeed:SetSize(500,270)
	newsfeed:SetPos(self:GetWide()-530, 100)

	timer.Simple(0, function()
		if not impulse.MainMenu.popup and impulse.GetSetting("perf_mcore") == false then
			Derma_Query("Would you like to enable Multi-core rendering? This will improve your FPS by about 60FPS, however if your computer has a low core count and/or a small amount of RAM it can cause crashes and performance problems.",
				"impulse",
				"Enable Multi-core rendering",
				function()
					impulse.SetSetting("perf_mcore", true)
				end,
				"No thanks")
		end
	end)
end

PANEL.FullRemove = PANEL.Remove 
function PANEL:Remove()
	self:SetVisible(false)
end

function PANEL:OnChildAdded(child)
	if IsValid(self.openElement) then
		self.openElement:Remove()
	end
	self.openElement = child
end

local bodyCol = Color(30, 30, 30, 190)
function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur(self)

	surface.SetDrawColor(bodyCol) -- menu body
	surface.DrawRect(70,0,400,h) -- left body
	surface.DrawRect(w-540,0,520,380)-- news body
	impulse.render.glowgo(100,50,337,91)
end

vgui.Register("impulseMainMenu", PANEL, "DPanel")