function IMPULSE:HudShouldDraw(name)
	if(name == "CHudHealth") or (name == "CHudBattery") then
	    return false
    end
end
