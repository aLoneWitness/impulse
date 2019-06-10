impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}
impulse.Inventory.Data[0] = impulse.Inventory.Data[0] or {}
impulse.Inventory.Items = impulse.Inventory.Items or {}
impulse.Inventory.ItemsRef = impulse.Inventory.ItemsRef or {}

local count = 1

function impulse.RegisterItem(item)
	impulse.Inventory.Items[count] = item
	impulse.Inventory.ItemsRef[item.UniqueID] = count
	count = count + 1
end

function impulse.Inventory.ClassToNetID(class)
	return impulse.Inventory.ItemsRef[class]
end