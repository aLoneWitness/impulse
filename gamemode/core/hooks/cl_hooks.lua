function IMPULSE:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseSplash")
	end
end

function IMPULSE:Think()
	if input.IsKeyDown(KEY_F1) and not IsValid(impulse.MainMenu) then
		local mainMenu = vgui.Create("impulseMainMenu")
		mainMenu:SetAlpha(0)
		mainMenu:AlphaTo(255, .3)
		mainMenu.popup = true
	end
end

function IMPULSE:ScoreboardShow()
    impulse_scoreboard = vgui.Create("impulseScoreboard")
end

function IMPULSE:ScoreboardHide()
    impulse_scoreboard:Remove()
end