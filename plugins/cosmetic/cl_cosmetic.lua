impulse.Cosmetics = impulse.Cosmetics or {}

function MakeCosmetic(ply, id, bone, data, slot)
	ply.Cosmetics = ply.Cosmetics or {}

	SafeRemoveEntity(ply.Cosmetics[slot])

	ply.Cosmetics[slot] = ClientsideModel(data.model, RENDERGROUP_OPAQUE)
	ply.Cosmetics[slot]:SetNoDraw(true)
	if data.bodygroups then
		ply.Cosmetics[slot]:SetBodyGroups(data.bodygroups)
	end
	ply.Cosmetics[slot]:SetModelScale(ply.Cosmetics[slot]:GetModelScale() * data.scale)
	ply.Cosmetics[slot].drawdata = data
	ply.Cosmetics[slot].bone = bone
	ply.Cosmetics[slot].owner = ply
end

local function RemoveCosmetic(ply, ent, slot)
	ply.Cosmetics[slot] = nil
	SafeRemoveEntity(ent)
end

local lastFace = -1
local lastHat = -1
local lastChest = -1

hook.Add("PostPlayerDraw", "impulseCosmeticDraw", function(k)
	if not k:Alive() then return end

	if k.Cosmetics then
		for a,b in pairs(k.Cosmetics) do
			if not IsValid(b) then continue end
			local bone = k:LookupBone(b.bone)

			if not bone then
				return
			end
			
			local matrix = k:GetBoneMatrix(bone)

			if not matrix then
				return
			end

			local pos = matrix:GetTranslation()
			local ang = matrix:GetAngles()
			local f = ang:Forward()
			local u = ang:Up()
			local r = ang:Right()
			pos = pos + (r * b.drawdata.pos.x) + (f * b.drawdata.pos.y) + (u * b.drawdata.pos.z)

			b:SetRenderOrigin(pos)
			ang:RotateAroundAxis(f, b.drawdata.ang.p)
			ang:RotateAroundAxis(u, b.drawdata.ang.y)
			ang:RotateAroundAxis(r, b.drawdata.ang.r)
			b:SetRenderAngles(ang)
			b:DrawModel()
		end
	end

	local faceCos = k:GetSyncVar(SYNC_COS_FACE) -- uses bone 6 face
	local hatCos = k:GetSyncVar(SYNC_COS_HEAD) -- uses bone 6 face
	local chestCos = k:GetSyncVar(SYNC_COS_CHEST) -- uses bone 1 spine

	if faceCos then
		if faceCos != lastFace then
			MakeCosmetic(k, faceCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[faceCos], 1)
			lastFace = faceCos
		end  
	elseif k.Cosmetics and k.Cosmetics[1] and IsValid(k.Cosmetics[1]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[1], 1)
		lastFace = -1
	end

	if hatCos then
		if hatCos != lastHat then
			MakeCosmetic(k, hatCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[hatCos], 2)
			lastHat = hatCos
		end  
	elseif k.Cosmetics and k.Cosmetics[2] and IsValid(k.Cosmetics[2]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[2], 2)
		lastHat = -1
	end

	if chestCos then
		if chestCos != lastChest then
			MakeCosmetic(k, chestCos, "ValveBiped.Bip01_Spine2", impulse.Cosmetics[chestCos], 3)
			lastChest = hatCos
		end  
	elseif k.Cosmetics and k.Cosmetics[3] and IsValid(k.Cosmetics[3]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[3], 3)
		lastChest = -1
	end
end)