impulse.team = {}
impulse.team.teams = {}

function impulse.team.define(data_table)
    team.SetUp( data_table.id, data_table.name, data_table.color ) -- Hooking into the source engine team system
    impulse.team.teams[data_table.id] = data_table
    if (CLIENT) then
        for v,k in pairs(data_table.models) do 
            impulse.PrepModelForLoad(k) -- We will load all the player models when people load
        end
    end
    return data_table.id -- return the teams unique id to be stored as the team name EG: TEAM_VISITOR
end

function meta:IsCP() -- function to check if the team has authority
    return impulse.team.teams[self:Team()].iscp
end