

if (CLIENT) then
	local lastSlot = lastSlot or 1
	local lifeTime = lifeTime or 0
	local deathTime = deathTime or 0

	local LIFE_TIME = 4
	local DEATH_TIME = 5

	local function OnSlotChanged()
		lifeTime = CurTime() + LIFE_TIME
		deathTime = CurTime() + DEATH_TIME
	end

	hook.Add("PlayerBindPress","IMPULSE-BIND-PRESS1", function(client, bind, pressed)
		local weapon = client:GetActiveWeapon()

		if (!client:InVehicle() and (!IsValid(weapon) or weapon:GetClass() != "weapon_physgun" or !client:KeyDown(IN_ATTACK))) then
			bind = string.lower(bind)

			if (string.find(bind, "invprev") and pressed) then
				lastSlot = lastSlot - 1

				if (lastSlot <= 0) then
					lastSlot = #client:GetWeapons()
				end

				OnSlotChanged()

				return true
			elseif (string.find(bind, "invnext") and pressed) then
				lastSlot = lastSlot + 1

				if (lastSlot > #client:GetWeapons()) then
					lastSlot = 1
				end

				OnSlotChanged()

				return true
			elseif (string.find(bind, "+attack") and pressed) then
				if (CurTime() < deathTime) then
					lifeTime = 0
					deathTime = 0

					for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
						if (k == lastSlot) then
							RunConsoleCommand("impulse_selectwep", v:GetClass())

							return true
						end
					end
				end
			elseif (string.find(bind, "slot")) then
				lastSlot = math.Clamp(tonumber(string.match(bind, "slot(%d)")) or 1, 1, #LocalPlayer():GetWeapons())
				lifeTime = CurTime() + LIFE_TIME
				deathTime = CurTime() + DEATH_TIME

				return true
			end
		end
	end)

	hook.Add("HUDPaint", "IMPULSE-WEAPON-HDPAINT", function()
		if impulse.hudEnabled == false or IsValid(impulse.MainMenu) then return end
		local x = ScrW() * 0.475

		for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
			local y = (ScrH() * 0.4) + (k * 24)
			local y2 = y

			local color = Color(255, 255, 255)

			if (k == lastSlot) then
				color = impulse.Config.MainColour
			end

			color.a = math.Clamp(255 - math.TimeFraction(lifeTime, deathTime, CurTime()) * 255, 0, 255)
			draw.DrawText(string.upper(v:GetPrintName()), "Impulse-Elements18-Shadow", x, y, color, nil, TEXT_ALIGN_LEFT)

		end
	end)
else
	concommand.Add("impulse_selectwep", function(client, command, arguments)
		client:SelectWeapon(arguments[1] or "keys")
	end)
end
