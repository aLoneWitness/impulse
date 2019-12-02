net.Receive("impulseOpsEMMenu", function()
	if impulse_eventmenu and IsValid(impulse_eventmenu) then
		impulse_eventmenu:Remove()
	end
	
	impulse_eventmenu = vgui.Create("impulseEventManager")
end)