local red = Color(255, 0, 0, 255)
local green = Color(0, 240, 0, 255)
hook.Add("HUDPaint", "impulseOpsHUD", function()
	if not impulse.hudEnabled then return end

	if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
		local onDuty = impulse.GetSetting("admin_onduty") or false

		if onDuty then
			draw.SimpleText("OBSERVER MODE", "Impulse-Elements16-Shadow", 20, 10, impulse.Config.MainColour)
		else
			draw.SimpleText("OBSERVER MODE (OFF DUTY! YOU WILL NOT VIEW INBOUND REPORTS!)", "Impulse-Elements16-Shadow", 20, 10, red)
		end

		draw.SimpleText("TOTAL REPORTS: " ..#impulse.Ops.Reports, "Impulse-Elements16-Shadow", 20, 30, impulse.Config.MainColour)

		local totalClaimed = 0
		for v,k in pairs(impulse.Ops.Reports) do
			if k[3] then
				totalClaimed = totalClaimed + 1

				if k[3] == LocalPlayer() then
					if IsValid(k[1]) then
						draw.SimpleText("REPORTEE: "..k[1]:SteamName().." ("..k[1]:Name()..")", "Impulse-Elements16-Shadow", 20, 80, green)
					else
						draw.SimpleText("REPORTEE IS INVALID! CLOSE THIS REPORT.", "Impulse-Elements16-Shadow", 20, 80, green)
					end
				end
			end
		end

		draw.SimpleText("CLAIMED REPORTS: " ..totalClaimed, "Impulse-Elements16-Shadow", 20, 50, impulse.Config.MainColour)
	end
end)