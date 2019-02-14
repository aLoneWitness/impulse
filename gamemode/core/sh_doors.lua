impulse.Doors = impulse.Doors or {}
impulse.Doors.Data = impulse.Doors.Data or {}

local eMeta = FindMetaTable("Entity")
local fileName = "impulse/doors/"..game.GetMap()

file.CreateDir("impulse/doors")

if SERVER then
	function impulse.Doors.Save()
		local doors = {}

		for v,k in pairs(ents.GetAll()) do
			if k:IsDoor() and k:CreatedByMap() then
				if k:GetSyncVar(SYNC_DOOR_BUYABLE, true) == false then
					doors[k:MapCreationID()] = {
						name = k:GetSyncVar(SYNC_DOOR_NAME, nil),
						group = k:GetSyncVar(SYNC_DOOR_GROUP, nil),
						pos = k:GetPos(),
						buyable = k:GetSyncVar(SYNC_DOOR_BUYABLE, false)
					}
				end
			end
		end

		if file.Exists(fileName..".dat", "DATA") then
			file.Write(fileName.."-backup.dat", file.Read(fileName, "DATA"))
			print("[impulse] Backup created of old doors file, marked with -backup")
		end 

		print("[impulse] Saving doors to impulse/doors/"..game.GetMap()..".dat | Doors saved: "..#doors)
		file.Write(fileName..".dat", util.TableToJSON(doors))
	end

	function impulse.Doors.Load()
		impulse.Doors.Data = {}

		if file.Exists(fileName..".dat", "DATA") then
			local mapDoorData = util.JSONToTable(file.Read(fileName..".dat", "DATA"))
			for doorID, doorData in pairs(mapDoorData) do
				local doorEnt = ents.GetMapCreatedEntity(doorID)

				if IsValid(doorEnt) and doorEnt:IsDoor() then
					local doorIndex = doorEnt:EntIndex()
					PrintTable(doorData)
					
					if doorData.name then doorEnt:SetSyncVar(SYNC_DOOR_NAME, doorData.name, true) end
					if doorData.group then doorEnt:SetSyncVar(SYNC_DOOR_GROUP, doorData.group, true) end
					if doorData.buyable != nil then doorEnt:SetSyncVar(SYNC_DOOR_BUYABLE, false, true) end
				end
			end
		end
	end

	function eMeta:DoorLock()
		self:Fire("lock", "", 0)
	end

	function eMeta:DoorUnlock()
		self:Fire("unlock", "", 0)
		if self:GetClass() == "func_door" then
			self:Fire("open")
		end
	end

	netstream.Hook("impulseDoorBuy", function(ply)
		if (ply.nextDoorBuy or 0) > CurTime() then return end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local traceEnt = util.TraceLine(trace).Entity

		if IsValid(traceEnt) and ply:CanBuyDoor(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_BUYABLE, true)) then
			if ply:CanAfford(impulse.Config.DoorPrice) then
				local owners = {}
				owners[ply:UserID()] = true

				traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, owners, true)

				ply:TakeMoney(impulse.Config.DoorPrice)
				ply:Notify("You have bought a door for "..impulse.Config.CurrencyPrefix..impulse.Config.DoorPrice..".")
			else
				ply:Notify("You cannot afford to buy this door.")
			end
		end
		ply.nextDoorBuy = CurTime() + 1
	end)

	netstream.Hook("impulseDoorSell", function(ply)
		if (ply.nextDoorSell or 0) > CurTime() then return end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local traceEnt = util.TraceLine(trace).Entity

		if IsValid(traceEnt) and ply:IsDoorOwner(traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil)) then
			traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, nil, true)
			traceEnt:DoorUnlock()

			ply:GiveMoney(impulse.Config.DoorPrice - 2)
			ply:Notify("You have sold a door for "..impulse.Config.CurrencyPrefix..(impulse.Config.DoorPrice - 2)..".")
		end
		ply.nextDoorSell = CurTime() + 1
	end)

	netstream.Hook("impulseDoorLock", function(ply)
		if (ply.nextDoorLock or 0) > CurTime() then return end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local traceEnt = util.TraceLine(trace).Entity

		if IsValid(traceEnt) and traceEnt:IsDoor() then
			local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

			if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
				traceEnt:DoorLock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			end
		end

		ply.nextDoorLock = CurTime() + 1
	end)

	netstream.Hook("impulseDoorUnlock", function(ply)
		if (ply.nextDoorUnlock or 0) > CurTime() then return end

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local traceEnt = util.TraceLine(trace).Entity

		if IsValid(traceEnt) and traceEnt:IsDoor() then
			local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

			if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
				traceEnt:DoorUnlock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			end
		end

		ply.nextDoorUnlock = CurTime() + 1
	end)
end

function meta:CanLockUnlockDoor(doorOwners, doorGroup)
	if not doorOwners and not doorGroup then return end

	hook.Run("playerCanUnlockLock", self, doorOwners, doorGroup)

	local teamDoorGroups = impulse.Teams.Data[self:Team()].doorGroup

	if doorOwners and doorOwners[self:UserID()] then
		return true
	elseif doorGroup and teamDoorGroups and table.HasValue(teamDoorGroups, doorGroup) then
		return true
	end
end

function meta:IsDoorOwner(doorOwners)
	if doorOwners and doorOwners[self:UserID()] then
		return true
	end
	return false
end

function meta:CanBuyDoor(doorOwners, doorBuyable)
	if doorOwners or doorBuyable == false then
			return false
	end
	return true
end

concommand.Add("impulse_doorsethidden", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 200
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		if args[1] == "1" then
			traceEnt:SetSyncVar(SYNC_DOOR_BUYABLE, false, true)
		else
			traceEnt:SetSyncVar(SYNC_DOOR_BUYABLE, nil, true)
		end
		traceEnt:SetSyncVar(SYNC_DOOR_GROUP, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_NAME, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, nil, true)

		ply:Notify("Door "..traceEnt:EntIndex().." show = "..args[1])

		impulse.Doors.Save()
	end
end)

concommand.Add("impulse_doorsetgroup", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 200
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		traceEnt:SetSyncVar(SYNC_DOOR_BUYABLE, false, true)
		traceEnt:SetSyncVar(SYNC_DOOR_GROUP, tonumber(args[1]), true)
		traceEnt:SetSyncVar(SYNC_DOOR_NAME, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, nil, true)

		ply:Notify("Door "..traceEnt:EntIndex().." group = "..args[1])

		impulse.Doors.Save()
	end
end)

concommand.Add("impulse_doorremovegroup", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 200
	trace.filter = ply

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		traceEnt:SetSyncVar(SYNC_DOOR_BUYABLE, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_GROUP, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_NAME, nil, true)
		traceEnt:SetSyncVar(SYNC_DOOR_OWNERS, nil, true)

		ply:Notify("Door "..traceEnt:EntIndex().." group = nil")

		impulse.Doors.Save()
	end
end)