/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Teams = impulse.Teams or {}
impulse.Teams.Data = impulse.Teams.Data or {}
impulse.Teams.ClassRef = impulse.Teams.ClassRef or {}
teamID = 0

function impulse.Teams.Define(teamData)
    teamID = teamID + 1
    impulse.Teams.Data[teamID] = teamData

    if teamData.classes then
    	impulse.Teams.Data[teamID].ClassRef = {}

    	for id,k in pairs(teamData.classes) do
    		impulse.Teams.Data[teamID].ClassRef[id] = k.name
    	end
    end

    team.SetUp(teamID, teamData.name, teamData.color, false)
    return teamID
end

if SERVER then
	meta.OldSetTeam = meta.OldSetTeam or meta.SetTeam
	function meta:SetTeam(teamID, forced)
		local teamData = impulse.Teams.Data[teamID]
		local teamPlayers = team.NumPlayers(teamID)
		local forced = forced or false

		if teamData.xp and teamData.xp > self:GetXP() and forced == false then
			self:Notify("You don't have the XP required to play as this team.")
			return false
		end

		if teamData.limit and forced == false then
			if teamData.percentLimit and teamData.percentLimit == true then
				local percentTeam = teamPlayers / #player.GetAll()
				if not self:IsDonator() and percentTeam > teamData.limit then
					self:Notify(teamData.name .. " is full.")
					return false
				end
			else
				if not self:IsDonator() and teamData.limit >= teamPlayers then
					self:Notify(teamData.name .. " is full.")
					return false
				end
			end
		end

		if teamData.model then
			self:SetModel(teamData.model)
		else
			self:SetModel(self.defaultModel)
		end

		self:SetupHands()

		if teamData.skin then
			self:SetSkin(teamData.skin)
		elseif not teamData.model then
			self:SetSkin(self.defaultSkin)
		end

		if teamData.bodygroups then
			for v, bodygroupData in pairs(teamData.bodygroups) do
				self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodyGroupCount(bodygroupData[1]))))
			end
		else
			self:SetBodyGroups("0000000")
		end

		self:StripWeapons()
		if teamData.loadout then
			for v,weapon in pairs(teamData.loadout) do
				self:Give(weapon)
			end
		end

		self:SetLocalSyncVar(SYNC_CLASS, nil, true)
		self:OldSetTeam(teamID)

		return true
	end

	function meta:SetTeamClass(classID, forced)
		local teamData = impulse.Teams.Data[self:Team()]
		local classData = teamData.classes[classID]
		local forced = forced or false
		local classPlayers = 0
		
		if classData.xp and classData.xp > self:GetXP() and forced == false then
			self:Notify("You don't have the XP required to play as this class.")
			return false
		end

		if classData.limit and forced == false then
			for v,k in pairs(player.GetAll()) do
				if k:GetTeamClass() == className then
					classPlayers = classPlayers + 1
				end
			end

			if classData.percentLimit and classData.percentLimit == true then
				local percentClass = classPlayers / #player.GetAll()
				if percentClass > classData.limit then
					self:Notify(classData.name .. " is full.")
					return false
				end
			else
				if classData.limit >= classPlayers then
					self:Notify(classData.name .. " is full.")
					return false
				end
			end
		end

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
				self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodyGroupCount(bodygroupData[1]))))
			end
		elseif teamData.bodygroups then
			for v, bodygroupData in pairs(teamData.bodygroups) do
				self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodyGroupCount(bodygroupData[1]))))
			end
		else
			self:SetBodyGroups("0000000")
		end

		self:StripWeapons()
		if classData.loadout then
			for v,weapon in pairs(teamData.loadout) do
				self:Give(weapon)
			end
		end

		self:SetLocalSyncVar(SYNC_CLASS, classID, true)

		return true
	end
end

function meta:GetTeamClassName()
	local classRef = impulse.Teams.Data[self:Team()].ClassRef
	local plyClass = self:GetSyncVar(SYNC_CLASS, nil)

	if classRef and plyClass then
		return classRef[plyClass]
	end

	return "Default"
end

function meta:GetTeamClass()
	return self:GetSyncVar(SYNC_CLASS, 0)
end

function meta:IsCP()
	return impulse.Teams.Data[self:Team()].cp or false
end