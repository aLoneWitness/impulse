/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

INV_CONFISCATED = 0
INV_PLAYER = 1
INV_STORAGE = 2

impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}

function impulse.Inventory.DBAddItem(ownerid, class, storageType)
	local query = mysql:Insert("impulse_inventory")
	query:Insert("uniqueid", class)
	query:Insert("ownerid", ownerid)
	query:Insert("storagetype", storageType or 1)
	query:Execute()
end

function impulse.Inventory.DBRemoveItem(ownerid, class, storetype, limit)
	local query = mysql:Delete("impulse_inventory")
	query:Where("ownerid", ownerid)
	query:Where("uniqueid", class)
	query:Where("storagetype", storetype or 1)
	if not limit or isnumber(limit) then
		query:Limit(limit or 1)
	end
	query:Execute()
end

function impulse.Inventory.DBClearInventory(ownerid, storageType)
	local query = mysql:Delete("impulse_inventory")
	query:Where("ownerid", ownerid)
	query:Where("storagetype", storageType or 1)
	query:Execute()
end

function impulse.Inventory.DBUpdateStoreType(ownerid, class, limit, newStorageType)
	local query = mysql:Update("impulse_inventory")
	query:Update("storagetype", newStorageType)
	query:Where("ownerid", ownerid)
	query:Where("uniqueid", class)
	if not limit or isnumber(limit) then
		query:Limit(limit or 1)
	end
	query:Execute()
end

function impulse.Inventory.ClassToNetID(class)
	return impulse.Inventory.ItemsRef[class]
end

function meta:GetInventory(storage)
	return impulse.Inventory.Data[self.impulseID][storage or 1]
end

function meta:CanHoldItem(itemclass, amount)
	local item = impulse.Inventory.Items[impulse.Inventory.ClassToNetID(itemclass)]
	local weight = (item.Weight or 0) * (amount or 1)

	return self.InventoryWeight + item.Weight <= impulse.Config.InventoryMaxWeight
end

function meta:CanHoldItemStorage(itemclass, amount)
	local item = impulse.Inventory.Items[impulse.Inventory.ClassToNetID(itemclass)]
	local weight = (item.Weight or 0) * (amount or 1)

	if self:IsDonator() then
		return self.InventoryWeightStorage + weight <= impulse.Config.InventoryStorageMaxWeightVIP
	else
		return self.InventoryWeightStorage + weight <= impulse.Config.InventoryStorageMaxWeight
	end
end

function meta:HasInventoryItem(itemclass, amount)
	local has = self.InventoryRegister[itemclass]

	if amount then
		if has and has >= amount then
			return true, has
		else
			return false, has
		end
	end

	if has then
		return true
	end

	return false
end

function meta:HasInventoryItemSpecific(id, storetype)
	if not self.beenInvSetup then return false end
	local storetype = storetype or 1
	local has = impulse.Inventory.Data[self.impulseID][storetype][id]

	if has then
		return true, has
	end

	return false
end

function meta:IsInventoryItemRestricted(id, storetype)
	if not self.beenInvSetup then return false end
	local storetype = storetype or 1
	local has = impulse.Inventory.Data[self.impulseID][storetype][id]

	if has then
		return has.restricted
	end

	return false
end

function meta:GiveInventoryItem(itemclass, storetype, restricted, isLoaded) -- no sv is a internal arg used for first time item setup, when they are already half loaded
	if not self.beenInvSetup and not isLoaded then return end

	local storetype = storetype or 1
	local restricted = restricted or false
	local itemid = impulse.Inventory.ClassToNetID(itemclass)
	local weight = impulse.Inventory.Items[itemid].Weight or 0
	local impulseid = self.impulseID


	local invid = table.insert(impulse.Inventory.Data[impulseid][storetype], {
		id = netid,
		class = itemclass,
		restricted = restricted,
		equipped = false
	})

	if not restricted and not isLoaded then
		impulse.Inventory.DBAddItem(impulseid, itemclass, storetype)
	end
	
	if storetype == 1 then
		self.InventoryWeight = self.InventoryWeight + weight
	elseif storetype == 2 then
		self.InventoryWeightStorage = self.InventoryWeightStorage + weight
	end

	self.InventoryRegister[itemclass] = (self.InventoryRegister[itemclass] or 0) + 1 -- use a register that copies the actions of the real inv for search efficiency

	net.Start("impulseInvGive")
	net.WriteUInt(itemid, 16)
	net.WriteUInt(invid, 10)
	net.WriteUInt(storetype, 4)
	net.WriteBool(restricted or false)
	net.Send(self)

	return invid
