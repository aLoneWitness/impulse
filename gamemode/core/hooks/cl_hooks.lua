function IMPULSE:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseSplash")
	end
end

function IMPULSE:Think()
	if input.IsKeyDown(KEY_F1) and not IsValid(impulse.MainMenu) then
		local mainMenu = vgui.Create("impulseMainMenu")
		mainMenu:SetAlpha(0)
		mainMenu:AlphaTo(255, .3)
		mainMenu.popup = true
	elseif input.IsKeyDown(KEY_F4) and not IsValid(impulse.playerMenu) then
		impulse.playerMenu = vgui.Create("impulsePlayerMenu")
	elseif input.IsKeyDown(KEY_LALT) then
		local trace = {}
		trace.start = LocalPlayer():EyePos()
		trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
		trace.filter = LocalPlayer()

		local traceEnt = util.TraceLine(trace).Entity

		if (not impulse.doorMenu or not IsValid(impulse.doorMenu)) and IsValid(traceEnt) and traceEnt:IsDoor() then
			local doorOwners = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
			local doorGroup =  traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)
			local doorBuyable = traceEnt:GetSyncVar(SYNC_DOOR_BUYABLE, true)

			if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) or LocalPlayer():CanLockUnlockDoor(doorOwners, doorGroup) then
				impulse.doorMenu = vgui.Create("impulseDoorMenu")
				impulse.doorMenu:SetDoor(traceEnt)
			end
		end
	end
end

function IMPULSE:ScoreboardShow()
    impulse_scoreboard = vgui.Create("impulseScoreboard")
end

function IMPULSE:ScoreboardHide()
    impulse_scoreboard:Remove()
end

function IMPULSE:DefineSettings()
	impulse.DefineSetting("hud_vignette", {name="Vignette enabled", category="HUD", type="tickbox", default=true})
	impulse.DefineSetting("hud_iconcolours", {name="Icon colours enabled", category="HUD", type="tickbox", default=false})
	impulse.DefineSetting("view_thirdperson", {name="Thirdperson enabled", category="View", type="tickbox", default=false})
	impulse.DefineSetting("view_thirdperson_fov", {name="Thirdperson FOV", category="View", type="slider", default=90, minValue=60, maxValue=95})
	impulse.DefineSetting("perf_mcore", {name="Multi-core rendering enabled", category="Performance", type="tickbox", default=false, onChanged = function(newValue)
		if newValue then
			RunConsoleCommand("gmod_mcore_test", tostring(tonumber(newValue)))
		end
	end})
end

local loweredAngles = Angle(30, -30, -25)

function IMPULSE:CalcViewModelView(weapon, viewmodel, oldEyePos, oldEyeAng, eyePos, eyeAngles)
	if not IsValid(weapon) then return end

	local vm_origin, vm_angles = eyePos, eyeAngles

	do
		local lp = LocalPlayer()
		local raiseTarg = 0

		if !lp:IsWeaponRaised() then
			raiseTarg = 100
		end

		local frac = (lp.raiseFraction or 0) / 100
		local rot = weapon.LowerAngles or loweredAngles

		vm_angles:RotateAroundAxis(vm_angles:Up(), rot.p * frac)
		vm_angles:RotateAroundAxis(vm_angles:Forward(), rot.y * frac)
		vm_angles:RotateAroundAxis(vm_angles:Right(), rot.r * frac)

		lp.raiseFraction = Lerp(FrameTime() * 2, lp.raiseFraction or 0, raiseTarg)
	end

	--The original code of the hook.
	do
		local func = weapon.GetViewModelPosition
		if (func) then
			local pos, ang = func( weapon, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end

		func = weapon.CalcViewModelView
		if (func) then
			local pos, ang = func( weapon, viewModel, oldEyePos*1, oldEyeAngles*1, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end
	end

	return vm_origin, vm_angles
end

function IMPULSE:ShouldDrawLocalPlayer()
	if impulse.GetSetting("view_thirdperson") then
		return true
	end
end

function IMPULSE:CalcView(player, origin, angles, fov)
	local view

	if IsValid(impulse.MainMenu) and not impulse.MainMenu.popup then
		view = {
			origin = impulse.Config.MenuCamPos,
			angles = impulse.Config.MenuCamAng,
			fov = 70
		}
		return view
	end
	
	local ragdoll = player:GetRagdollEntity()

	if ragdoll and IsValid(ragdoll) then
		local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment( "eyes" ))
		if not eyes then return end

		view = {
			origin = eyes.Pos,
			angles = eyes.Ang,
			fov = 70
		}
		return view
	end

	if impulse.GetSetting("view_thirdperson") then
		local angles = player:GetAimVector():Angle()
		local targetpos = Vector(0, 0, 60)

		player:SetAngles(angles)

		local pos = targetpos

		local offset = Vector(5, 5, 5)

		offset.x = 75
		offset.y = 20
		offset.z = 5
		angles.yaw = angles.yaw + 3

		local t = {}

		t.start = player:GetPos() + pos
		t.endpos = t.start + angles:Forward() * -offset.x

		t.endpos = t.endpos + angles:Right() * offset.y
		t.endpos = t.endpos + angles:Up() * offset.z
		t.filter = player
		
		local tr = util.TraceLine(t)

		pos = tr.HitPos

		if (tr.Fraction < 1.0) then
			pos = pos + tr.HitNormal * 5
		end

		return {
			origin = pos,
			angles = angles,
			fov = impulse.GetSetting("view_thirdperson_fov")
		}
	end
end
