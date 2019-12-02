concommand.Add("impulse_ops_eventmanager", function(ply)
	if not ply:IsEventAdmin() then
		return
	end

	net.Start("impulseOpsEMMenu")
	net.Send(ply)
end)