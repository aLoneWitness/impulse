util.AddNetworkString("impulseOpsEMMenu")
util.AddNetworkString("impulseOpsEMPushSequence")
util.AddNetworkString("impulseOpsEMUpdateEvent")

net.Receive("impulseOpsEMPushSequence", function(len, ply)
	if (ply.nextOpsEMPush or 0) > CurTime() then return end
	ply.nextOpsEMPush = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()
	local seqEventCount = net.ReadUInt(16)
	local events = {}

	print("[ops-em] Starting pull of "..seqName.." (by "..ply:SteamName().."). Total events: "..seqEventCount.."")

	for i=1, seqEventCount do
		local dataSize = net.ReadUInt(16)
		local eventData = pon.decode(net.ReadData(dataSize))

		table.insert(events, eventData)
		print("[ops-em] Got event "..i.."/"..seqEventCount.." ("..eventData.Type..")")
	end

	impulse.Ops.EventManager.Sequences[seqName] = events

	print("[ops-em] Finished pull of "..seqName..". Ready to play sequence!")

	if IsValid(ply) then
		ply:Notify("Push completed.")
	end
end)