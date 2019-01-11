/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

util.AddNetworkString("IMPULSE_InitializeVars")
util.AddNetworkString("IMPULSE_PlayerVar")
util.AddNetworkString("IMPULSE_PlayerVarRemoval")
util.AddNetworkString("IMPULSE_impulseVarDisconnect")

--hook.Add("PlayerLoadout", "IMPULSE-CONFIGSET", function(player)
	--player:SetRunSpeed(impulse.Config.JogSpeed)
	--player:SetWalkSpeed(impulse.Config.WalkSpeed)
--end)

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
            if not target.impulseVars then return end
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


impulse.chatID = impulse.chatID or 0

function IMPULSE:PlayerSay(player,text,teamChat)
   if teamChat == true then return text end -- teamchat is not used for commands
   if not string.StartWith(text, "/") then return text end
    for v,k in pairs(impulse.chatcommands) do -- loop through all commands
		if "/"..k[1] == string.sub(string.lower(text), 1, string.len(k[1])+1) then -- if what they typed is a command
		   local input = string.sub(text, string.len(k[1])+3)
		   local args = string.Explode(" ", text) -- split the string into each word (argument)
           table.remove(args, 1)
           impulse.chatID = impulse.chatID +1
           k[3](player, args, input, impulse.chatID) -- Run command function (Add arg)
           return ""
       end
    end
	return text
end


function IMPULSE:PlayerHurt(victim, attacker, healthLeft, damageTaken) -- WARNING, I NEED REPLACING WITH A CLIENT BASED MORE EFFICIENT SYSTEM!
    if victim:IsPlayer() then
        victim:ScreenFade(SCREENFADE.IN, Color(255,255,255,130), 0.5, 0.1) -- Shock effect
    end
end
