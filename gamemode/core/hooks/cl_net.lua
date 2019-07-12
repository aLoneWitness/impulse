netstream.Hook("impulseJoinData", function(xisNew)
	impulse_isNewPlayer = xisNew -- this is saved as a normal global variable cuz impulse or localplayer have not loaded yet on the client
end)

net.Receive("impulseNotify", function(len)
	local message = net.ReadString()

	LocalPlayer():Notify(message)
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

net.Receive("impulseInvGive", function()
	local netid = net.ReadUInt(16)
	local invid = net.ReadUInt(10)
	local strid = net.ReadUInt(4)
	local restricted = net.ReadBool()

	if not impulse.Inventory.Data[0][strid] then
		impulse.Inventory.Data[0][strid] = {}
	end

	impulse.Inventory.Data[0][strid][invid] = {
		equipped = false,
		restricted = restricted,
		id = netid
	}

	if impulse_inventory and IsValid(impulse_inventory) then
		impulse_inventory:SetupItems()
	end
end)

net.Receive("impulseInvMove", function()
	local invid = net.ReadUInt(10)
	local newinvid = net.ReadUInt(10)
	local from = net.ReadUInt(4)
	local to = net.ReadUInt(4)
	local netid

	local take = impulse.Inventory.Data[0][from][invid]

	netid = take.id

	impulse.Inventory.Data[0][from][invid] = nil
	impulse.Inventory.Data[0][to][newinvid] = {
		id = netid
	}

	if impulse_storage and IsValid(impulse_storage) then
		local invScroll = impulse_storage.invScroll:GetVBar():GetScroll()
		local invStorageScroll = impulse_storage.invStorageScroll:GetVBar():GetScroll()

		impulse_storage:SetupItems(invScroll, invStorageScroll)
		surface.PlaySound("physics/wood/wood_crate_impact_hard2.wav")
	end
end)

net.Receive("impulseInvRemove", function()
	local invid = net.ReadUInt(10)
	local strid = net.ReadUInt(4)
	local item = impulse.Inventory.Data[0][strid][invid]

	if item then
		impulse.Inventory.Data[0][strid][invid] = nil

		if impulse_inventory and IsValid(impulse_inventory) then
			impulse_inventory:SetupItems()
		end
	end
end)

net.Receive("impulseInvClear", function()
	local storetype = net.ReadUInt(4)

	if impulse.Inventory.Data[0][storetype] then
		impulse.Inventory.Data[0][storetype] = {}
	end
end)

net.Receive("impulseInvClearRestricted", function()
	local storetype = net.ReadUInt(4)

	if impulse.Inventory.Data[0][storetype] then
		for v,k in pairs(impulse.Inventory.Data[0][storetype]) do
			if k.restricted then
				impulse.Inventory.Data[0][storetype][v] = nil
			end
		end
	end
end)

net.Receive("impulseInvUpdateEquip", function()
	local invid = net.ReadUInt(10)
	local state = net.ReadBool()
	local item = impulse.Inventory.Data[0][1][invid]

	item.equipped = state or false

	if impulse_inventory and IsValid(impulse_inventory) then
		impulse_inventory:FindItemPanelByID(invid).IsEquipped = state or false
	end
end)

net.Receive("impulseInvDoSearch", function()
	local searchee = Entity(net.ReadUInt(8))
	local invSize = net.ReadUInt(16)
	local invCompiled = {}

	if not IsValid(searchee) then return end

	for i=1,invSize do
		local itemnetid = net.ReadUInt(10)
		local item = impulse.Inventory.Items[itemnetid]
		
		table.insert(invCompiled, item)
	end


	impulse.MakeWorkbar(5, "Searching...", function()
		if not IsValid(searchee) then return end

		local searchMenu = vgui.Create("impulseSearchMenu")
		searchMenu:SetInv(invCompiled)
		searchMenu:SetPlayer(searchee)
	end, true)
end)

net.Receive("impulseInvStorageOpen", function(len, ply)
	impulse_storage = vgui.Create("impulseInventoryStorage")
end)

net.Receive("impulseRagdollLink", function()
	local ragdoll = net.ReadEntity()

	if IsValid(ragdoll) then
		LocalPlayer().Ragdoll = ragdoll
	end
end)

net.Receive("impulseUpdateOOCLimit", function()
	local time = net.ReadUInt(16)

	LocalPlayer().OOCLimit = (LocalPlayer().OOCLimit and LocalPlayer().OOCLimit - 1) or ((LocalPlayer():IsDonator() and impulse.Config.OOCLimitVIP) or impulse.Config.OOCLimit)
	LocalPlayer():Notify("You have "..LocalPlayer().OOCLimit.." OOC messages left for "..string.NiceTime(time)..".")
end)

net.Receive("impulseCharacterEditorOpen", function()
	local vo = impulse.GetRandomAmbientVO("female")
	surface.PlaySound(vo)

	vgui.Create("impulseCharacterEditor")
end)

net.Receive("impulseUpdateDefaultModelSkin", function()
	impulse_defaultModel = net.ReadString()
	impulse_defaultSkin = net.ReadUInt(8)
end)

net.Receive("impulseConfiscateCheck", function()
	local item = net.ReadEntity()

	if IsValid(item) then
		local request = Derma_Query("Would you like to confiscate this "..item.HUDName.."?", 
			"impulse",
			"Confiscate",
			function()
				net.Start("impulseDoConfiscate")
				net.SendToServer()
			end,
			"Cancel")

		function request:Think()
			if not item or not IsValid(item) then
				self:Remove()
			end
		end
	end
end)