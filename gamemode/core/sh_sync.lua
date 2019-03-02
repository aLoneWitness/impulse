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

local SYNC_ID_BITS = 6
local SYNC_MAX_VARS = 63

SYNC_BOOL = 1
SYNC_STRING =  2
SYNC_INT = 3
SYNC_BIGINT = 4
SYNC_HUGEINT = 5
SYNC_MINITABLE = 6
SYNC_INTSTACK = 7

local SYNC_TYPE_PUBLIC = 1
local SYNC_TYPE_PRIVATE = 2

local entMeta = FindMetaTable("Entity")

function impulse.Sync.RegisterVar(type, conditional)
	syncVarsID = syncVarsID + 1

	if syncVarsID > SYNC_MAX_VARS then
		print("[impulse] WARNING: Sync var limit hit! (63)")
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
			local count = net.WriteUInt(#value, 4)

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
			local count = net.ReadUInt(#value, 4)
			local compiled =  {}

			for k in range(1, count) do
				table.insert(compiled, (net.ReadUInt(8)))
			end

			return compiled
		end
	end
end

if SERVER then
	util.AddNetworkString("iSyncU")
	util.AddNetworkString("iSyncUlcl")
	util.AddNetworkString("iSyncR")
	util.AddNetworkString("iSyncRvar")

	-- target is optional. Sync will take the player and sync their all SyncVars with all clients or the single target if provided.
	function entMeta:Sync(target)
		local targetID = self:EntIndex()
		local syncUser = impulse.Sync.Data[targetID]

		for varID, syncData in pairs(syncUser) do
			local value = syncData[1]
			local syncRealm = syncData[2]
			local syncType = impulse.Sync.Vars[varID]
			local syncCondition = impulse.Sync.VarsConditional[varID]

			if target and syncCondition and not syncCondition(target) then
				return
			end
			
			if syncRealm == SYNC_TYPE_PUBLIC then
				if target then
					if value == nil then
						net.Start("iSyncRvar")
							net.WriteUInt(targetID, 16)
							net.WriteUInt(varID, SYNC_ID_BITS)
						net.Send(target)
					else
						net.Start("iSyncU")
							net.WriteUInt(targetID, 16)
							net.WriteUInt(varID, SYNC_ID_BITS)
							impulse.Sync.DoType(syncType, value)
						net.Send(target)
					end
				else
					local recipFilter = RecipientFilter()

					if syncCondition then
						for v,k in pairs(player.GetAll()) do
							if syncCondition(k) then
								recipFilter:AddPlayer(k)
							end
						end
					else
						recipFilter:AddAllPlayers()
					end

					if value == nil then
						net.Start("iSyncRvar")
							net.WriteUInt(targetID, 16)
							net.WriteUInt(varID, SYNC_ID_BITS)
						net.Send(recipFilter)
					else
						net.Start("iSyncU")
							net.WriteUInt(targetID, 16)
							net.WriteUInt(varID, SYNC_ID_BITS)
							impulse.Sync.DoType(syncType, value)
						net.Send(recipFilter)
					end
				end
			elseif target and target:IsPlayer() and target:EntIndex() == targetID then
				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(target)
				else
					net.Start("iSyncUlcl")
						net.WriteUInt(targetID, 8)
						net.WriteUInt(varID, SYNC_ID_BITS)
						impulse.Sync.DoType(syncType, value)
					net.Send(target)
				end
			end
		end
	end

	-- target is optional. SyncSingle will take the player and sync the SyncVar provided with all clients or the single target if provided.
	function entMeta:SyncSingle(varID, target)
		local targetID = self:EntIndex()
		local syncUser = impulse.Sync.Data[targetID]
		local syncData = syncUser[varID]
		local value = syncData[1]
		local syncRealm = syncData[2]
		local syncType = impulse.Sync.Vars[varID]
		local syncCondition = impulse.Sync.VarsConditional[varID]

		if target and syncCondition and not syncCondition(target) then
			return
		end

		if syncRealm == SYNC_TYPE_PUBLIC then
			if target then
				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(target)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						impulse.Sync.DoType(syncType, value)
					net.Send(target)
				end
			else
				local recipFilter = RecipientFilter()

				if syncCondition then
					for v,k in pairs(player.GetAll()) do
						if syncCondition(k) then
							recipFilter:AddPlayer(k)
						end
					end
				else
					recipFilter:AddAllPlayers()
				end

				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(recipFilter)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						impulse.Sync.DoType(syncType, value)
					net.Send(recipFilter)
				end
			end
		elseif target and target:IsPlayer() and target:EntIndex() == targetID then
			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(target)
			else
				net.Start("iSyncUlcl")
					net.WriteUInt(targetID, 8)
					net.WriteUInt(varID, SYNC_ID_BITS)
					impulse.Sync.DoType(syncType, value)
				net.Send(target)
			end
		end
	end

	-- SyncRemove will remove all SyncVars for this entity, then it will update all clients to remove this etntity.
	function entMeta:SyncRemove()
		local targetID = self:EntIndex()

		impulse.Sync.Data[targetID] = nil

		net.Start("iSyncR")
			net.WriteUInt(targetID, 16)
		net.Broadcast()	
	end

	function entMeta:SyncRemoveVar(varID)
		local targetID = self:EntIndex()

		impulse.Sync.Data[targetID][varID] = nil

		net.Start("iSyncR")
			net.WriteUInt(targetID, 16)
		net.Broadcast()	
	end

	-- instantSync is optional. SetSyncVar will set the SyncVar however it will not update it with all clients unless instantSync is true.
	function entMeta:SetSyncVar(varID, newValue, instantSync)
		local targetID = self:EntIndex()
		local targetData = impulse.Sync.Data[targetID]

		if not targetData then
			impulse.Sync.Data[targetID] = {}
			targetData = impulse.Sync.Data[targetID]
		elseif targetData[varID] and targetData[varID][1] == newValue then
			return
		end

		targetData[varID] = {newValue, SYNC_TYPE_PUBLIC}

		if instantSync then
			self:SyncSingle(varID)
		end
	end
	
	-- SetLocalSyncVar will set a local (to the player) SyncVar that will not be communicated with any other players.
	function meta:SetLocalSyncVar(varID, newValue)
		local targetID = self:EntIndex()
		local targetData = impulse.Sync.Data[targetID]
		targetData[varID] = {newValue, SYNC_TYPE_PRIVATE}

		self:SyncSingle(varID, self)
	end

	function entMeta:GetSyncVar(varID, fallback)
		local targetData = impulse.Sync.Data[self.EntIndex(self)]

		if targetData != nil then
			if targetData[varID] != nil then
				return targetData[varID][1]
			end
		end
		return fallback
	end
else
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

		print("[impulse] Sync V3 DEBUG:\nsize:"..len.."\ntype: "..syncType.."\nvarid:"..varID.."\nval: "..tostring(newValue).."\ntarget: "..targetID)

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

		print("[impulse] Sync V3 DEBUG (LOCAL):\nsize:"..len.."\ntype: "..syncType.."\nvarid:"..varID.."\nval: "..tostring(newValue).."\ntarget: "..targetID)

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
SYNC_HAT = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_HUNGER = impulse.Sync.RegisterVar(SYNC_INT)

-- ent sync vars
SYNC_DOOR_NAME = impulse.Sync.RegisterVar(SYNC_STRING)
SYNC_DOOR_GROUP = impulse.Sync.RegisterVar(SYNC_INT)
SYNC_DOOR_BUYABLE = impulse.Sync.RegisterVar(SYNC_BOOL)
SYNC_DOOR_OWNERS = impulse.Sync.RegisterVar(SYNC_MINITABLE)

-- conditional networking test 1
SYNC_PRISON_SENTENCE = impulse.Sync.RegisterVar(SYNC_INT, function(ply)
	return ply:IsCP()
end)