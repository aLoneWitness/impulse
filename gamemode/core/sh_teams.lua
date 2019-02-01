/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Teams = impulse.Teams or {}
impulse.Teams.Data = impulse.Teams.Data or {}
teamID = 0

function impulse.Teams.Define(teamData)
    teamID = teamID + 1
    teamData.classes = teamData.classes or {}
    teamData.ranks = teamData.ranks or {}
    team.SetUp(teamID, teamData.name, teamData.color, false)

    impulse.Teams.Data[teamID] = teamData
    return teamID
end

meta.OldSetTeam = meta.OldSetTeam or meta.SetTeam
function meta:SetTeam(teamID, forced)
	local teamData = impulse.Teams.Data[teamID]
	local teamPlayers = team.NumPlayers(teamID)
	local forced = forced or false

	if teamData.limit and forced == false then
		if teamData.percentLimit and teamData.percentLimit == true then
			local percentTeam = teamPlayers / #player.GetAll()
			if percentTeam > teamData.limit then
				self:Notify(teamData.name .. " is full.")
				return
			end
		else
			if teamData.limit >= teamPlayers then
				self:Notify(teamData.name .. " is full.")
				return
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
	self:OldSetTeam(teamID)
end

function meta:SetClass(className, forced)
	local classData = impulse.Teams.Data[self:Team()].classes[className]
	local forced = forced or false
	
end

function meta:IsCP()
	return impulse.Teams.Data[self:Team()].cp or false
end