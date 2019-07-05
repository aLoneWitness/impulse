local PANEL = {}

function PANEL:Init()
	impulse.hudEnabled = false

	self:SetPos(0,0)
	self:SetSize(ScrW(), ScrH())
	self:MakePopup()
	self:SetPopupStayAtBack(true)
	self.welcomeMessage = "Welcome"
end

function PANEL:OnKeyCodeReleased()
	if self.used then return end
	
	impulse.hudEnabled = true
	self.used = true
	self:AlphaTo(0, 2, 0, function()
		self:Remove()
	end)

	IMPULSE:PostReloadToolsMenu()

	if impulse_isNewPlayer == true then
		local counter = 1
		local function playIntroScenes()
			if impulse.Config.IntroScenes[counter + 1] then
				counter = counter + 1
				impulse.Scenes.Play(counter, impulse.Config.IntroScenes[counter], playIntroScenes)
			else
				local mainMenu = vgui.Create("impulseMainMenu")
				mainMenu:SetAlpha(0)
				mainMenu:AlphaTo(255, 1)
			end
		end

		impulse.Scenes.Play(1, impulse.Config.IntroScenes[counter], playIntroScenes)
		surface.PlaySound(impulse.Config.IntroMusic)
	else
		vgui.Create("impulseMainMenu")
	end
end

function PANEL:OnMousePressed()
	if self.used then return end
	
	impulse.hudEnabled = true
	self.used = true
	self:AlphaTo(0, 2, 0, function()
		self:Remove()
	end)
	if impulse_isNewPlayer == true then
		local counter = 1
		local function playIntroScenes()
			if impulse.Config.IntroScenes[counter + 1] then
				counter = counter + 1
				impulse.Scenes.Play(counter, impulse.Config.IntroScenes[counter], playIntroScenes)
			else
				local mainMenu = vgui.Create("impulseMainMenu")
				mainMenu:SetAlpha(0)
				mainMenu:AlphaTo(255, 1)
			end
		end

		impulse.Scenes.Play(1, impulse.Config.IntroScenes[counter], playIntroScenes)
		surface.PlaySound(impulse.Config.IntroMusic)
	else
		vgui.Create("impulseMainMenu")
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(color_black) -- menu body
	surface.DrawRect(0, 0, w, h)
	draw.DrawText(self.welcomeMessage.." to", "Impulse-Elements27-Shadow", ScrW()/2, 150, color_white, TEXT_ALIGN_CENTER)
	impulse.render.glowgo((ScrW()/2)-168, 200, 337, 91)
	draw.DrawText("Press any key to continue...", "Impulse-Elements27-Shadow", ScrW()/2, 302, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseSplash", PANEL, "DPanel")