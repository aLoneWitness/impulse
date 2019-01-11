function IMPULSE:PlayerInitialSpawn()
	
end

function IMPULSE:PlayerLoadout(player)
	player:SetRunSpeed(impulse.Config.JogSpeed)
	player:SetWalkSpeed(impulse.Config.WalkSpeed)

	return true
end

function IMPULSE:ShowHelp()
	
end