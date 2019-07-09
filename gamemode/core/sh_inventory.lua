impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}
impulse.Inventory.Data[0] = impulse.Inventory.Data[0] or {}
impulse.Inventory.Items = impulse.Inventory.Items or {}
impulse.Inventory.ItemsRef = impulse.Inventory.ItemsRef or {}

if CLIENT then
	impulse.Inventory.Data[0][1] = impulse.Inventory.Data[0][1] or {}
	impulse.Inventory.Data[0][2] = impulse.Inventory.Data[0][2] or {}
end

local count = 1

function impulse.RegisterItem(item)
	local class = item.WeaponClass

	if class then
		function item:OnEquip(ply)
			local wep = ply:Give(class)

			if wep and IsValid(wep) then
				wep:SetClip1(self.clip or 0)
			end
		end

		function item:UnEquip(ply)
			local wep = ply:GetWeapon(class)

			if wep and IsValid(wep) then
				self.clip = wep:Clip1()
				ply:StripWeapon(class)
			end
		end
	end

	impulse.Inventory.Items[count] = item
	impulse.Inventory.ItemsRef[item.UniqueID] = count
	count = count + 1
end

function impulse.Inventory.ClassToNetID(class)
	return impulse.Inventory.ItemsRef[class]
end

function meta:GetMaxInventoryStorage()
	if self:IsDonator() then
		return impulse.Config.InventoryStorageMaxWeightVIP
	end

	return impulse.Config.InventoryStorageMaxWeight
end