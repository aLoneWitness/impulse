function meta:SetMoney(value)
    self:setIVar("money",value)
    impulse.DB.query("UPDATE impulse_pd SET money = "..value.." WHERE steamid = '"..self:SteamID().." '")
end

function meta:GetMoney()
   return tonumber(impulse.DB.query("SELECT money FROM impulse_pd WHERE steamid = '"..self:SteamID().."'"))
end

function meta:CanAfford(cost)
   return cost <= (self:GetMoney() or 0) 
end

function meta:GiveMoney(amount)
    return self:setMoney(self:GetMoney()+amount)
end

function meta:TakeMoney(amount)
    return self:setMoney(self:GetMoney()-amount)
end

function meta:SetBank(value)
    return impulse.DB.query("UPDATE impulse_pd SET atm = "..value.." WHERE steamid = '"..self:SteamID().." '")
end