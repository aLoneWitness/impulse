function IMPULSE:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseMainMenu")
	end
end

function IMPULSE:Think()
	if input.IsKeyDown(KEY_F1) and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseMainMenu")
	end
end