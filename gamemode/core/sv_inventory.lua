function meta:inventorySave()
    return impulse.DB.query("UPDATE impulse_pd SET inventory = "..SQLStr(pon.endcode(self.Inventory)).."WHERE steamid = '"..self:SteamID().."'","INVENTORY-SET")
end

function meta:inventoryRead()
    self.Inventory = pon.decode(impulse.DB.query("SELECT inventory FROM impulse_pd WHERE steamid = '"..self:SteamID().."'")) -- may need to use util.KeyValuesToTable
end