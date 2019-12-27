util.AddNetworkString("opsSnapshot")

hook.Add("PlayerDeath", "opsDeathSnapshot", function(victim, attacker, inflictor)
	if not victim:IsPlayer() or not inflictor:IsPlayer() then
		return
	end

	local snapshot = {}

	snapshot.Victim = victim
	snapshot.VictimID = victim:SteamID()
	snapshot.VictimNick = victim:Nick()
	snapshot.VictimPos = victim:GetPos()
	snapshot.VictimLastPos = victim.LastKnownPos or snapshot.VictimPos
	snapshot.VictimAng = victim:GetAngles()
	snapshot.VictimEyeAng = victim:EyeAngles()
	snapshot.VictimModel = victim:GetModel()
	snapshot.VictimHitGroup = victim:LastHitGroup()

	snapshot.Inflictor = inflictor
	snapshot.InflictorID = inflictor:SteamID()
	snapshot.InflictorNick = inflictor:Nick()
	snapshot.InflictorPos = inflictor:GetPos()
	snapshot.InflictorLastPos = inflictor.LastKnownPos or snapshot.InflictorPos
	snapshot.InflictorAng = inflictor:GetAngles()
	snapshot.InflictorEyePos = inflictor:EyePos()
	snapshot.InflictorEyeAng = inflictor:EyeAngles()
	snapshot.InflictorModel = inflictor:GetModel()

	if attacker:IsPlayer() then
		snapshot.AttackerClass = IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() or 'unknown'
	else
		snapshot.AttackerClass = "non player ent"
	end

	local snapshotsCount = #impulse.Ops.Snapshots + 1
	impulse.Ops.Snapshots[snapshotsCount] = snapshot

	victim.LastSnapshotID = snapshotsCount
	inflictor.LastSnapshotID = snapshotsCount
end)