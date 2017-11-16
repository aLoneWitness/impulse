function meta:inventorySave()
    impulse.DB.query("UPDATE impulse_pd SET inventory = "..SQLStr(pon.endcode(self.Inventory)).."WHERE steamid = "..self:SteamID(),"INVENTORY-SET")
end

