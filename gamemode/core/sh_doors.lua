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
				local doorData = k:GetDoorData()
				if doorData then
					if doorData.buyable == false then
						doors[k:MapCreationID()] = {
							name = doorData.name or nil,
							group = doorData.group or nil,
							hidden = doorData.hidden or nil,
							pos = k:GetPos(),
							buyable = doorData.buyable or false
						}
					end
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
					impulse.Doors.Data[doorIndex] = doorData
				end
			end
		end
	end

	function eMeta:DoorDataUpdate(key, value)
		local entID = self:EntIndex()

		impulse.Doors.Data[entID] = impulse.Doors.Data[self:EntIndex()] or {}
		impulse.Doors.Data[entID][key] = value

		netstream.Start(nil, "iDoorU", entID, key, value)
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
		local doorData = traceEnt:GetDoorData()

		if IsValid(traceEnt) and ply:CanBuyDoor(doorData) then
			if ply:CanAfford(impulse.Config.DoorPrice) then
				local owners = (doorData and doorData.owners) or {}
				owners[ply:UserID()] = true

				traceEnt:DoorDataUpdate("owners", owners)

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
		local doorData = traceEnt:GetDoorData()

		if IsValid(traceEnt) and doorData and ply:IsDoorOwner(doorData) then
			traceEnt:DoorDataUpdate("owners", nil)
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
			local doorData = traceEnt:GetDoorData()

			if ply:CanLockUnlockDoor(doorData) then
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
			local doorData = traceEnt:GetDoorData()

			if ply:CanLockUnlockDoor(doorData) then
				traceEnt:DoorUnlock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			end
		end

		ply.nextDoorUnlock = CurTime() + 1
	end)
else
	netstream.Hook("iDoorU", function(entIndex, key, doorData)
		if entIndex == -1 or entIndex == 0 then return end

		impulse.Doors.Data[entIndex] = impulse.Doors.Data[entIndex] or {}
		impulse.Doors.Data[entIndex][key] = doorData
	end)
end

function eMeta:GetDoorData()
	return impulse.Doors.Data[self:EntIndex()]
end

function meta:CanLockUnlockDoor(doorData)
	if not doorData then return false end

	hook.Run("playerCanUnlockLock", self, doorData)

	local teamDoorGroups = impulse.Teams.Data[self:Team()].doorGroup

	if doorData.owners and doorData.owners[self:UserID()] then
		return true
	elseif doorData.group and teamDoorGroups and table.HasValue(teamDoorGroups, doorData.group) then
		return true
	end
end

function meta:IsDoorOwner(doorData)
	if doorData and doorData.owners and doorData.owners[self:UserID()] then
		return true
	end
	return false
end

function meta:CanBuyDoor(doorData)
	if doorData then
		if (doorData.owners) or doorData.buyable == false then
			return false
		end
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
		traceEnt:DoorDataUpdate("buyable", !tobool(args[1]))
		traceEnt:DoorDataUpdate("group", nil)
		traceEnt:DoorDataUpdate("name", nil)
		traceEnt:DoorDataUpdate("group", nil)
		traceEnt:DoorDataUpdate("owners", nil)

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
		traceEnt:DoorDataUpdate("buyable", false)
		traceEnt:DoorDataUpdate("group", tonumber(args[1]))
		traceEnt:DoorDataUpdate("name", nil)
		traceEnt:DoorDataUpdate("owners", nil)

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
		traceEnt:DoorDataUpdate("buyable", nil)
		traceEnt:DoorDataUpdate("group", nil)
		traceEnt:DoorDataUpdate("name", nil)
		traceEnt:DoorDataUpdate("owners", nil)

		ply:Notify("Door "..traceEnt:EntIndex().." group = nil")

		impulse.Doors.Save()
	end
end)