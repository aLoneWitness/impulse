/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

util.AddNetworkString("IMPULSE_InitializeVars")
util.AddNetworkString("IMPULSE_PlayerVar")
util.AddNetworkString("IMPULSE_PlayerVarRemoval")
util.AddNetworkString("IMPULSE_impulseVarDisconnect")


-- impulse uses keys instead of rcon, do not touch this system

local function stringRandom(length)
	local str = "";
	for i = 1, length do
		str = str..string.char(math.random(97, 122));
	end
	return string.upper(str);
end


local function GenerateKey()
    return stringRandom(5).."-"..stringRandom(5).."-"..stringRandom(5).."-"..stringRandom(5)
end

if not file.IsDir("impulse", "DATA") and not file.Exists("impulse/serverkey.dat", "DATA") then
	file.CreateDir("impulse")
	impulse.key = GenerateKey()
	file.Write("impulse/serverkey.dat", impulse.key)
else
	impulse.key = file.Read("impulse/serverkey.dat","DATA")
end


MsgC(Color(0,255,0), "[IMPULSE] Server key: ["..(impulse.key or "MAJOR ERROR PLEASE CLOSE SERVER").."]. Keep this secret!\n")

local nexttry

concommand.Add("impulse_sudokey", function(ply,cmd,args)
	local antiSpam = nexttry or 0

	if CurTime() > antiSpam  then
		if args[1] and string.upper(args[1]) == impulse.key then
			ply:AddChatText(Color(0,255,0), "[IMPULSE] Sudo key accepted.")
			ply.hasSudo = true
		elseif args[1] then
			ply:AddChatText(Color(0,255,0), "[IMPULSE] Sudo key rejected. You must wait 2 seconds before retrying.")
		end
	end
	nexttry = CurTime() + 2
end)

concommand.Add("impulse_sudo", function(ply,cmd,args)
	local antiSpam = nexttry or 0

	if CurTime() > antiSpam then
		nexttry = CurTime() + 0.3
		if not ply.hasSudo and not args[1] then return false end
		game.ConsoleCommand(args[1].."\n")
	end

end)

-- end of key system


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
