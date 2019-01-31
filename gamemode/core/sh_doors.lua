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
					doors[k:MapCreationID()] = {
						name = doorData.name or nil,
						teams = doorData.teams or nil,
						pos = k:GetPos(),
						buyable = doorData.buyable or false
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
	end

	netstream.Hook("impulseDoorBuy", function(ply, doorIndex)
		local door = Entity(doorIndex)
		if not IsValid(door) then return end
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local traceEnt = util.TraceLine(trace).Entity

		if IsValid(traceEnt) and traceEnt == door then
			if ply:CanAfford(impulse.Config.DoorPrice) then
				local doorData = door:GetDoorData()
				local owners = (doorData and doorData.owners) or {}
				owners[ply] = true
				door:DoorDataUpdate("owners", owners)
				ply:TakeMoney(impulse.Config.DoorPrice)
				ply:Notify("You have bought a door for "..impulse.Config.CurrencyPrefix..impulse.Config.DoorPrice..".")
			else
				ply:Notify("You cannot afford to buy this door.")
			end
		end
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