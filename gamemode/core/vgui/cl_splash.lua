local PANEL = {}

function PANEL:Init()
	impulse.hudEnabled = false

	self:SetPos(0,0)
	self:SetSize(ScrW(), ScrH())
	self:MakePopup()
	self:SetPopupStayAtBack(true)
	self.welcomeMessage = "Welcome"

	impulse.splash = self
end

function PANEL:OnKeyCodeReleased()
	if self.used then return end
	
	impulse.hudEnabled = true
	self.used = true
	impulse_IsReady = true
	self:AlphaTo(0, 2, 0, function()
		self:Remove()
	end)

	hook.Run("PostReloadToolsMenu")

	if impulse_isNewPlayer or (cookie.GetString("impulse_em_do_intro") or "") == "true" then
		if (cookie.GetString("impulse_em_do_intro") or "") == "true" then
			cookie.Delete("impulse_em_do_intro")	
		end

		impulse.Scenes.PlaySet(impulse.Config.IntroScenes, impulse.Config.IntroMusic, function()
			local mainMenu = vgui.Create("impulseMainMenu")
			mainMenu:SetAlpha(0)
			mainMenu:AlphaTo(255, 1)
		end)

		net.Start("impulseOpsEMIntroCookie")
		net.SendToServer()
	else
		vgui.Create("impulseMainMenu")
	end
end

function PANEL:OnMousePressed()
	self:OnKeyCodeReleased()
end

local splashCol = Color(200, 200, 200, 150)
function PANEL:Paint(w,h)
	--impulse.blur(self, 10, 20, 255)
	Derma_DrawBackgroundBlur(self)
	--surface.SetDrawColor(color_black) -- menu body
	--surface.DrawRect(0, 0, w, h)

	local x = w * .5
	local y = h * .4
	local logo_scale = 1.1
	local logo_w = logo_scale * 367
	local logo_h = logo_scale * 99
	--draw.DrawText(self.welcomeMessage.." to", "Impulse-Elements27-Shadow", ScrW()/2, 150, color_white, TEXT_ALIGN_CENTER)
	impulse.render.glowgo(x - (logo_w * .5), y, logo_w, logo_h)
	draw.DrawText("press any key to continue", "Impulse-Elements27-Shadow", x, y + logo_h + 40, splashCol, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseSplash", PANEL, "DPanel")