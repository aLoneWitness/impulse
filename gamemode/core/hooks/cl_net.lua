netstream.Hook("impulseJoinData", function(xisNew)
	impulse_isNewPlayer = xisNew -- this is saved as a normal global variable cuz impulse or localplayer have not loaded yet on the client
end)

netstream.Hook("impulseNotify", function(msgData)
	LocalPlayer():Notify(unpack(msgData))
end)

netstream.Hook("impulseATMOpen", function()
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