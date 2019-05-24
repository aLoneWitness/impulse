/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

INV_CONFISCATED = 0
INV_PLAYER = 1
INV_STORAGE = 2

impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}

function impulse.Inventory.DBAddItem(itemuid, ownerid, storageType, data, onDone)
	local query = mysql:Insert("impulse_inventory")
	query:Insert("uniqueid", itemuid)
	query:Insert("ownerid", ownerid)
	query:Insert("storagetype", storageType or 1)
	if data then
		query:Insert("data", data)
	end

	query:Callback(function(result, status, id)
		if onDone then
			return onDone(id)
		end
	end)

	query:Execute()

	return 
end

function impulse.Inventory.DBRemoveItem(itemid)
	local query = mysql:Delete("impulse_inventory")
	query:Where("id", itemid)
	query:Execute()
end

function impulse.Inventory.DBClearOwnerStorage(ownerid, storageType)
	local query = mysql:Delete("impulse_inventory")
	query:Where("ownerid", ownerid)
	query:Where("storagetype", storageType or 1)
	query:Execute()
end

function impulse.Inventory.DBUpdateStorage(itemid, newStorageType)
	local query = mysql:Update("impulse_inventory")
	query:Update("storagetype", newStorageType)
	query:Where("id", itemid)
	query:Execute()
end

function impulse.Inventory.DBUpdateData(itemid, newData)
	local query = mysql:Update("impulse_inventory")
	query:Update("data", newData)
	query:Where("id", itemid)
	query:Execute()
end

function impulse.Inventory.ClassToNetID(class)
	return impulse.Inventory.ItemsRef[class]
end

function meta:GetInventory(storage)
	return impulse.Inventory.Data[self:UserID()][storage]
end

function meta:GiveItem(class, storetype, silent)
	net.Start("impulseInvGive")
	net.WriteUInt()
	if silent then
		
	end
end

function meta:SetupInventory()
	for v,k in pairs(self:GetInventory(1)) do
		net.Start("impulseInvGiveSilent")
		net.WriteUInt(k.id, 16)
		net.WriteUInt(1, 4)
		net.Send(self)
	end

	for v,k in pairs(self:GetInventory(2)) do
		net.Start("impulseInvGiveSilent")
		net.WriteUInt(k.id, 16)
		net.WriteUInt(2, 4)
		net.Send(self)
	end
end