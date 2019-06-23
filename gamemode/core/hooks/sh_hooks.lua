local KEY_BLACKLIST = IN_ATTACK + IN_ATTACK2

function IMPULSE:StartCommand(ply, command)
	local weapon = ply:GetActiveWeapon()

	if not ply:IsWeaponRaised() then
		command:RemoveKey(KEY_BLACKLIST)
	end
end

function IMPULSE:PlayerSwitchWeapon(ply, oldWep, newWep)
	if SERVER then
		ply:SetWeaponRaised(false)
	end
end

local isValid = IsValid
local mathAbs = math.abs
function IMPULSE:Move(ply, mvData)
	if SERVER then
		local draggedPlayer = ply.ArrestedDragging

		if isValid(draggedPlayer) and ply == draggedPlayer.ArrestedDragger then
			local draggerPos = ply:GetPos()
			local draggedPos = draggedPlayer:GetPos()
			local dist = (draggerPos - draggedPos):LengthSqr()

			local dragPosNormal = draggerPos:GetNormal()
			local dX = mathAbs(dragPosNormal.x)
			local dY = mathAbs(dragPosNormal.y)

			local speed = (dX + dY) * math.Clamp(dist / (100 ^ 2), 0, 30)

			local ang = mvData:GetMoveAngles()
			local pos = mvData:GetOrigin()
			local vel = mvData:GetVelocity()

			vel.x = vel.x * speed
			vel.y = vel.y * speed
			vel.z =  15

			pos = pos + vel + ang:Right() + ang:Forward() + ang:Up()

			if dist > (55 ^ 2) then
				draggedPlayer:SetVelocity(vel)
			end
		end
	end

	-- alt walk thing based on nutscripts
	if ply:GetMoveType() == MOVETYPE_WALK and mvData:KeyDown(IN_WALK) then
		local speed = ply:GetWalkSpeed()
		local forwardRatio = 0
		local sideRatio = 0
		local ratio = impulse.Config.SlowWalkRatio

		if (mvData:KeyDown(IN_FORWARD)) then
			forwardRatio = ratio
		elseif (mvData:KeyDown(IN_BACK)) then
			forwardRatio = -ratio
		end

		if (mvData:KeyDown(IN_MOVELEFT)) then
			sideRatio = -ratio
		elseif (mvData:KeyDown(IN_MOVERIGHT)) then
			sideRatio = ratio
		end

		mvData:SetForwardSpeed(forwardRatio * speed)
		mvData:SetSideSpeed(sideRatio * speed)
	end
end