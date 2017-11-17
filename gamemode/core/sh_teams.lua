impulse.team = {}


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

if SERVER then
    function IMPULSE:OnPlayerChangeTeam(player,oldteam,newteam)
        player:SetIVar("job",team.GetName(newteam))
    end
    
    
    function impulse.team.updateranks()
        for v,k in pairs(player.GetAll()) do
            local job =  k:Team()
            local rank = v:GetRank()
            if impulse.team.teams[job].ranks and hook.Run('ShouldUpdateRank',k,job,rank) then
               k.jobPlaytime[job] = v.jobPlaytime[job] or 0
               k.jobPlaytimep[job] = k.jobPlaytime[job] + impulse.GetConfig().rankUpdateTime
               
               k:CheckForPromotion()
               k:SaveRanks()
            end
        
    end
    
    timer.Create("IMPULSE-JOB-RANK-UPDT", impulse.GetConfig().rankUpdateTime, 0, impulse.team.updateranks)
    


end