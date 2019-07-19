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

	function button:DoClick()
		surface.PlaySound("ui/buttonclick.wav")
		gui.OpenURL(impulse.Config.CommunityURL or "www.google.com")
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,310)
	button:SetFont("Impulse-Elements32")
	button:SetText("Donate")
	button:SizeToContents()

	local normalCol = button:GetColor()
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

	function button:DoClick()
		surface.PlaySound("ui/buttonclick.wav")
		gui.OpenURL(impulse.Config.DonateURL or "www.google.com")
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,ScrH()-230)
	button:SetFont("Impulse-Elements32")
	button:SetText("Credits")
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

	local mainmenu = self
	function button:DoClick()
		if self.popup then return end
		if impulseCredits and IsValid(impulseCredits) then return end
		
		impulseCredits = vgui.Create("impulseCredits")
		impulseCredits:AlphaTo(255, 2, 1.5)
		mainmenu:AlphaTo(0, 2, 0)
	end

	function button:Think()
		if impulse.MainMenu.popup then
			self:Hide()
		else
			self:Show()
		end
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

	local button = vgui.Create("DImageButton", self)
	button:SetPos(self:GetWide() - 30 - 53, 385)
	button:SetImage("impulse/icons/social/discord.png")
	button:SetSize(62, 55)

	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(normalCol)
		end
	end

	function button:OnCursorEntered()
		surface.PlaySound("ui/buttonrollover.wav")
	end

	function button:DoClick()
		surface.PlaySound("ui/buttonclick.wav")
		gui.OpenURL(impulse.Config.DiscordURL or "www.viniscool.com")
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

	local testMessage = function()
		Derma_Message([[Welcome to the impulse test server!
			Thanks for coming along and helping us test impulse, before we start though
			let's get some stuff out the way, please take your time to read the text below:

			- This is NOWHERE NEAR A FINAL VERSION of impulse. We still have to add many features 
			such as the inventory and crafting system.
			- Bugs, expect lot's of them, this is a test, not a live server.
			- Roleplay, don't expect much roleplay at this early stage in testing.
			- Don't go around killing people randomly or prop spamming. This is not testing,
			it is just making it harder for others to give impulse a go.
			- Footage and sharing stuff - Sure, you can record and screenshot whatever you
			like. Just leave the watermark in the image/video.

			- SUPER COOL TESTER BADGE! - We've got a couple of 'SUPER COOL TESTER BADGES' to
			give out to the best testers, so get testing. 

			REPORT BUGS/FEEDBACK TO: https://github.com/vingard/impulse-issues/issues

			Happy bug hunting!
			-vin]], "impulse", "Uh huh")
	end

	timer.Simple(0, function()
		if impulse.MainMenu.popup then return end

		if not steamworks.IsSubscribed("1651398810") then
			Derma_Query("You are not subscribed to the impulse framework content!\nIf you do not subscribe you will experience missing textures and errors.\nAfter subscribing, rejoin the server.",
				"impulse",
				"Subscribe",
				function()
					gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1651398810")
				end,
				"No thanks")
		end
		
		if impulse.GetSetting("perf_mcore") == false then
			Derma_Query("Would you like to enable Multi-core rendering?\nThis will often greatly improve your FPS, however if your computer has a low core count and/or\na small amount of RAM, it can cause crashes and performance problems.",
				"impulse",
				"Enable Multi-core rendering",
				function()
					impulse.SetSetting("perf_mcore", true)
					testMessage()
				end,
				"No thanks")
		else
			testMessage()
		end
	end)
end

local fullRemove = PANEL.Remove 
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

	draw.SimpleText("beta", "Impulse-SpecialFont", 370, 120, Color(170, 170, 170))
end

vgui.Register("impulseMainMenu", PANEL, "DPanel")