end

function meta:TakeInventoryItem(invid, storetype)
	if not self.beenInvSetup then return end

	local storetype = storetype or 1
	local amount = amount or 1
	local impulseid = self.impulseID
	local item = impulse.Inventory.Data[impulseid][storetype][invid]
	local itemid = impulse.Inventory.ClassToNetID(item.class)
	local weight = (impulse.Inventory.Items[itemid].Weight or 0) * amount

	impulse.Inventory.DBRemoveItem(self.impulseID, item.class, storetype, 1)

	if storetype == 1 then
		self.InventoryWeight = math.Clamp(self.InventoryWeight - weight, 0, 1000)
	elseif storetype == 2 then
		self.InventoryWeightStorage = math.Clamp(self.InventoryWeightStorage - weight, 0, 1000)
	end

	local regvalue = self.InventoryRegister[item.class]
	self.InventoryRegister[item.class] = regvalue - 1

	if regvalue < 1 then -- any negative values to be removed
		self.InventoryRegister[item.class] =  nil
	end

	hook.Run("OnInventoryItemRemoved", self, storetype, item.class, item.id, item.equipped, item.restricted, invid)
	impulse.Inventory.Data[impulseid][storetype][invid] = nil
	print(itemid)
	
	net.Start("impulseInvRemove")
	net.WriteUInt(invid, 10)
	net.WriteUInt(storetype, 4)
	net.Send(self)
end

function meta:TakeInventoryItemClass(itemclass, storetype, amount)
	if not self.beenInvSetup then return end

	local storetype = storetype or 1
	local amount = amount or 1
	local itemid = impulse.Inventory.ClassToNetID(itemclass)
	local weight = (impulse.Inventory.Items[itemid].Weight or 0) * amount
	local impulseid = self.impulseID

	impulse.Inventory.DBRemoveItem(self.impulseID, itemclass, storetype, amount)

	local loop = 0
	for v,k in pairs(impulse.Inventory.Data[impulseid][storetype]) do
		if k.class == itemclass then
			hook.Run("OnInventoryItemRemoved", self, storetype, k.class, k.id, k.equipped, k.restricted)
			k = nil
			loop = loop + 1

			if loop == amount then
				break
			end
		end
	end

	if storetype == 1 then
		self.InventoryWeight = math.Clamp(self.InventoryWeight - weight, 0, 1000)
	elseif storetype == 2 then
		self.InventoryWeightStorage = math.Clamp(self.InventoryWeightStorage - weight, 0, 1000)
	end

	local regvalue = self.InventoryRegister[itemclass]
	regvalue =  regvalue - (1 * amount) -- decrease amount by one

	if regvalue < 1 then -- any negative values to be removed
		regvalue =  nil
	end
	
	net.Start("impulseInvRemove")
	net.WriteUInt(itemid)
end

function meta:SetInventoryItemEquipped(itemid, state)
	local item = impulse.Inventory.Data[self.impulseID][1][itemid]
	local id = impulse.Inventory.ClassToNetID(item.class)
	local onEquip = impulse.Inventory.Items[id].OnEquip
	local unEquip = impulse.Inventory.Items[id].UnEquip
	if not onEquip then return end
	local itemclass = impulse.Inventory.Items[id]

	if itemclass.EquipGroup then
		local equippedItem = self.InventoryEquipGroups[itemclass.EquipGroup]
		if equippedItem and equippedItem != itemid then
			self:SetInventoryItemEquipped(equippedItem, false)
		end 
	end

	if state then
		if itemclass.EquipGroup then
			self.InventoryEquipGroups[itemclass.EquipGroup] = itemid
		end
		onEquip(item, self)
	elseif unEquip then
		if itemclass.EquipGroup then
			self.InventoryEquipGroups[itemclass.EquipGroup] = nil
		end
		unEquip(item, self)
	end

	item.equipped = state

	net.Start("impulseInvUpdateEquip")
	net.WriteUInt(itemid, 10)
	net.WriteBool(state or false)
	net.Send(self)
end