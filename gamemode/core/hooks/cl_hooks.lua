function IMPULSE:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		vgui.Create("impulseSplash")

		if system.IsWindows() then
			system.FlashWindow()
		end
	end
end

function IMPULSE:Think()
	if LocalPlayer():Team() != 0 and not vgui.CursorVisible() then
		if input.IsKeyDown(KEY_F1) and (not IsValid(impulse.MainMenu) or not impulse.MainMenu:IsVisible()) then
			local mainMenu = impulse.MainMenu or vgui.Create("impulseMainMenu")
			mainMenu:SetVisible(true)
			mainMenu:SetAlpha(0)
			mainMenu:AlphaTo(255, .3)
			mainMenu.popup = true
		elseif input.IsKeyDown(KEY_F4) and not IsValid(impulse.playerMenu) and LocalPlayer():Alive() then
			impulse.playerMenu = vgui.Create("impulsePlayerMenu")
		elseif input.IsKeyDown(KEY_LALT) and LocalPlayer():Alive() then
			local trace = {}
			trace.start = LocalPlayer():EyePos()
			trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
			trace.filter = LocalPlayer()

			local traceEnt = util.TraceLine(trace).Entity

			if (not impulse.entityMenu or not IsValid(impulse.entityMenu)) and IsValid(traceEnt) then
				if traceEnt:IsDoor() then
					local doorOwners = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
					local doorGroup =  traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)
					local doorBuyable = traceEnt:GetSyncVar(SYNC_DOOR_BUYABLE, true)

					if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) or LocalPlayer():CanLockUnlockDoor(doorOwners, doorGroup) then
						impulse.entityMenu = vgui.Create("impulseEntityMenu")
						impulse.entityMenu:SetDoor(traceEnt)
					end
				elseif traceEnt:IsPlayer() then
					impulse.entityMenu = vgui.Create("impulseEntityMenu")
					impulse.entityMenu:SetRangeEnt(traceEnt)
					impulse.entityMenu:SetPlayer(traceEnt)
				end
			end
		end
	end

	if (nextLoopThink or 0) < CurTime() then
		for v,k in pairs(player.GetAll()) do
			local isArrested = k:GetSyncVar(SYNC_ARRESTED, false)
			local isBleeding = k:GetSyncVar(SYNC_BLEEDING, false)

			if isArrested != (k.BoneArrested or false) then
				k:SetHandsBehindBack(isArrested)
				k.BoneArrested = isArrested
			end

			local bleedingRange = (impulse.GetSetting("perf_bleedingrange") or 800) ^ 2
			local dist = k:GetPos():DistToSqr(LocalPlayer():GetPos())

			if isBleeding and dist < bleedingRange and (k.nextBleed or 0) < CurTime() and k:GetMoveType() != MOVETYPE_NOCLIP then
				local pos = k:GetPos()

				if dist < 300 then
					local effectdata = EffectData()
					effectdata:SetOrigin((pos + k:OBBCenter()))

					util.Effect("BloodImpact", effectdata)
				end

				if not k.lastBleedPos or (k.lastBleedPos:DistToSqr(k:GetPos()) > (40 ^ 2)) then
					util.Decal("Blood", pos, Vector(pos.x, pos.y, -100000), k)
					k.lastBleedPos = pos
				end

				k.nextBleed = CurTime() + math.random(5, 10)
			end

		end

		nextLoopThink = CurTime() + 0.5
	end
end

function IMPULSE:ScoreboardShow()
	if LocalPlayer():Team() == 0 then return end -- players who have not been loaded yet

    impulse_scoreboard = vgui.Create("impulseScoreboard")
end

function IMPULSE:ScoreboardHide()
	if LocalPlayer():Team() == 0 then return end -- players who have not been loaded yet
	
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
	impulse.DefineSetting("perf_blur", {name="Blur enabled", category="Performance", type="tickbox", default=true})
	impulse.DefineSetting("perf_bleedingrange", {name="Bleeding render range", category="Performance", type="slider", default=1000, minValue=200, maxValue=3000})
	impulse.DefineSetting("inv_sortbyweight", {name="Sort by weight", category="Inventory", type="tickbox", default=false})
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

	if IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible() and not impulse.MainMenu.popup then
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

		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = 50
			else
				targetpos.z = 40
			end
		end

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

local blackandwhite = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function IMPULSE:RenderScreenspaceEffects()
	if impulse.hudEnabled == false or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) then
		return
	end

	if LocalPlayer():Health() < 20 then
		DrawColorModify(blackandwhite)
	end
end

function IMPULSE:StartChat()
	net.Start("impulseChatState")
	net.WriteBool(true)
	net.SendToServer()
end

function IMPULSE:FinishChat()
	net.Start("impulseChatState")
	net.WriteBool(false)
	net.SendToServer()
end

function IMPULSE:OnContextMenuOpen()
	if LocalPlayer():Team() == 0 or not LocalPlayer():Alive() then return end

	impulse_inventory = vgui.Create("impulseInventory")
	gui.EnableScreenClicker(true)
end

function IMPULSE:OnContextMenuClose()
	if IsValid(impulse_inventory) then
		impulse_inventory:Remove()
		gui.EnableScreenClicker(false)
	end
end

concommand.Add("impulse_togglethirdperson", function() -- ease of use command for binds
	impulse.SetSetting("view_thirdperson", (!impulse.GetSetting("view_thirdperson")))
end)