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

		if impulse.GetSetting("admin_esp") and LocalPlayer():IsSuperAdmin() then
			draw.SimpleText("ENTCOUNT: "..#ents.GetAll(), "Impulse-Elements16-Shadow", 20, 100, impulse.Config.MainColour)
			draw.SimpleText("PLAYERCOUNT: "..#player.GetAll(), "Impulse-Elements16-Shadow", 20, 120, impulse.Config.MainColour)

			local y = 140

			for v,k in pairs(team.GetAllTeams()) do
				draw.SimpleText(team.GetName(v)..": "..#team.GetPlayers(v), "Impulse-Elements16-Shadow", 20, y, impulse.Config.MainColour)
				y = y + 20
			end

			for v,k in pairs(player.GetAll()) do
				if k ==  LocalPlayer() then continue end
				
				local pos = (k:GetPos() + k:OBBCenter()):ToScreen()
				local col = team.GetColor(k:Team())

				draw.SimpleText(k:Name(), "Impulse-Elements18-Shadow", pos.x, pos.y, col, TEXT_ALIGN_CENTER)
				draw.SimpleText(k:SteamName(), "Impulse-Elements16-Shadow", pos.x, pos.y + 15, impulse.Config.InteractColour, TEXT_ALIGN_CENTER)

				if k:GetTeamClass() != 0 then
					draw.SimpleText(k:GetTeamClassName().." - "..k:GetTeamRankName(), "Impulse-Elements14-Shadow", pos.x + 20, pos.y, col, TEXT_ALIGN_CENTER)
				end
			end
		end
	end
end)