/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

util.AddNetworkString("IMPULSE_InitializeVars")
util.AddNetworkString("IMPULSE_PlayerVar")
util.AddNetworkString("IMPULSE_PlayerVarRemoval")
util.AddNetworkString("IMPULSE_impulseVarDisconnect")

function meta:removeIVar(var, target)
    target = target or player.GetAll()
    self.impulseVars = self.impulseVars or {}
    self.impulseVars[var] = nil

    net.Start("impulse_PlayerVarRemoval")
        net.WriteUInt(self:UserID(), 16)
        impulse.writeNetimpulseVarRemoval(var)
    net.Send(target)
end

function meta:setIVar(var, value, target)
    if not IsValid(self) then return end
    target = target or player.GetAll()

    if value == nil then return self:removeimpulseVar(var, target) end

    self.impulseVars = self.impulseVars or {}
    self.impulseVars[var] = value

    net.Start("impulse_PlayerVar")
        net.WriteUInt(self:UserID(), 16)
        impulse.writeNetimpulseVar(var, value)
    net.Send(target)
end

function meta:setSelfIVar(var, value)
    self.privateDRPVars = self.privateDRPVars or {}
    self.privateDRPVars[var] = true

    self:setIVar(var, value, self)
end

function meta:getimpulseVar(var)
    self.impulseVars = self.impulseVars or {}
    return self.impulseVars[var]
end

function meta:sendIVars()
    if self:EntIndex() == 0 then return end

    local plys = player.GetAll()

    net.Start("impulse_InitializeVars")
        net.WriteUInt(#plys, 8)
        for _, target in pairs(plys) do
            net.WriteUInt(target:UserID(), 16)

            local impulseVars = {}
            for var, value in pairs(target.impulseVars) do
                if self ~= target and (target.privateDRPVars or {})[var] then continue end
                table.insert(impulseVars, var)
            end

            net.WriteUInt(#impulseVars, impulse.impulse_ID_BITS + 2) -- Allow for three times as many unknown impulseVars than the limit
            for i = 1, #impulseVars, 1 do
                impulse.writeNetimpulseVar(impulseVars[i], target.impulseVars[impulseVars[i]])
            end
        end
    net.Send(self)
end
concommand.Add("_sendimpulsevars", function(ply)
    if ply.impulseVarsSent and ply.impulseVarsSent > (CurTime() - 3) then return end -- prevent spammers
    ply.impulseVarsSent = CurTime()
    ply:sendIVars()
end)

impulse.chatcommands = {}

function impulse.RegisterChatCommand(commanddata,func)
    local name = "/"..commanddata.name
    local desc = commanddata.desc or ""
    local table = {name,desc,func}
    table.insert(impulse.chatcommands, table)
end

function IMPULSE:PlayerSay(player,text,teamChat)
   if teamChat then return text end -- teamchat is not used for commands
    for v,k in pairs(impulse.chatcommands) do -- loop through all commands
       if k[1]==string.lower(text) then -- if what they typed is a command
           local args = string.Explode(" ", text) -- split the string into each word (argument)
           args[1]=nil -- lets not send the actual command
           k[3](args) -- Run command function (Add arg)
       end
    end
end
