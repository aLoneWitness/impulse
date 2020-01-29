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
	snapshot.VictimBodygroups = {}

	for v,k in pairs(victim:GetBodyGroups()) do
		snapshot.VictimBodygroups[k.id] = victim:GetBodygroup(k.id)
	end

	snapshot.Inflictor = inflictor
	snapshot.InflictorID = inflictor:SteamID()
	snapshot.InflictorNick = inflictor:Nick()
	snapshot.InflictorPos = inflictor:GetPos()
	snapshot.InflictorLastPos = inflictor.LastKnownPos or snapshot.InflictorPos
	snapshot.InflictorAng = inflictor:GetAngles()
	snapshot.InflictorEyePos = inflictor:EyePos()
	snapshot.InflictorEyeAng = inflictor:EyeAngles()
	snapshot.InflictorModel = inflictor:GetModel()
	snapshot.InflictorHealth = inflictor:Health()
	snapshot.InflictorBodygroups = {}

	for v,k in pairs(inflictor:GetBodyGroups()) do
		snapshot.InflictorBodygroups[k.id] = inflictor:GetBodygroup(k.id)
	end

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

local SNAP_TICKRATE = 0.66
local SNAP_PACKETSIZE = 128
-- heavy optimizations
local ctime = CurTime
hook.Add("PlayerPostThink", "opsSnapshotCaptureSys", function(ply)
	local curTime = ctime()

	if (ply.lastSnapshotCap or 0) < curTime then
		ply.lastSnapshotCap = curTime + SNAP_TICKRATE

		ply.SnapCaps = ply.SnapCaps or {}
		ply.SnapTick = (ply.SnapTick or 0) + 1
		ply.SnapStart = ply.SnapStart or curTime
		ply.SnapCaps[ply.SnapTick] = {
			[1] = ply.GetPos(ply),
			[2] = ply.GetAngles(ply)
		}
	end
end)


function impulse.Snapshot.NetSplit(snapshot)
	local start
	local splits = 1
	local splitSnapshot = {}
	
	for v,k in pairs(snapshot) do
		start = start or v
		
		splitSnapshot[splits] = splitSnapshot[splits] or {}
		splitSnapshot[splits][v] = k
		
		if v >= (start + SNAP_PACKETSIZE) then
			splits = splits + 1
		end
	end
	
	return splitSnapshot
end

function meta:GetSnapData(length)
	local cur = ply.SnapTick

	if not cur then 
		return
	end

	local compiled = {}
	local tps = 1 / SNAP_TICKRATE
	local reps = 0
	
	for i = cur - math.ceil(tps * length), cur do
		if not ply.SnapCaps[i] then
			return
		end

		compiled[i] = {
			Time = tps * reps,
			Tick = i,
			TickSinceStart = reps,
			GeoData = ply.SnapCaps[i]
		}

		reps = reps + 1
	end

	return compiled, ply.SnapStart, reps
end
