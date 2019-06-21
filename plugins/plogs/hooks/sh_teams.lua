plogs.Register('Teams', false)

plogs.AddHook("OnPlayerChangedTeam", function(ply, oldTeam, newTeam)
	plogs.PlayerLog(ply, 'Teams', ply:NameID().." changed to team "..team.GetName(newTeam).." from "..team.GetName(oldTeam), {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID()
	})
end)

plogs.AddHook("PlayerChangeClass", function(ply, id, name)
	plogs.PlayerLog(ply, 'Teams', ply:NameID().." ("..team.GetName(ply:Team())..") changed to class "..name, {
		['Name'] 	= ply:Name(),
		['SteamID']	= ply:SteamID()
	})
end)