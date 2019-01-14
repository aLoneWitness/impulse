/*
** Copyright (c) 2019 Jake Green (vin)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Sync = impulse.Sync or {}
impulse.Sync.Data = impulse.Sync.Data or {}
local syncVars = {}
local SYNC_TYPE_NEXT = 1
local SYNC_TYPE_ISSUED = 2
local SYNC_TYPE_NEVER = 3

function impulse.Sync.RegisterVar(varName)
	local id = table.insert(syncVars, varName)
	return id
end

if SERVER then
	function meta:Sync(syncUser)
		local targetID = self:UserID()
		local syncUser = impulse.Sync.Data[targetID]
		for varID, syncData in pairs(syncUser) do
			local value = syncData[1]
			local syncType = syncData[2]

			if syncType == SYNC_TYPE_NEXT then
				if syncUser then
					netstream.Start(syncUser, "impulseSyncUpdate", varID, targetID, value)
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

	function meta:SetSyncVar(varID, newValue, instantSync)
		local instantSync = instantSync or false
		local targetID = self:UserID()
		netstream.Start(self, "impulseSyncUpdate", varID, targetID, newValue)
		
		local targetData = impulse.Sync.Data[targetID]
		targetData[varID] = {newValue, SYNC_TYPE_NEXT}

		if instantSync then
			self:Sync()
		end
	end
	
	function meta:SetLocalSyncVar(varID, newValue)
		netstream.Start(self, "impulseSyncUpdate", varID, self:UserID(), newValue)
		local targetData = impulse.Sync.Data[targetID]
		targetData[varID] = {newValue, SYNC_TYPE_NEVER}
	end

	function meta:GetSyncVar(varID, fallback)
		return impulse.Sync.Data[self:UserID()][varID] or fallback
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
		return self.impulseSync[varID] or fallback
	end

	netstream.Hook("impulseSyncUpdate", function(varID, targetID, newValue)
		local target = Player(targetID)
		if !IsValid(target) then return MsgN("[impulseSync] Invalid target player! VarID: "..varID.." TargetID: "..targetID.." Value: "..newValue) end
		target.impulseSync = target.impulseSync or {}
		print(varID)
		local varName = syncVars[varID]

		target.impulseSync[varID] = newValue
	end)
end