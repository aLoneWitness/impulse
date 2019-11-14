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

function impulse.Inventory.DBUpdateStoreType(ownerid, class, limit, oldStorageType, newStorageType)
	local query = mysql:Update("impulse_inventory")
	query:Update("storagetype", newStorageType)
	query:Where("ownerid", ownerid)
	query:Where("uniqueid", class)
	query:Where("storagetype", oldStorageType)
	if not limit or isnumber(limit) then
		query:Limit(limit or 1)
	end
	query:Execute()
end

function impulse.Inventory.SpawnItem(class, pos)
	local itemid = impulse.Inventory.ClassToNetID(class)
	if not itemid then return print("[impulse] Attempting to spawn nil item!") end
	
	local item = ents.Create("impulse_item")
	item:SetItem(itemid)
	item:SetPos(pos)
	item:Spawn()

	return item
end

function impulse.Inventory.SpawnBench(class, pos, ang)
	local benchClass = impulse.Inventory.Benches[class]
	if not benchClass then return print("[impulse] Attempting to spawn nil bench!") end

	local bench = ents.Create("impulse_bench")
	bench:SetBench(benchClass)
	bench:SetPos(pos)
	bench:SetAngles(ang)
	bench:Spawn()

	return bench
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
		return true, has
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

function meta:HasIllegalInventoryItem(storetype)
	if not self.beenInvSetup then return false end
	local storetype = storetype or 1
	local inv = self:GetInventory(storetype)

	for v,k in pairs(inv) do
		local itemclass = impulse.Inventory.ClassToNetID(k.class)
		local item = impulse.Inventory.Items[itemclass]

		if not k.restricted and item.Illegal then
			return true, v
		end
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

function meta:GiveInventoryItem(itemclass, storetype, restricted, isLoaded, moving, clip) -- isLoaded is a internal arg used for first time item setup, when they are already half loaded
	if not self.beenInvSetup and not isLoaded then return end

	local storetype = storetype or 1
	local restricted = restricted or false
	local itemid = impulse.Inventory.ClassToNetID(itemclass)
	local weight = impulse.Inventory.Items[itemid].Weight or 0
	local impulseid = self.impulseID

	local inv = impulse.Inventory.Data[impulseid][storetype]
	local invid 

	for i=1, (table.Count(inv) + 1) do -- intellegent table insert looks for left over ids to reuse to stop massive id's that cant be networked
		if inv[i] == nil then
			invid = i
			impulse.Inventory.Data[impulseid][storetype][i] = {
				id = itemid,
				class = itemclass,
				restricted = restricted,
				equipped = false,
				clip = clip or nil
			}
			break
		end
	end

	if not restricted and not isLoaded and not moving then
		impulse.Inventory.DBAddItem(impulseid, itemclass, storetype)
	end
	
	if storetype == 1 then
		self.InventoryWeight = self.InventoryWeight + weight
		self.InventoryRegister[itemclass] = (self.InventoryRegister[itemclass] or 0) + 1 -- use a register that copies the actions of the real inv for search efficiency
	elseif storetype == 2 then
		self.InventoryWeightStorage = self.InventoryWeightStorage + weight
	end

	if not moving then
		net.Start("impulseInvGive")
		net.WriteUInt(itemid, 16)
		net.WriteUInt(invid, 10)
		net.WriteUInt(storetype, 4)
		net.WriteBool(restricted or false)
		net.Send(self)
	end

	return invid
end

function meta:TakeInventoryItem(invid, storetype, moving)
	if not self.beenInvSetup then return end

	local storetype = storetype or 1
	local amount = amount or 1
	local impulseid = self.impulseID
	local item = impulse.Inventory.Data[impulseid][storetype][invid]
	local itemid = impulse.Inventory.ClassToNetID(item.class)
	local weight = (impulse.Inventory.Items[itemid].Weight or 0) * amount

	if not moving then
		impulse.Inventory.DBRemoveItem(self.impulseID, item.class, storetype, 1)
	end

	if storetype == 1 then
		self.InventoryWeight = math.Clamp(self.InventoryWeight - weight, 0, 1000)
	elseif storetype == 2 then
		self.InventoryWeightStorage = math.Clamp(self.InventoryWeightStorage - weight, 0, 1000)
	end

	if storetype == 1 then
		local regvalue = self.InventoryRegister[item.class]
		self.InventoryRegister[item.class] = regvalue - 1

		if self.InventoryRegister[item.class] < 1 then -- any negative values to be removed
			self.InventoryRegister[item.class] = nil
		end
	end

	if item.equipped then
		self:SetInventoryItemEquipped(invid, false)
	end

	local clip = item.clip

	hook.Run("OnInventoryItemRemoved", self, storetype, item.class, item.id, item.equipped, item.restricted, invid)
	impulse.Inventory.Data[impulseid][storetype][invid] = nil
	
	if not moving then
		net.Start("impulseInvRemove")
		net.WriteUInt(invid, 10)
		net.WriteUInt(storetype, 4)
		net.Send(self)
	end

	return clip
end

function meta:ClearInventory(storetype)
	if not self.beenInvSetup then return end
	local storetype = storetype or 1

	local inv = self:GetInventory(storetype)

	for v,k in pairs(inv) do
		self:TakeInventoryItem(v, storetype, true)
	end

	impulse.Inventory.DBClearInventory(self.impulseID, storetype)

	net.Start("impulseInvClear")
	net.WriteUInt(storetype, 4)
	net.Send(self)
end

function meta:ClearRestrictedInventory(storetype)
	if not self.beenInvSetup then return end
	local storetype = storetype or 1

	local inv = self:GetInventory(storetype)

	for v,k in pairs(inv) do
		if k.restricted then
			self:TakeInventoryItem(v, storetype, true)
		end
	end

	net.Start("impulseInvClearRestricted")
	net.WriteUInt(storetype, 4)
	net.Send(self)
