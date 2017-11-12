function meta:SetMoney(value)
    self:setIVar("money",value)
    return impulse.DB.query("UPDATE impulse_pd SET money = "..value.." WHERE steamid = '"..self:SteamID().." '")
end

function meta:CanAfford(cost)
   return cost <= (self:getIVar("money") or 0) 
end

function meta:GiveMoney(amount)
    self:setMoney(self:getIVar("money")+amount)
end

function meta:TakeMoney(amount)
    self:setMoney(self:getIVar("money")-amount)
end

function meta:SetBank(value)
    return impulse.DB.query("UPDATE impulse_pd SET atm = "..value.." WHERE steamid = '"..self:SteamID().." '")
end