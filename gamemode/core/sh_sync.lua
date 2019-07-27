/*
** Copyright (c) 2019 Jake Green (vin)
** This file is private and may not be shared, downloaded, used or sold.
*/
-- This is Sync version 4 by vin.
-- Sync V3 has massive networking speed improvements over sync V2, however these improvements require a bit more effort on the coders part
-- SYNC V3 SHOULD NOT BE USED TO SEND VERY LARGE DATA TABLES, FOR EXAMPLE AN INVENTORY. FOR THAT USE NETSTREAM.
-- Sync V4 has been released, new features include the efficient intstack data type and conditional sync vars. However, conditional sync vars will not auto update previous data.

impulse.Sync = impulse.Sync or {}
impulse.Sync.Vars = impulse.Sync.Vars or {}
impulse.Sync.VarsConditional = impulse.Sync.VarsConditional or {}
impulse.Sync.Data = impulse.Sync.Data or {}
local syncVarsID = 0

SYNC_ID_BITS = 8
SYNC_MAX_VARS = 255

SYNC_BOOL = 1
SYNC_STRING =  2
SYNC_INT = 3
SYNC_BIGINT = 4
SYNC_HUGEINT = 5
SYNC_MINITABLE = 6
SYNC_INTSTACK = 7

SYNC_TYPE_PUBLIC = 1
SYNC_TYPE_PRIVATE = 2

local entMeta = FindMetaTable("Entity")

function impulse.Sync.RegisterVar(type, conditional)
	syncVarsID = syncVarsID + 1

	if syncVarsID > SYNC_MAX_VARS then
		print("[impulse] WARNING: Sync var limit hit! (255)")
	end

	impulse.Sync.Vars[syncVarsID] = type

	if conditional then
		impulse.Sync.VarsConditional[syncVarsID] = conditional
	end

	return syncVarsID
end

function impulse.Sync.DoType(type, value)
	if SERVER then
		if type == SYNC_BOOL then
			return net.WriteBool(value)
		elseif type == SYNC_INT then
			return net.WriteUInt(value, 8)
		elseif type == SYNC_STRING then
			return net.WriteString(value)
		elseif type == SYNC_BIGINT then
			return net.WriteUInt(value, 16)
		elseif type == SYNC_HUGEINT then
			return net.WriteUInt(value, 32)
		elseif type == SYNC_MINITABLE then
			return net.WriteData(pon.encode(value), 32)
		elseif type == SYNC_INTSTACK then
			local count = net.WriteUInt(#value, 8)

			for v,k in pairs(value) do
				net.WriteUInt(k, 8)
			end

			return
		end
	else
		if type == SYNC_BOOL then
			return net.ReadBool()
		elseif type == SYNC_INT then
			return net.ReadUInt(8)
		elseif type == SYNC_STRING then
			return net.ReadString()
		elseif type == SYNC_BIGINT then
			return net.ReadUInt(16)
		elseif type == SYNC_HUGEINT then
			return net.ReadUInt(32)
		elseif type == SYNC_MINITABLE then
			return pon.decode(net.ReadData(32))
		elseif type == SYNC_INTSTACK then
			local count = net.ReadUInt(8)
			local compiled =  {}

			for k = 1, count do
				table.insert(compiled, (net.ReadUInt(8)))
			end

			return compiled
		end
	end
end

if CLIENT then
	function entMeta:GetSyncVar(varID, fallback)
		local targetData = impulse.Sync.Data[self.EntIndex(self)]

		if targetData != nil then
			if targetData[varID] != nil then
				return targetData[varID]
			end
		end
		return fallback
	end

	net.Receive("iSyncU", function(len)
		local targetID = net.ReadUInt(16)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncType = impulse.Sync.Vars[varID]
		local newValue = impulse.Sync.DoType(syncType)
		local targetData = impulse.Sync.Data[targetID]

		if not targetData then
			impulse.Sync.Data[targetID] = {}
			targetData = impulse.Sync.Data[targetID]
		end

		targetData[varID] = newValue

		hook.Run("OnSyncUpdate", varID, targetID, newValue)
	end)

	net.Receive("iSyncUlcl", function(len)
		local targetID = net.ReadUInt(8)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncType = impulse.Sync.Vars[varID]
		local newValue = impulse.Sync.DoType(syncType)
		local targetData = impulse.Sync.Data[targetID]

		if not targetData then
			impulse.Sync.Data[targetID] = {}
			targetData = impulse.Sync.Data[targetID]
		end

		targetData[varID] = newValue

		hook.Run("OnSyncUpdate", varID, targetID, newValue)
	end)

	net.Receive("iSyncR", function()
		local targetID = net.ReadUInt(16)

		impulse.Sync.Data[targetID] = nil
	end)

	net.Receive("iSyncRvar", function()
		local targetID = net.ReadUInt(16)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncEnt = impulse.Sync.Data[targetID]

		if syncEnt then
			if impulse.Sync.Data[targetID][varID] != nil then
				impulse.Sync.Data[targetID][varID] = nil
			end
		end
	end)
end

-- player sync vars
SYNC_RPNAME = impulse.Sync.RegisterVar(SYNC_STRING)
SYNC_XP = impulse.Sync.RegisterVar(SYNC_HUGEINT)
SYNC_MONEY = impulse.Sync.RegisterVar(SYNC_HUGEINT)
SYNC_BANKMONEY = impulse.Sync.RegisterVar(SYNC_HUGEINT)
SYNC_WEPRAISED = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_CLASS = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_RANK = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_ARRESTED = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_HUNGER = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_TYPING = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_BLEEDING = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_BROKENLEGS = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_DISEASES = impulse.Sync.RegisterVar(SYNC_INTSTACK)
SYNC_PROPCOUNT = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_CRAFTLEVEL = impulse.Sync.RegisterVar(SYNC_INT)

SYNC_COS_FACE = impulse.Sync.RegisterVar(SYNC_INT) -- cosmetic sync values for clothing
SYNC_COS_HEAD = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_COS_CHEST = impulse.Sync.RegisterVar(SYNC_INT)

-- ent sync vars
SYNC_DOOR_NAME = impulse.Sync.RegisterVar(SYNC_STRING)
SYNC_DOOR_GROUP = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_DOOR_BUYABLE = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_DOOR_OWNERS = impulse.Sync.RegisterVar(SYNC_INTSTACK)

hook.Run("CreateSyncVars")