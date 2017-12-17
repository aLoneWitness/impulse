
local AnimTranslateTable = {}
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_RUN_CHARGING
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK

local IsValid = IsValid
local os = os
local util = util

function IMPULSE:CalcMainActivity( Player, Velocity )
	local speed = Velocity:Length()
	if not Player.LastOnGround and not Player:OnGround() then
		Player.LastOnGround = true
	end
	if Player:IsOnGround() and Player.LastOnGround then
		Player:AddVCDSequenceToGestureSlot( GESTURE_SLOT_FLINCH, Player:LookupSequence("jump_land"), 0, true )
		Player.LastOnGround = false
	end

	if Player:IsOnGround() then
		if speed > Player:GetRunSpeed() - 10 then
			return ACT_HL2MP_RUN_FAST, -1
		elseif speed <= Player:GetWalkSpeed() + 10 then
			print(speed)
			return ACT_HL2MP_WALK, -1
		end
	end

end

