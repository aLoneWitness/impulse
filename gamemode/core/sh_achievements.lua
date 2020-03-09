impulse.Achievements = impulse.Achievements or {}

if SERVER then
	function meta:AchievementGive(name, skipPoints)
		if not self.impulseData then
			return
		end

		self.impulseData.Achievements = self.impulseData.Achievements or {}
		if self.impulseData.Achievements[name] then
			return
		end

		self.impulseData.Achievements[name] = math.floor(os.time())
		self:SaveData()

		net.Start("impulseAchievementGet")
		net.WriteString(name)
		net.Send(self)

		if not skipPoints then
			self:CalculateAchievementPoints()
		end
	end

	function meta:AchievementTake(name)
		if not self.impulseData then
			return
		end

		self.impulseData.Achievements = self.impulseData.Achievements or {}
		self.impulseData.Achievements[name] = nil
		self:SaveData()
	end

	function meta:AchievementHas(name)
		if not self.impulseData then
			return false
		end

		self.impulseData.Achievements = self.impulseData.Achievements or {}

		if self.impulseData.Achievements[name] then
			return true
		end

		return false
	end

	function meta:AchievementCheck(name)
		if not self.impulseData then
			return
		end

		self.impulseData.Achievements = self.impulseData.Achievements or {}
		local ach = impulse.Config.Achievements[name]

		if ach.OnJoin and ach.Check and not self:AchievementHas(name) and ach.Check(self) then
			self:AchievementGive(name)
		end
	end

	function meta:CalculateAchievementPoints()
		if not self.impulseData then
			return 0
		end

		local val = 0

		for v,k in pairs(self.impulseData.Achievements) do
			val = val + 60
		end

		self:SetSyncVar(SYNC_TROPHYPOINTS, val, true)
	end
end