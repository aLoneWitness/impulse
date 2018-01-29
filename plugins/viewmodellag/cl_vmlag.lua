local cl_vm_lag_enabled = CreateClientConVar("cl_vm_lag_enabled", "1", true)
local cl_vm_lag_scale = CreateClientConVar("cl_vm_lag_scale", "1.5", true)

local function VectorMA( start, scale, direction, dest )
	dest.x = start.x + direction.x * scale
	dest.y = start.y + direction.y * scale
	dest.z = start.z + direction.z * scale
end

local function CalcViewModelLag(vm, origin, angles, original_angles)
	local vOriginalOrigin = Vector(origin.x, origin.y, origin.z);
	local vOriginalAngles = Angle(angles.x, angles.y, angles.z);

	vm.m_vecLastFacing = vm.m_vecLastFacing or angles:Forward()

	local forward = angles:Forward();

	if (FrameTime() != 0.0) then
		local vDifference = forward - vm.m_vecLastFacing;

		local flSpeed = 5.0;

		local flDiff = vDifference:Length();
		if ( (flDiff > cl_vm_lag_scale:GetFloat()) and (cl_vm_lag_scale:GetFloat() > 0.0) ) then
			local flScale = flDiff / cl_vm_lag_scale:GetFloat();
			flSpeed = flSpeed * flScale;
		end

		VectorMA(vm.m_vecLastFacing, flSpeed * FrameTime(), vDifference, vm.m_vecLastFacing);

		vm.m_vecLastFacing:Normalize()
		VectorMA(origin, 5.0, vDifference * -1.0, origin);
	end

	local right, up;
	right = original_angles:Right()
	up = original_angles:Up()

	local pitch = original_angles[1];

	if (pitch > 180.0) then
		pitch = pitch - 360.0;
	elseif (pitch < -180.0) then
		pitch = pitch + 360.0;
	end

	if (cl_vm_lag_scale:GetFloat() == 0.0) then
		origin = vOriginalOrigin;
		angles = vOriginalAngles;
	end

	VectorMA(origin, -pitch * 0.035, forward, origin);
	VectorMA(origin, -pitch * 0.03, right,	origin);
	VectorMA(origin, -pitch * 0.02, up, origin);
end


do
	local function doLag(weapon, vm, oldPos, oldAng, pos, ang)
		if (IsValid(weapon) and weapon.GetIronSights and weapon:GetIronSights()) then
			vm.m_vecLastFacing = ang:Forward()
		else
			CalcViewModelLag(vm, pos, ang, oldAng)
		end
	end

	if (cl_vm_lag_enabled:GetInt() != 0) then
		hook.Add("CalcViewModelView", "HL2ViewModelSway", doLag)
	end

	cvars.AddChangeCallback("cl_vm_lag_enabled", function(var, old, new)
		if (tonumber(new) != 0) then
			hook.Add("CalcViewModelView", "HL2ViewModelSway", doLag)
		else
			hook.Remove("CalcViewModelView", "HL2ViewModelSway")
		end
	end)
end
