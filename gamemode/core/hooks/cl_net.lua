netstream.Hook("impulseJoinData", function(xisNew)
	impulse_isNewPlayer = xisNew -- this is saved as a normal global variable cuz impulse or localplayer have not loaded yet on the client
end)

net.Receive("impulseNotify", function(len)
	local message = net.ReadString()

	if LocalPlayer() and IsValid(LocalPlayer()) then
		LocalPlayer():Notify(message)
	end
end)

net.Receive("impulseATMOpen", function()
	vgui.Create("impulseATMMenu")
end)

net.Receive("impulseReadNote", function()
	local text = net.ReadString()

	local mainFrame = vgui.Create("DFrame")
	mainFrame:SetSize(300, 500)
	mainFrame:Center()
	mainFrame:MakePopup()
	mainFrame:SetTitle("Letter")

	local textFrame = vgui.Create( "DTextEntry", mainFrame ) 
	textFrame:SetPos(25, 50)
	textFrame:Dock(FILL)
	textFrame:SetText(text)
	textFrame:SetEditable(false)
	textFrame:SetMultiline(true)
end)

net.Receive("impulseChatNetMessage", function(len)
	local id = net.ReadUInt(8)
	local message = net.ReadString()
	local target = net.ReadUInt(8)
	local chatClass = impulse.chatClasses[id]
	local plyTarget = Entity(target)

	if target == 0 then
		chatClass(message)
	elseif IsValid(plyTarget) then
		chatClass(message, plyTarget)
	end
end)

net.Receive("impulseSendJailInfo", function()
	local endTime = net.ReadUInt(16)
	local hasJailData = net.ReadBool()
	local jailData

	if hasJailData then
		jailData = net.ReadTable()
	end

	impulse_JailDuration = endTime
	impulse_JailTimeEnd = CurTime() + endTime
	impulse_JailData = jailData or nil

	hook.Run("PlayerGetJailData", endTime, jailData)
end)

net.Receive("impulseBudgetSound", function()
	local ent = Entity(net.ReadUInt(16))
	local snd = net.ReadString()

	if IsValid(ent) then
		ent:EmitSound(snd)
	end
end)

net.Receive("impulseBudgetSoundExtra", function()
	local ent = Entity(net.ReadUInt(16))
	local snd = net.ReadString()
	local level = net.ReadUInt(8)
	local pitch = net.ReadUInt(8)

	if level == 0 then
		level = 75
	end

	if pitch == 0 then
		pitch = 100
	end

	if IsValid(ent) then
		ent:EmitSound(snd, level, pitch)
	end
end)

net.Receive("impulseCinematicMessage", function()
	local title = net.ReadString()

	impulse.CinematicIntro = true
	impulse.CinematicTitle = title
end)

net.Receive("impulseZoneUpdate", function()
	local zone = net.ReadUInt(8)

	impulse.ShowZone = true
	LocalPlayer().impulseZone = zone
end)

net.Receive("impulseQuizForce", function()
	local team = net.ReadUInt(8)
	local quiz = vgui.Create("impulseQuiz")
	quiz:SetQuiz(team)
end)

net.Receive("impulseInvGiveSilent", function()
	local netid = net.ReadUInt(16)
	local strid = net.ReadUInt(4)

	if not impulse.Inventory.Data[0][strid] then
		impulse.Inventory.Data[0][strid] = {}
	end

	table.insert(impulse.Inventory.Data[0][strid], {
		equipped = false,
		restricted = false,
		id = netid
	})
end)