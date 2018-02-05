function IMPULSE:CalcView(player, origin, angles, fov)
	local ragdoll = player:GetRagdollEntity();

	if( !ragdoll || ragdoll == NULL || !ragdoll:IsValid() ) then return; end

	local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
	local view = {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = 70,
	};

	return view
end
