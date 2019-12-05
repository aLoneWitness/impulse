local function UpdateEventAdmins(eventid)
	for v,k in pairs(player.GetAll()) do
		if k:IsEventAdmin() then
			net.Start("impulseOpsEMSequenceEvent")
			net.WriteUInt(eventid, 10)
			net.Send(k)
		end
	end
end

function impulse.Ops.EventManager.PlayEvent(sequence, eventid)

	UpdateEventAdmins(eventid)
end