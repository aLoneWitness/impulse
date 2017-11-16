function meta:inventorySave()
    return impulse.DB.query("UPDATE impulse_pd SET inventory = "..SQLStr(pon.endcode(self.Inventory)).."WHERE steamid = '"..self:SteamID().."'","INVENTORY-SET")
end

function meta:inventoryGet()
    return impulse.DB.query("SELECT inventory FROM impulse_pd WHERE steamid = '"..self:SteamID().."'")
end