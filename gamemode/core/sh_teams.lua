/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Teams = impulse.Teams or {}
impulse.Teams.Data = impulse.Teams.Data or {}
teamID = 0

function impulse.Teams.Define(teamData)
    teamID = teamID + 1
    print(teamID)
    teamData.classes = teamData.classes or {}
    teamData.ranks = teamData.ranks or {}
    team.SetUp(teamID, teamData.name, teamData.color, false)

    impulse.Teams.Data[teamData.name] = teamData
    return teamID
end