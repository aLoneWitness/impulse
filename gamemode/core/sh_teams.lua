/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Teams = impulse.Teams or {}
impulse.Teams.Data = {}

function impulse.Teams.Define(teamData)
    local teamID = #impulse.Teams.Data
    teamData.Default = teamData.Default or false
    teamData.Classes = teamData.Classes or {}
    teamData.Ranks = teamData.Ranks or {}
    teamData.FemaleModels = teamData.FemaleModels or teamData.MaleModels
    team.SetUp(teamID, teamData.Name, teamData.Color, false)

    impulse.Teams.Data[teamData.Name] = teamData
    return teamID
end