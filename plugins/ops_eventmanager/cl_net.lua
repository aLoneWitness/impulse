net.Receive("impulseOpsEMMenu", function()
	local count = net.ReadUInt(8)
	local svSequences = {}

	for i=1, count do
		table.insert(svSequences, net.ReadString())
	end

	if impulse_eventmenu and IsValid(impulse_eventmenu) then
		impulse_eventmenu:Remove()
	end
	
	impulse_eventmenu = vgui.Create("impulseEventManager")
	impulse_eventmenu:SetupPlayer(svSequences)
end)

net.Receive("impulseOpsEMUpdateEvent", function()
	local event = net.ReadUInt(16)

	impulse_OpsEM_CurEvent = event
end)