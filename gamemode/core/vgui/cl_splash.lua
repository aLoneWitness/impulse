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

function PANEL:Paint(w,h)
	surface.SetDrawColor(color_black) -- menu body
	surface.DrawRect(0, 0, w, h)
	draw.DrawText(self.welcomeMessage.." to", "Impulse-Elements27-Shadow", ScrW()/2, 150, color_white, TEXT_ALIGN_CENTER)
	impulse.render.glowgo((ScrW()/2)-168, 200, 337, 91)
	draw.DrawText("Press any key to continue...", "Impulse-Elements27-Shadow", ScrW()/2, 302, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseSplash", PANEL, "DPanel")