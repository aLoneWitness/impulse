util.AddNetworkString("IMPULSE_InitializeVars")
util.AddNetworkString("IMPULSE_PlayerVar")
util.AddNetworkString("IMPULSE_PlayerVarRemoval")
util.AddNetworkString("IMPULSE_DarkRPVarDisconnect")

function meta:removeIVar(var, target)
    hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, nil)
    target = target or player.GetAll()
    self.DarkRPVars = self.DarkRPVars or {}
    self.DarkRPVars[var] = nil


    net.Start("DarkRP_PlayerVarRemoval")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVarRemoval(var)
    net.Send(target)
end

function meta:setIVar(var, value, target)
    if not IsValid(self) then return end
    target = target or player.GetAll()

    if value == nil then return self:removeDarkRPVar(var, target) end
    hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

    self.DarkRPVars = self.DarkRPVars or {}
    self.DarkRPVars[var] = value

    net.Start("DarkRP_PlayerVar")
        net.WriteUInt(self:UserID(), 16)
        DarkRP.writeNetDarkRPVar(var, value)
    net.Send(target)
end

function meta:setSelfIVar(var, value)
    self.privateDRPVars = self.privateDRPVars or {}
    self.privateDRPVars[var] = true

    self:setDarkRPVar(var, value, self)
end

function meta:getDarkRPVar(var)
    self.DarkRPVars = self.DarkRPVars or {}
    return self.DarkRPVars[var]
end

function meta:sendIVars()
    if self:EntIndex() == 0 then return end

    local plys = player.GetAll()

    net.Start("DarkRP_InitializeVars")
        net.WriteUInt(#plys, 8)
        for _, target in pairs(plys) do
            net.WriteUInt(target:UserID(), 16)

            local DarkRPVars = {}
            for var, value in pairs(target.DarkRPVars) do
                if self ~= target and (target.privateDRPVars or {})[var] then continue end
                table.insert(DarkRPVars, var)
            end

            net.WriteUInt(#DarkRPVars, DarkRP.DARKRP_ID_BITS + 2) -- Allow for three times as many unknown DarkRPVars than the limit
            for i = 1, #DarkRPVars, 1 do
                DarkRP.writeNetDarkRPVar(DarkRPVars[i], target.DarkRPVars[DarkRPVars[i]])
            end
        end
    net.Send(self)
end
concommand.Add("_sendIvars", function(ply)
    if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 3) then return end -- prevent spammers
    ply.DarkRPVarsSent = CurTime()
    ply:sendDarkRPVars()
end)
