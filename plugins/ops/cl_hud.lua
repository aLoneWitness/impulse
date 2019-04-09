local red = Color(255, 0, 0, 255)
hook.Add("HUDPaint", "impulseOpsHUD", function()
	if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
		draw.SimpleText("OBSERVER MODE", "Impulse-Elements16-Shadow", 20, 10, red)
		draw.SimpleText(LocalPlayer():GetZoneName(), "Impulse-Elements16-Shadow", 20, 30, red)
	end
end)