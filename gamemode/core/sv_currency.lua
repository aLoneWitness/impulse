function meta:setMoney(value)
    self:setIVar("money",value)
    return impulse.DB.query("UPDATE impulse_pd SET money = "..value.." WHERE steamid = '"..self:SteamID().." '")
end

function