/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

local maxId = 0
local impulseVars = {}
local impulseVarById = {}

-- the amount of bits assigned to the value that determines which impulseVar we're sending/receiving
local impulse_ID_BITS = 8
local UNKNOWN_impulseVAR = 255 -- Should be equal to 2^impulse_ID_BITS - 1
impulse.impulse_ID_BITS = impulse_ID_BITS

function impulse.registerimpulseVar(name, writeFn, readFn)
    maxId = maxId + 1

    -- UNKNOWN_impulseVAR is reserved for unknown values
    if maxId >= UNKNOWN_impulseVAR then impulse.error(string.format("Too many impulseVar registrations! impulseVar '%s' triggered this error", name), 2) end

    impulseVars[name] = {id = maxId, name = name, writeFn = writeFn, readFn = readFn}
    impulseVarById[maxId] = impulseVars[name]
end

-- Unknown values have unknown types and unknown identifiers, so this is sent inefficiently
local function writeUnknown(name, value)
    net.WriteUInt(UNKNOWN_impulseVAR, 8)
    net.WriteString(name)
    net.WriteType(value)
end

-- Read the value of a impulseVar that was not registered
local function readUnknown()
    return net.ReadString(), net.ReadType(net.ReadUInt(8))
end

local warningsShown = {}
local function warnRegistration(name)
    if warningsShown[name] then return end
    warningsShown[name] = true

    impulse.errorNoHalt(string.format([[Warning! impulseVar '%s' wasn't registered!
        Please contact the author of the impulse Addon to fix this.
        Until this is fixed you don't need to worry about anything. Everything will keep working.
        It's just that registering impulseVars would make impulse faster.]], name), 4)
end

function impulse.writeNetimpulseVar(name, value)
    local impulseVar = impulseVars[name]
    if not impulseVar then
        warnRegistration(name)

        return writeUnknown(name, value)
    end

    net.WriteUInt(impulseVar.id, impulse_ID_BITS)
    return impulseVar.writeFn(value)
end

function impulse.writeNetimpulseVarRemoval(name)
    local impulseVar = impulseVars[name]
    if not impulseVar then
        warnRegistration(name)

        net.WriteUInt(UNKNOWN_impulseVAR, 8)
        net.WriteString(name)
        return
    end

    net.WriteUInt(impulseVar.id, impulse_ID_BITS)
end

function impulse.readNetimpulseVar()
    local impulseVarId = net.ReadUInt(impulse_ID_BITS)
    local impulseVar = impulseVarById[impulseVarId]

    if impulseVarId == UNKNOWN_impulseVAR then
        local name, value = readUnknown()

        return name, value
    end

    local val = impulseVar.readFn(value)

    return impulseVar.name, val
end

function impulse.readNetimpulseVarRemoval()
    local id = net.ReadUInt(impulse_ID_BITS)
    return id == 255 and net.ReadString() or impulseVarById[id].name
end

-- The money is a double because it accepts higher values than Int and UInt, which are undefined for >32 bits
impulse.registerimpulseVar("money",         net.WriteDouble, net.ReadDouble)
impulse.registerimpulseVar("salary",        fp{fn.Flip(net.WriteInt), 32}, fp{net.ReadInt, 32})
impulse.registerimpulseVar("rpname",        net.WriteString, net.ReadString)
impulse.registerimpulseVar("job",           net.WriteString, net.ReadString)
impulse.registerimpulseVar("rank",           net.WriteString, net.ReadString)
impulse.registerimpulseVar("arrested",      net.WriteBit, fc{tobool, net.ReadBit})

-- EASE OF USE FUNCTIONS AND SERVICES BELOW

if SERVER then
	local PLAYER = FindMetaTable("Player")
	util.AddNetworkString( "IMPULSE-ColoredMessage" )
	til.AddNetworkString( "IMPULSE-SurfaceSound" )

	function PLAYER:AddChatText(...)
		local args = {...}
		net.Start("ColoredMessage")
		net.WriteTable(args)
		net.Send(self)
	end
	
	function PLAYER:surfacePlaySound(sound)
	    net.Start("IMPULSE-SurfaceSound")
	    net.WriteString(sound)
	    net.Send(self)
	end
elseif CLIENT then
	net.Receive("IMPULSE-ColoredMessage",function(len) 
		local msg = net.ReadTable()
		chat.AddText(unpack(msg))
	end)
	
	net.Receive("IMPULSE-SurfaceSound",function()
        surface.PlaySound(net.ReadString())
    end)
end