end

function meta:ClearIllegalInventory(storetype)
	if not self.beenInvSetup then return end
	local storetype = storetype or 1

	local inv = self:GetInventory(storetype)

	for v,k in pairs(inv) do
		local itemData = impulse.Inventory.Items[impulse.Inventory.ClassToNetID(v)]

		if itemData and itemData.Illegal then
			self:TakeInventoryItem(v)
		end
	end
end

function meta:TakeInventoryItemClass(itemclass, storetype, amount)
	if not self.beenInvSetup then return end

	local storetype = storetype or 1
	local amount = amount or 1
	local impulseid = self.impulseID

	local count = 0
	for v,k in pairs(impulse.Inventory.Data[impulseid][storetype]) do
		if k.class == itemclass then
			count = count + 1
			self:TakeInventoryItem(v, storetype)

			if count == amount then
				return
			end
		end
	end
end

function meta:SetInventoryItemEquipped(itemid, state)
	if not self:Alive() then return end
	
	local item = impulse.Inventory.Data[self.impulseID][1][itemid]
	local id = impulse.Inventory.ClassToNetID(item.class)
	local onEquip = impulse.Inventory.Items[id].OnEquip
	local unEquip = impulse.Inventory.Items[id].UnEquip
	if not onEquip then return end
	local itemclass = impulse.Inventory.Items[id]

	if itemclass.CanEquip and not itemclass.CanEquip(item, self) then
		return
	end

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
		onEquip(item, self, itemclass)
		self:EmitBudgetSound("impulse/equip.wav", 900)
	elseif unEquip then
		if itemclass.EquipGroup then
			self.InventoryEquipGroups[itemclass.EquipGroup] = nil
		end
		unEquip(item, self, itemclass)
		self:EmitBudgetSound("impulse/unequip.wav", 900)
	end

	item.equipped = state

	net.Start("impulseInvUpdateEquip")
	net.WriteUInt(itemid, 10)
	net.WriteBool(state or false)
	net.Send(self)
end

function meta:UnEquipInventory()
	if not self.beenInvSetup then return end

	local inv = self:GetInventory(1)

	for v,k in pairs(inv) do
		if k.equipped then
			self:SetInventoryItemEquipped(v, false)
		end
	end
end

function meta:DropInventoryItem(itemid)
	local trace = {}
	trace.start = self:EyePos()
	trace.endpos = trace.start + self:GetAimVector() * 45
	trace.filter = self

	local item = impulse.Inventory.Data[self.impulseID][1][itemid]
	local tr = util.TraceLine(trace)

	local itemnetid = impulse.Inventory.ClassToNetID(item.class)
	local itemclass = impulse.Inventory.Items[itemnetid]

	if item.restricted then
		if not itemclass.DropIfRestricted then
			return
		end
	end

	self:TakeInventoryItem(itemid)

	self.DroppedItemsC = (self.DroppedItemsC or 0)
	self.DroppedItems = self.DroppedItems or {}

	if self.DroppedItemsC >= impulse.Config.DroppedItemsLimit then
		for v,k in pairs(self.DroppedItems) do
			if k and IsValid(k) and k.ItemOwner and k.ItemOwner == self then
				k:Remove()
				break
			end
		end
	end

	local ent = impulse.Inventory.SpawnItem(item.class, tr.HitPos)
	ent.ItemOwner = self

	if itemclass.WeaponClass and item.clip then
		ent.ItemClip = item.clip
	end

	self.DroppedItemsC = self.DroppedItemsC + 1
	local index = table.insert(self.DroppedItems, ent)
	ent.DropIndex = index
end

function meta:UseInventoryItem(itemid)
	local itemclass = impulse.Inventory.Data[self.impulseID][1][itemid].class
	local itemnetid = impulse.Inventory.ClassToNetID(itemclass)
	local item = impulse.Inventory.Items[itemnetid]
	local trEnt

	if item.OnUse then
		if item.ShouldTraceUse then
			local trace = {}
			trace.start = self:EyePos()
			trace.endpos = trace.start + self:GetAimVector() * 85
			trace.filter = self

			trEnt = util.TraceLine(trace).Entity

			if not trEnt or not IsValid(trEnt) or not item.ShouldTraceUse(item, self, trEnt) then
				return
			end
		end
		local shouldRemove = item.OnUse(item, self, trEnt or nil)

		if shouldRemove and self:HasInventoryItemSpecific(itemid) then
			self:TakeInventoryItem(itemid)
		end
	end
end

function meta:MoveInventoryItem(itemid, from, to)
	if self:IsInventoryItemRestricted(itemid, from) then return end
	local item = impulse.Inventory.Data[self.impulseID][from][itemid]
	local itemclass = item.class

	local itemclip = self:TakeInventoryItem(itemid, from, true)

	impulse.Inventory.DBUpdateStoreType(self.impulseID, itemclass, 1, from, to)
	local newinvid = self:GiveInventoryItem(itemclass, to, false, nil, true, (itemclip or nil))

	net.Start("impulseInvMove")
	net.WriteUInt(itemid, 10)
	net.WriteUInt(newinvid, 10)
	net.WriteUInt(from, 4)
	net.WriteUInt(to, 4)
	net.Send(self)
end

function meta:CanMakeMix(mixClass)
	local skill = self:GetSkillLevel("craft")

	if mixClass.Level > skill then
		return false
	end

	for v,k in pairs(mixClass.Input) do
		local item = self:HasInventoryItem(v, k.take)

		if not item or self:IsInventoryItemRestricted(item) then
			return false
		end
	end

	return true
end