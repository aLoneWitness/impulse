
function meta:SetHandsBehindBack(state)
	if CLIENT then
	    local L_UPPERARM = self:LookupBone("ValveBiped.Bip01_L_UpperArm")
	    local R_UPPERARM = self:LookupBone("ValveBiped.Bip01_R_UpperArm")
	    local L_FOREARM = self:LookupBone("ValveBiped.Bip01_L_Forearm" )
	    local R_FOREARM = self:LookupBone("ValveBiped.Bip01_R_Forearm" )
	    local L_HAND = self:LookupBone("ValveBiped.Bip01_L_Hand" ) 
	    local R_HAND = self:LookupBone("ValveBiped.Bip01_R_Hand" )
			
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
	else
		self:SetSyncVar(SYNC_ARRESTED, state, true)
	end
end

function meta:CanArrest(cuffer)
	if not cuffer then return true end -- server can arrest anyone

	if self:IsCP() then
		return false
	end

	return true
end

if SERVER then
	function meta:Arrest()
		self.ArrestedWeapons = {}
		for v,k in pairs(self:GetWeapons()) do
			self.ArrestedWeapons[k:GetClass()] = true
		end

		self:SetHandsBehindBack(true)
		self:StripWeapons()
		self:StripAmmo()
		self:SetRunSpeed(impulse.Config.WalkSpeed - 30)
		self:SetWalkSpeed(impulse.Config.WalkSpeed - 30)

		self.Arrested = true
	end

	function meta:UnArrest()
		if self.ArrestedWeapons then
			for v,k in pairs(self.ArrestedWeapons) do
				self:Give(v)
			end
		end

		self:SetRunSpeed(impulse.Config.JogSpeed)
		self:SetWalkSpeed(impulse.Config.WalkSpeed)

		self:SetHandsBehindBack(false)
		self.Arrested = false
	end
end