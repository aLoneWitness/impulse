impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}
impulse.Inventory.Data[0] = impulse.Inventory.Data[0] or {}
impulse.Inventory.Items = impulse.Inventory.Items or {}
impulse.Inventory.ItemsRef = impulse.Inventory.ItemsRef or {}
impulse.Inventory.Benches = impulse.Inventory.Benches or {}
impulse.Inventory.Mixtures = impulse.Inventory.Mixtures or {}
impulse.Inventory.MixturesRef = impulse.Inventory.MixturesRef or {}

if CLIENT then
	impulse.Inventory.Data[0][1] = impulse.Inventory.Data[0][1] or {}
	impulse.Inventory.Data[0][2] = impulse.Inventory.Data[0][2] or {}
end

local count = 1
local countX = 1

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

	impulse.Inventory.Items[count] = item -- this is done the wrong way round yea yea ik
	impulse.Inventory.ItemsRef[item.UniqueID] = count
	count = count + 1
end

function impulse.RegisterBench(bench)
	local class = bench.Class

	impulse.Inventory.Benches[class] = bench
	impulse.Inventory.Mixtures[class] = {}
end

function impulse.RegisterMixture(mix)
	local class = mix.Class
	local bench = mix.Bench

	impulse.Inventory.Mixtures[bench][class] = mix
	impulse.Inventory.MixturesRef[countX] = class
	countX = countX + 1
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

if CLIENT then
	function meta:HasInventoryItem(id)
		if self:Team() == 0 then
			return false
		end

		local inv = impulse.Inventory.Data[0][1]
		local has = false
		local count

		for v,k in pairs(inv) do
			if k.id == id then
				has = true
				count = (count or 0) + 1
			end
		end

		return has, count
	end
end