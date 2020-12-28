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
	local event = net.ReadUInt(10)

	impulse_OpsEM_CurEvents = impulse_OpsEM_CurEvents or {}
	impulse_OpsEM_CurEvents[event] = CurTime()
end)

net.Receive("impulseOpsEMClientsideEvent", function()
	local event = net.ReadString()
	local uid = net.ReadString()
	local len = net.ReadUInt(16)
	local prop = pon.decode(net.ReadData(len))

	if not impulse.Ops.EventManager then
		return
	end

	local sequenceData = impulse.Ops.EventManager.Config.Events[event]

	if not sequenceData then
		return
	end

	if not uid or uid == "" then
		uid = nil
	end

	sequenceData.Do(prop or {}, uid)
end)

net.Receive("impulseOpsEMPlayScene", function()
	local scene = net.ReadString()

	if not impulse.Ops.EventManager.Scenes[scene] then
		return print("[impulse] Error! Can't find sceneset: "..scene)
	end

	impulse.Scenes.PlaySet(impulse.Ops.EventManager.Scenes[scene])
end)