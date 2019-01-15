/*
** Copyright (c) 2019 Jake Green (vin)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Sync = impulse.Sync or {}
impulse.Sync.Data = impulse.Sync.Data or {}
local syncVarsID = 0
local SYNC_TYPE_PUBLIC = 1
local SYNC_TYPE_PRIVATE = 2

function impulse.Sync.RegisterVar()
	syncVarsID = syncVarsID + 1
	return syncVarsID
end

if SERVER then
	-- target is optional. Sync will take the player and sync their all SyncVars with all clients or the single target if provided.
	function meta:Sync(target)
		local targetID = self:UserID()
		local syncUser = impulse.Sync.Data[targetID]
		for varID, syncData in pairs(syncUser) do
			local value = syncData[1]
			local syncType = syncData[2]

			if syncType == SYNC_TYPE_PUBLIC then
				if target then
					netstream.Start(target, "impulseSyncUpdate", varID, targetID, value)
				else
					for v, ply in pairs(player.GetAll()) do
						if not ply == Player(targetID) then
							netstream.Start(ply, "impulseSyncUpdate", varID, targetID, value)
						end
					end
				end
			end
		end
	end

	-- target is optional. SyncSingle will take the player and sync the SyncVar provided with all clients or the single target if provided.
	function meta:SyncSingle(varID, target)
		local targetID = self:UserID()
		local syncUser = impulse.Sync.Data[targetID]
		local syncData = syncUser[varID]
		local value = syncData[1]
		local syncType = syncData[2]

		if syncType == SYNC_TYPE_PUBLIC then
			if target then
				netstream.Start(target, "impulseSyncUpdate", varID, targetID, value)
			else
				for v, ply in pairs(player.GetAll()) do
					if not ply == Player(targetID) then
						netstream.Start(ply, "impulseSyncUpdate", varID, targetID, value)
					end
				end
			end
		end
	end

	-- SyncRemove will remove all SyncVars for this player, then it will update all clients to remove this player.
	function meta:SyncRemove()
		local targetID = self:UserID()

		impulse.Sync.Data[targetID] = nil
		netstream.Start("impulseSyncRemove", targetID)
	end

	-- instantSync is optional. SetSyncVar will set the SyncVar however it will not update it with all clients unless instantSync is true.
	function meta:SetSyncVar(varID, newValue, instantSync)
		local instantSync = instantSync or false
		local targetID = self:UserID()
		netstream.Start(self, "impulseSyncUpdate", varID, targetID, newValue)
		
		local targetData = impulse.Sync.Data[targetID]
		targetData[varID] = {newValue, SYNC_TYPE_PUBLIC}

		if instantSync then
			self:SyncSingle(varID)
		end
	end
	
	-- SetLocalSyncVar will set a local (to the player) SyncVar that will not be communicated with any other players.
	function meta:SetLocalSyncVar(varID, newValue)
		local targetID = self:UserID()

		netstream.Start(self, "impulseSyncUpdate", varID, targetID, newValue)
		local targetData = impulse.Sync.Data[targetID]
		targetData[varID] = {newValue, SYNC_TYPE_PRIVATE}
	end

	function meta:GetSyncVar(varID, fallback)
		local targetData = impulse.Sync.Data[self:UserID()]

		if targetData then
			return targetData[varID] or fallback
		else
			return fallback
		end
	end
	
	netstream.Hook("impulseRequestSync", function(ply)
		if ply.lastSync and ply.lastSync > (CurTime() - 3) then return end
		ply.lastSync = CurTime()

		for v,k in pairs(player.GetAll()) do
			k:Sync(ply)
		end
	end)
else
	function meta:GetSyncVar(varID, fallback)
		local targetData = impulse.Sync.Data[self:UserID()]

		if targetData then
			return targetData[varID] or fallback
		else
			return fallback
		end
	end

	netstream.Hook("impulseSyncUpdate", function(varID, targetID, newValue)
		local targetData = impulse.Sync.Data[targetID]
		if not targetData then
			impulse.Sync.Data[targetID] = {}
			targetData = impulse.Sync.Data[targetID]
		end

		targetData[varID] = newValue

		hook.Run("OnSyncUpdate", varID, targetID, newValue)
	end)

	netstream.Hook("impulseSyncRemove", function(targetID)
		impulse.Sync.Data[targetID] = nil
	end)
end

SYNC_RPNAME = impulse.Sync.RegisterVar()
SYNC_XP = impulse.Sync.RegisterVar()
SYNC_MONEY = impulse.Sync.RegisterVar()
SYNC_BANKMONEY = impulse.Sync.RegisterVar()