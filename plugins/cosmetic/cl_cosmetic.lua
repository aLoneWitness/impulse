impulse.Cosmetics = impulse.Cosmetics or {}

function MakeCosmetic(ply, id, bone, data, slot)
	ply.Cosmetics = ply.Cosmetics or {}

	SafeRemoveEntity(ply.Cosmetics[slot])

	ply.Cosmetics[slot] = ClientsideModel(data.model, RENDERGROUP_OPAQUE)
	ply.Cosmetics[slot]:SetNoDraw(true)

	if data.bodygroups then
		ply.Cosmetics[slot]:SetBodyGroups(data.bodygroups)
	end

	if ply:IsFemale() and data.femaleScale then
		ply.Cosmetics[slot]:SetModelScale(ply.Cosmetics[slot]:GetModelScale() * data.femaleScale)
	else
		ply.Cosmetics[slot]:SetModelScale(ply.Cosmetics[slot]:GetModelScale() * data.scale)
	end

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
			local isFemale = k:IsFemale()

			if isFemale and b.drawdata.femalePos then
				pos = pos + (r * b.drawdata.femalePos.x) + (f * b.drawdata.femalePos.y) + (u * b.drawdata.femalePos.z)
			else
				pos = pos + (r * b.drawdata.pos.x) + (f * b.drawdata.pos.y) + (u * b.drawdata.pos.z)
			end

			b:SetRenderOrigin(pos)

			if isFemale and b.drawdata.femaleAng then
				ang:RotateAroundAxis(f, b.drawdata.femaleAng.p)
				ang:RotateAroundAxis(u, b.drawdata.femaleAng.y)
				ang:RotateAroundAxis(r, b.drawdata.femaleAng.r)
			else
				ang:RotateAroundAxis(f, b.drawdata.ang.p)
				ang:RotateAroundAxis(u, b.drawdata.ang.y)
				ang:RotateAroundAxis(r, b.drawdata.ang.r)
			end

			b:SetRenderAngles(ang)
			b:DrawModel()
		end
	end

	local faceCos = k:GetSyncVar(SYNC_COS_FACE) -- uses bone 6 face
	local hatCos = k:GetSyncVar(SYNC_COS_HEAD) -- uses bone 6 face
	local chestCos = k:GetSyncVar(SYNC_COS_CHEST) -- uses bone 1 spine

	if faceCos then
		if faceCos != (k.lastFace or -1) then
			MakeCosmetic(k, faceCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[faceCos], 1)
			k.lastFace = faceCos
		end  
	elseif k.Cosmetics and k.Cosmetics[1] and IsValid(k.Cosmetics[1]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[1], 1)
		k.lastFace = -1
	end

	if hatCos then
		if hatCos != (k.lastHat or -1) then
			MakeCosmetic(k, hatCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[hatCos], 2)
			k.lastHat = hatCos
		end  
	elseif k.Cosmetics and k.Cosmetics[2] and IsValid(k.Cosmetics[2]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[2], 2)
		k.lastHat = -1
	end

	if chestCos then
		if chestCos != (k.lastChest or -1) then
			MakeCosmetic(k, chestCos, "ValveBiped.Bip01_Spine2", impulse.Cosmetics[chestCos], 3)
			k.lastChest = hatCos
		end  
	elseif k.Cosmetics and k.Cosmetics[3] and IsValid(k.Cosmetics[3]) then -- cosmetic removed
		RemoveCosmetic(k, k.Cosmetics[3], 3)
		k.lastChest = -1
	end
end)

hook.Add("SetupInventoryModel", "impulseDrawCosmetics", function(panel)
	panel.lastFaceI = -1
	panel.lastHatI = -1
	panel.lastChestI = -1

	function panel:PostDrawModel(k)
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
				local isFemale = k:IsFemale()

				if isFemale and b.drawdata.femalePos then
					pos = pos + (r * b.drawdata.femalePos.x) + (f * b.drawdata.femalePos.y) + (u * b.drawdata.femalePos.z)
				else
					pos = pos + (r * b.drawdata.pos.x) + (f * b.drawdata.pos.y) + (u * b.drawdata.pos.z)
				end

				b:SetRenderOrigin(pos)

				if isFemale and b.drawdata.femaleAng then
					ang:RotateAroundAxis(f, b.drawdata.femaleAng.p)
					ang:RotateAroundAxis(u, b.drawdata.femaleAng.y)
					ang:RotateAroundAxis(r, b.drawdata.femaleAng.r)
				else
					ang:RotateAroundAxis(f, b.drawdata.ang.p)
					ang:RotateAroundAxis(u, b.drawdata.ang.y)
					ang:RotateAroundAxis(r, b.drawdata.ang.r)
				end
				
				b:SetRenderAngles(ang)
				b:DrawModel()
			end
		end

		local faceCos = LocalPlayer():GetSyncVar(SYNC_COS_FACE) -- uses bone 6 face
		local hatCos = LocalPlayer():GetSyncVar(SYNC_COS_HEAD) -- uses bone 6 face
		local chestCos = LocalPlayer():GetSyncVar(SYNC_COS_CHEST) -- uses bone 1 spine

		if faceCos then
			if faceCos != self.lastFaceI then
				MakeCosmetic(k, faceCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[faceCos], 1)
				self.lastFaceI = faceCos
			end  
		elseif k.Cosmetics and k.Cosmetics[1] and IsValid(k.Cosmetics[1]) then -- cosmetic removed
			RemoveCosmetic(k, k.Cosmetics[1], 1)
			self.lastFaceI = -1
		end

		if hatCos then
			if hatCos != self.lastHatI then
				MakeCosmetic(k, hatCos, "ValveBiped.Bip01_Head1", impulse.Cosmetics[hatCos], 2)
				self.lastHatI = hatCos
			end  
		elseif k.Cosmetics and k.Cosmetics[2] and IsValid(k.Cosmetics[2]) then -- cosmetic removed
			RemoveCosmetic(k, k.Cosmetics[2], 2)
			self.lastHatI = -1
		end

		if chestCos then
			if chestCos != self.lastChestI then
				MakeCosmetic(k, chestCos, "ValveBiped.Bip01_Spine2", impulse.Cosmetics[chestCos], 3)
				self.lastChestI = hatCos
			end  
		elseif k.Cosmetics and k.Cosmetics[3] and IsValid(k.Cosmetics[3]) then -- cosmetic removed
			RemoveCosmetic(k, k.Cosmetics[3], 3)
			self.lastChestI = -1
		end
	end
end)