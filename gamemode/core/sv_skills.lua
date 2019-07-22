function meta:GetSkill(name, fallback)
	local skills = self.impulseSkills
	if not skills then return end

	if skills[name] then
		return skills[name]
	else
		return (fallback or 1)
	end
end

function meta:SetSkill(name, value)
	if not self.impulseSkills then return end

	self.impulseSkills[name] = value

	local data = util.TableToJSON(self.impulseSkills)

	if data then
		local query = mysql:Update("impulse_players")
		query:Update("skills", data)
		query:Where("steamid", self:SteamID())
		query:Execute()
	end
end

function meta:AddSkill(name, value)
	if not self.impulseSkills then return end

	local cur = self:GetSkill(name, 1)
	local new = math.Clamp(cur + value, 1, 100)

	if cur != new then
		self:SetSkill(name, new)
	end
end