function meta:SetHandsBehindBack(state)
	local L_UPPERARM = self:LookupBone("ValveBiped.Bip01_L_UpperArm")
	local R_UPPERARM = self:LookupBone("ValveBiped.Bip01_R_UpperArm")
	local L_FOREARM = self:LookupBone("ValveBiped.Bip01_L_Forearm")
	local R_FOREARM = self:LookupBone("ValveBiped.Bip01_R_Forearm")
	local L_HAND = self:LookupBone("ValveBiped.Bip01_L_Hand") 
	local R_HAND = self:LookupBone("ValveBiped.Bip01_R_Hand")
			
	if L_UPPERARM and R_UPPERARM and L_FOREARM and R_FOREARM and L_HAND and R_HAND then
		if state then
			if self:IsFemale() then
				self:ManipulateBoneAngles(L_UPPERARM, Angle(5, 5, 0))
				self:ManipulateBoneAngles(R_UPPERARM, Angle(-5, 10, 0))
				self:ManipulateBoneAngles(L_FOREARM, Angle(16, 5, 0))
				self:ManipulateBoneAngles(R_FOREARM, Angle(-16, 5, 0))         
				self:ManipulateBoneAngles(L_HAND, Angle(-25, -10, 0))
				self:ManipulateBoneAngles(R_HAND, Angle(25, -10, 0))
			else
				self:ManipulateBoneAngles(L_UPPERARM, Angle(5, 5, 0))
				self:ManipulateBoneAngles(R_UPPERARM, Angle(-5, 10, 0))
				self:ManipulateBoneAngles(L_FOREARM, Angle(25, 5, 0))
				self:ManipulateBoneAngles(R_FOREARM, Angle(-25, 5, 0))
				self:ManipulateBoneAngles(L_HAND, Angle(-25, -10, 0))                  
				self:ManipulateBoneAngles(R_HAND, Angle(25, -10, 0))           
			end
		else
			self:ManipulateBoneAngles(L_UPPERARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(R_UPPERARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(L_FOREARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(R_FOREARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(L_HAND, Angle(0, 0, 0))  
			self:ManipulateBoneAngles(R_HAND, Angle(0, 0, 0))  
		end
	end
end

function meta:CanArrest(arrested)
	if not arrested then return true end -- server can arrest anyone

	if not self:IsCP() then
		return false
	end

	if arrested:IsCP() then
		return false
	end

	return true
end