meta.OldSetTeam = meta.OldSetTeam or meta.SetTeam
function meta:SetTeam(teamID, forced)
	local teamData = impulse.Teams.Data[teamID]
	local teamPlayers = team.NumPlayers(teamID)

	if teamData.model then
		self:SetModel(teamData.model)
	else
		self:SetModel(self.defaultModel)
	end

	if teamData.skin then
		self:SetSkin(teamData.skin)
	elseif not teamData.model then
		self:SetSkin(self.defaultSkin)
	end

	if teamData.bodygroups then
		for v, bodygroupData in pairs(teamData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	else
		self:SetBodyGroups("0000000")
	end

	self:StripWeapons()
	self:ClearRestrictedInventory()
	
	if teamData.loadout then
		for v,weapon in pairs(teamData.loadout) do
			self:Give(weapon)
		end
	end

	hook.Run("OnPlayerChangedTeam", self, self:Team(), teamID)

	self:SetLocalSyncVar(SYNC_CLASS, nil, true)
	self:SetLocalSyncVar(SYNC_RANK, nil, true)
	self:OldSetTeam(teamID)
	self:SetupHands()

	hook.Run("UpdatePlayerSync", self)

	if teamData.onBecome then
		teamData.onBecome(self)
	end

	return true
end

function meta:SetTeamClass(classID, skipLoadout)
	local teamData = impulse.Teams.Data[self:Team()]
	local classData = teamData.classes[classID]
	local classPlayers = 0

	if classData.model then
		self:SetModel(classData.model)
	else
		self:SetModel(teamData.model or self.defaultModel)
	end

	self:SetupHands()

	if classData.skin then
		self:SetSkin(classData.skin)
	else
		self:SetSkin(teamData.skin or self.defaultSkin)
	end

	if classData.bodygroups then
		for v, bodygroupData in pairs(classData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	elseif teamData.bodygroups then
		for v, bodygroupData in pairs(teamData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	else
		self:SetBodyGroups("0000000")
	end

	if not skipLoadout then
		self:StripWeapons()

		if classData.loadout then
			for v,weapon in pairs(classData.loadout) do
				self:Give(weapon)
			end
		else
			for v,weapon in pairs(teamData.loadout) do
				self:Give(weapon)
			end

			if classData.loadoutAdd then
				for v,weapon in pairs(classData.loadoutAdd) do
					self:Give(weapon)
				end
			end
		end
	end

	if classData.onBecome then
		classData.onBecome(self)
	end

	self:SetLocalSyncVar(SYNC_CLASS, classID, true)

	hook.Run("PlayerChangeClass", self, classID, classData.name)

	return true
end

function meta:SetTeamRank(rankID)
	local teamData = impulse.Teams.Data[self:Team()]
	local classData = teamData.classes[self:GetTeamClass()]
	local rankData = teamData.ranks[rankID]

	if rankData.model then
		self:SetModel(rankData.model)
	end

	self:SetupHands()

	if rankData.skin then
		self:SetSkin(rankData.skin)
	end

	if rankData.bodygroups then
		for v, bodygroupData in pairs(rankData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	elseif teamData.bodygroups then
		for v, bodygroupData in pairs(teamData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	else
		self:SetBodyGroups("0000000")
	end

	self:StripWeapons()

	if rankData.loadout then
		for v,weapon in pairs(rankData.loadout) do
			self:Give(weapon)
		end
	else
		for v,weapon in pairs(teamData.loadout) do
			self:Give(weapon)
		end

		if classData and classData.loadoutAdd then
			for v,weapon in pairs(classData.loadoutAdd) do
				self:Give(weapon)
			end
		end

		if rankData.loadoutAdd then
			for v,weapon in pairs(rankData.loadoutAdd) do
				self:Give(weapon)
			end
		end
	end

	if rankData.onBecome then
		rankData.onBecome(self)
	end

	self:SetLocalSyncVar(SYNC_RANK, rankID, true)

	return true
end

function meta:AddTeamTime(time)
	-- if not self.beenSetup then
	-- 	return
	-- end
	
	-- local rankTable = self.impulseRanks
	-- local teamTime = rankTable[self:Team()]

	-- if not teamTime then
	-- 	rankTable[self:Team()] = 0
	-- 	teamTime = 0
	-- end

	-- rankTable[self:Team()] = teamTime + (time / 60)

	-- local query = mysql:Update("impulse_players")
	-- query:Update("ranks", util.TableToJSON(rankTable))
	-- query:Where("steamid", self:SteamID())
	-- query:Execute(true) -- queued
end

-- function meta:SetTeamWhitelist(type, level)
-- 	local data = self:GetData()
-- 	data.whitelists = data.whitelists or {}

-- 	data.whitelists[type] = level

-- 	self:SaveData()
-- end

-- function meta:GetTeamWhitelist(type)
-- 	local data = self:GetData()
-- 	local whitelist = data.whitelists

-- 	if whitelist and whitelist[type] then
-- 		return whitelist[type]
-- 	end
-- end

-- function meta:HasTeamWhitelist(type, level)
-- 	local whitelistLevel = self:GetTeamWhitelist(type)

-- 	if whitelistLevel and not level then
-- 		return true
-- 	elseif whitelistLevel and level <= whitelistLevel then
-- 		return true
-- 	end

-- 	return false
-- end