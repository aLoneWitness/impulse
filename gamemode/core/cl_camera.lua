function IMPULSE:CalcView(player, origin, angles, fov)
	local view

	if IsValid(impulse.MainMenu) and not impulse.MainMenu.popup then
		view = {
			origin = impulse.Config.MenuCamPos,
			angles = impulse.Config.MenuCamAng,
			fov = 70
		}
		return view
	end
	
	local ragdoll = player:GetRagdollEntity();

	if( !ragdoll || ragdoll == NULL || !ragdoll:IsValid() ) then return; end

	local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
	view = {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = 70,
	};

	return view
end
