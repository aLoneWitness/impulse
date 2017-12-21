local IsValid = IsValid
local os = os
local util = util
hook.Add("CalcMainActivity", "IMPULSE-ANIMATIONBASE", function( Player, Velocity )
	local speed = Velocity:Length()

	if Player:IsOnGround() and not Player:Crouching() and not Player:InVehicle() then
		if speed <= Player:GetWalkSpeed() + 10 then
			return ACT_HL2MP_WALK, -1
		elseif speed > impulse.Config.SprintSpeed - 10 then
			return ACT_HL2MP_RUN_FAST, -1
		elseif speed > Player:GetRunSpeed() - 10 then
			return ACT_MP_RUN, -1
		end
	end

end)


