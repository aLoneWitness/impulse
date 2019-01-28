local KEY_BLACKLIST = IN_ATTACK + IN_ATTACK2

function IMPULSE:StartCommand(ply, command)
	local weapon = ply:GetActiveWeapon()

	if not ply:IsWeaponRaised() then
		command:RemoveKey(KEY_BLACKLIST)
	end
end

function IMPULSE:PlayerSwitchWeapon(ply, oldWep, newWep)
	if SERVER then
		ply:SetWeaponRaised(false)
	end
end