function meta:SetRPName(name)
    self:setIVar("rpname",name)
    impulse.DB.query("UPDATE impulse_pd SET name = "..SQLStr(name).." WHERE steamid = '"..self:SteamID().."'")
end

function meta:GetRPName()
    return impulse.DB.query("SELECT name FROM impulse_pd WHERE steamid = '"..self:SteamID().."'")
end