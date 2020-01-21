impulse.Ops = impulse.Ops or {}
impulse.Ops.Snapshot = impulse.Ops.Snapshot or {}
impulse.Ops.Snapshots = impulse.Ops.Snapshots or {}
impulse.Ops.Snapshot.Playback = impulse.Ops.Snapshot.Playback or {}

SNAP_TICKRATE = 0.66 -- delay between snapcaps
SNAP_PACKETSIZE = 128 -- snapcaps per packet
SNAP_MAXTICKS = 3600 -- 40 minutes long
SNAP_SPEED = 1

function impulse.Ops.Snapshot.Playback.VirtualFrameTime()
	local snapshot = 0
	local cur = impulse.Ops.Snapshot.Playback.CurTick
	local frame = snapshot.Data[cur]
	local pStart = snapshot.PlaybackStart
	
	return math.Clamp(CurTime() - pStart, 0, 1)
end

function impulse.Ops.Snapshot.Playback.TimeSinceStart()
	local snapshot = 0
	local cur = impulse.Ops.Snapshot.Playback.CurTick
	local frame = snapshot.Data[cur]
	local tickSinceStart = frame.TicksSinceStart

	return (1 / tickSinceStart) + impulse.Ops.Snapshot.Playback.VirtualFrameTime()
end

function impulse.Ops.Snapshot.Playback.Length()
	local snapshot = 0
	local ticks = impulse.Ops.Snapshot.Playback.Ticks
	
	return (1 / ticks)
end

local snapshotCommand = {
    description = "Plays the snapshot specified by the snapshot ID.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local id = arg[1]

        if not tonumber(id) then
        	return ply:Notify("ID must be a number.")
        end

        id = tonumber(id)

        if not impulse.Ops.Snapshots[id] then
        	return ply:Notify("Snapshot could not be found with that ID.")
        end

        ply:Notify("Downloading snapshot #"..id.."...")

        local snapshot = impulse.Ops.Snapshots[id]
        snapshot = pon.encode(snapshot)
		
		net.Start("opsSnapshot")
		net.WriteUInt(id, 16)
		net.WriteUInt(#snapshot, 32)
		net.WriteData(snapshot, #snapshot)
		net.Send(ply)
    end
}

impulse.RegisterChatCommand("/snapshot", snapshotCommand)
