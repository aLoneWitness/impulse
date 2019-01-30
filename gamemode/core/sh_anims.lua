-- this animation system is HEAVILY based on nutscripts system with partial recodes or changes to suit impulse.
-- i claim no credit for this
-- check out NS at https://github.com/rebel1324/NutScript/

impulse.anim = impulse.anim or {}
impulse.anim.citizen_male = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_RANGE_ATTACK_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_ATTACK_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = {
		["prop_vehicle_prisoner_pod"] = {"podpose", Vector(-3, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_BUSY_SIT_CHAIR, Vector(14, 0, -14)},
		["prop_vehicle_airboat"] = {ACT_BUSY_SIT_CHAIR, Vector(8, 0, -20)},
		chair = {ACT_BUSY_SIT_CHAIR, Vector(1, 0, -23)}
	},
}

impulse.anim.citizen_female = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = impulse.anim.citizen_male.vehicle
}
impulse.anim.metrocop = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE,
	vehicle = {
		chair = {ACT_COVER_PISTOL_LOW, Vector(5, 0, -5)},
		["prop_vehicle_airboat"] = {ACT_COVER_PISTOL_LOW, Vector(10, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_COVER_PISTOL_LOW, Vector(18, -2, 4)},
		["prop_vehicle_prisoner_pod"] = {ACT_IDLE, Vector(-4, -0.5, 0)}
	}
}
impulse.anim.overwatch = {
	normal = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE
}
impulse.anim.vort = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "actionidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	glide = ACT_GLIDE
}
impulse.anim.player = {
	normal = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE,
		[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH,
		[ACT_MP_WALK] = ACT_HL2MP_WALK,
		[ACT_MP_RUN] = ACT_HL2MP_RUN
	},
	passive = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_PASSIVE,
		[ACT_MP_WALK] = ACT_HL2MP_WALK_PASSIVE,
		[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
		[ACT_MP_RUN] = ACT_HL2MP_RUN_PASSIVE
	}
}
impulse.anim.zombie = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_ZOMBIE,
	[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
	[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_02,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE
}
impulse.anim.fastZombie = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_WALK_ZOMBIE,
	[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
	[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_05,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_06,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE_FAST
}


local translations = {}

function impulse.anim.SetModelClass(model, class)
	if not impulse.anim[class] then
		error("'"..tostring(class).."' is not a valid animation class!")
	end
	
	translations[model:lower()] = class
end

-- Micro-optimization since the get class function gets called a lot.
local stringLower = string.lower
local stringFind = string.find

function impulse.anim.GetModelClass(model)
	model = stringLower(model)
	local class = translations[model]

	if not class and stringFind(model, "/player") then
		return "player"
	end

	class = class or "citizen_male"

	if (class == "citizen_male" and (stringFind(model, "female") or stringFind(model, "alyx") or stringFind(model, "mossman"))) then
		class = "citizen_female"
	end
	
	return class
end

impulse.anim.SetModelClass("models/police.mdl", "metrocop")
impulse.anim.SetModelClass("models/combine_super_soldier.mdl", "overwatch")
impulse.anim.SetModelClass("models/combine_soldier_prisonGuard.mdl", "overwatch")
impulse.anim.SetModelClass("models/combine_soldier.mdl", "overwatch")
impulse.anim.SetModelClass("models/vortigaunt.mdl", "vort")
impulse.anim.SetModelClass("models/vortigaunt_blue.mdl", "vort")
impulse.anim.SetModelClass("models/vortigaunt_doctor.mdl", "vort")
impulse.anim.SetModelClass("models/vortigaunt_slave.mdl", "vort")
impulse.anim.SetModelClass("models/player/zelpa/male_08.mdl", "citizen_male")

local ALWAYS_RAISED = {}
ALWAYS_RAISED["weapon_physgun"] = true
ALWAYS_RAISED["gmod_tool"] = true

do
	function meta:ForceSequence(sequence, callback, time, noFreeze)
		hook.Run("OnPlayerEnterSequence", self, sequence, callback, time, noFreeze)

		if not sequence then
			return netstream.Start(nil, "seqSet", self)
		end

		local sequence = self:LookupSequence(sequence)

		if sequence and sequence > 0 then
			time = time or self:SequenceDuration(sequence)

			self.impulseSeqCallback = callback
			self.impulseForceSeq = sequence

			if not noFreeze then
				self:SetMoveType(MOVETYPE_NONE)
			end

			if time > 0 then
				timer.Create("impulseSeq"..self:EntIndex(), time, 1, function()
					if IsValid(self) then
						self:leaveSequence()
					end
				end)
			end

			netstream.Start(nil, "seqSet", self, sequence)

			return time
		end

		return false
	end

	function meta:leaveSequence()
		hook.Run("OnPlayerLeaveSequence", self)

		netstream.Start(nil, "seqSet", self)

		self:SetMoveType(MOVETYPE_WALK)
		self.impulseForceSeq = nil

		if self.impulseSeqCallback then
			self:impulseSeqCallback()
		end
	end

	function meta:IsWeaponRaised()
		local weapon = self.GetActiveWeapon(self)

		if IsValid(weapon) then
			if weapon.IsAlwaysRaised or ALWAYS_RAISED[weapon.GetClass(weapon)] then
				return true
			elseif weapon.IsAlwaysLowered then
				return false
			end
		end

		return self.GetSyncVar(self, SYNC_WEPRAISED, false)
	end

	if SERVER then
		function meta:SetWeaponRaised(state)
			self:SetSyncVar(SYNC_WEPRAISED, state, true)

			local weapon = self:GetActiveWeapon()

			if IsValid(weapon) then
				weapon:SetNextPrimaryFire(CurTime() + 1)
				weapon:SetNextSecondaryFire(CurTime() + 1)
			end
		end

		function meta:ToggleWeaponRaised()
			self:SetWeaponRaised(!self:IsWeaponRaised())
		end
	end

	if CLIENT then
		netstream.Hook("seqSet", function(entity, sequence)
			if IsValid(entity) then
				if not sequence then
					entity.impulseForceSeq = nil

					return
				end

				entity:SetCycle(0)
				entity:SetPlaybackRate(1)
				entity.impulseForceSeq = sequence
			end
		end)
	end
end

HOLDTYPE_TRANSLATOR = {}
HOLDTYPE_TRANSLATOR[""] = "normal"
HOLDTYPE_TRANSLATOR["physgun"] = "smg"
HOLDTYPE_TRANSLATOR["ar2"] = "smg"
HOLDTYPE_TRANSLATOR["crossbow"] = "shotgun"
HOLDTYPE_TRANSLATOR["rpg"] = "shotgun"
HOLDTYPE_TRANSLATOR["slam"] = "normal"
HOLDTYPE_TRANSLATOR["grenade"] = "grenade"
HOLDTYPE_TRANSLATOR["fist"] = "normal"
HOLDTYPE_TRANSLATOR["melee2"] = "melee"
HOLDTYPE_TRANSLATOR["passive"] = "normal"
HOLDTYPE_TRANSLATOR["knife"] = "melee"
HOLDTYPE_TRANSLATOR["duel"] = "pistol"
HOLDTYPE_TRANSLATOR["camera"] = "smg"
HOLDTYPE_TRANSLATOR["magic"] = "normal"
HOLDTYPE_TRANSLATOR["revolver"] = "pistol"

PLAYER_HOLDTYPE_TRANSLATOR = {}
PLAYER_HOLDTYPE_TRANSLATOR[""] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["fist"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["pistol"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["grenade"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["slam"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee2"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["passive"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["knife"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["duel"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["bugbait"] = "normal"

local getModelClass = impulse.anim.GetModelClass
local IsValid = IsValid
local string  = string
local type = type

local PLAYER_HOLDTYPE_TRANSLATOR = PLAYER_HOLDTYPE_TRANSLATOR
local HOLDTYPE_TRANSLATOR = HOLDTYPE_TRANSLATOR

function IMPULSE:TranslateActivity(ply, act)
	local model = string.lower(ply.GetModel(ply))
	local class = getModelClass(model) or "player"
	local weapon = ply.GetActiveWeapon(ply)

	if class == "player" then
		if IsValid(weapon) and not ply.IsWeaponRaised(ply) and ply.OnGround(ply) then
			local holdType = IsValid(weapon) and (weapon.HoldType or weapon.GetHoldType(weapon)) or "normal"
			if not ply.IsWeaponRaised(ply) and ply.OnGround(ply) then
				holdType = PLAYER_HOLDTYPE_TRANSLATOR[holdType] or "passive"
			end

			local animTree = impulse.anim.player[holdType]

			if animTree and animTree[act] then
				if type(animTree[act]) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, animTree[act])
					return
				else
					return animTree[act]
				end
			end
		end
		return self.BaseClass.TranslateActivity(self.BaseClass, ply, act)
	end

	local animTree = impulse.anim[class]

	if animTree then
		local subClass = "normal"
		if ply.InVehicle(ply) then
			local vehicle = ply.GetVehicle(ply)
			local class = vehicle:IsChair() and "chair" or vehicle:GetClass()

			if animTree.vehicle and animTree.vehicle[class] then
				local act = animTree.vehicles[class][1]
				local fixvec = animTree.vehicle[class][2]

				if fixvec then
					ply:SetLocalPos(Vector(16.5438, -0.1642, -20.5493))
				end

				if type(act) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, act)

					return
				else
					return act
				end
			else
				act = animTree.normal[ACT_MP_CROUCH_IDLE][1]

				if type(act) == "string" then
					ply.CalcSeqOverride = ply:LookupSequence(act)
				end
				return
			end
		elseif ply.OnGround(ply) then
			ply.ManipulateBonePosition(ply, 0, vector_origin)

			if IsValid(weapon) then
				subClass = weapon.HoldType or weapon.GetHoldType(weapon)
				subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass
			end

			if animTree[subClass] and animTree[subClass][act] then
				local act2 = animTree[subClass][act][ply:IsWeaponRaised() and 2 or 1]

				if type(act2) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, act2)
					return
				end
				return act2
			end
		elseif animTree.glide then
			return animTree.glide
		end
	end
end

local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle

function IMPULSE:CalcMainActivity(ply, velocity)
	local eyeAngles = ply.EyeAngles(ply)
	local yaw = vectorAngle(velocity)[2]
	local normalized = normalizeAngle(yaw - eyeAngles[2])

	ply.SetPoseParameter(ply, "move_yaw", normalized)

	local oldSeqOverride = ply.CalcSeqOverride
	local seqIdeal, seqOverride = self.BaseClass.CalcMainActivity(self.BaseClass, ply, velocity)

	return seqIdeal, ply.impulseForceSeq or oldSeqOverride or ply.CalcSeqOverride
end

function IMPULSE:DoAnimationEvent(ply, event, data)
	local model = ply:GetModel():lower()
	local class = impulse.anim.GetModelClass(model)

	if class == "player" then
		return self.BaseClass:DoAnimationEvent(ply, event, data)
	else
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) then
			local holdType = weapon.HoldType or weapon:GetHoldType()
			holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

			local animation = impulse.anim[class][holdType]

			if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
				return ACT_VM_PRIMARYATTACK
			elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
				return ACT_VM_SECONDARYATTACK
			elseif event == PLAYERANIMEVENT_RELOAD then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)
				return ACT_INVALID
			elseif event == PLAYERANIMEVENT_JUMP then
				ply.m_bJumping = true
				ply.m_bFirstJumpFrame = true
				ply.m_flJumpStartTime = CurTime()
				ply:AnimRestartMainSequence()
				return ACT_INVALID
			elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
				ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
				return ACT_INVALID
			end
		end
	end
	return ACT_INVALID
end