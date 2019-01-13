netstream.Hook("impulseJoinData", function(xisNew)
	impulse_isNewPlayer = xisNew -- this is saved as a normal global variable cuz impulse or localplayer have not loaded yet on the client
end)

netstream.Hook("impulseNotify", function(msgData)
	LocalPlayer():Notify(unpack(msgData))
end)