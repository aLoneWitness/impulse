-- This is an edited version of nutscript's stamina by chessnut.


if (SERVER) then
	local function BeginStamina(client)
		client:setIVar("stamina", 100, client)

		local uniqueID = "impulseStam"..client:SteamID()
		local offset = 0
		local velocity
		local length2D = 0
		local runSpeed = client:GetRunSpeed() - 5

		timer.Create(uniqueID, 0.25, 0, function()
			if (IsValid(client)) then

				if (client:GetMoveType() != MOVETYPE_NOCLIP) then
					velocity = client:GetVelocity()
					length2D = velocity:Length2D()
					runSpeed = gfl.runSpeed

					if (client:KeyDown(IN_SPEED) and length2D >= (runSpeed - 10)) then
						offset = -2
					elseif (offset > 0.5) then
						offset = 1
					else
						offset = 1.75
					end

					local current = client.stamina or 0
					local value = math.Clamp(current + offset, 0, 100)

					if (current != value) then
						client:setIVar("stamina", value, client)
						client.stamina = value

						if value == 0 then
							client:SetRunSpeed(gfl.walkSpeed)
							--client:setNetVar("brth", true)
						elseif value >= 50 then
							client:SetRunSpeed(runSpeed)
							--client:setNetVar("brth", nil)
						end
					end
				end
			else
				timer.Remove(uniqueID)
			end
		end)
	end
end
