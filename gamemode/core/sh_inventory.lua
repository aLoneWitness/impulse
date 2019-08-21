impulse.Inventory = impulse.Inventory or {}
impulse.Inventory.Data = impulse.Inventory.Data or {}
impulse.Inventory.Data[0] = impulse.Inventory.Data[0] or {}
impulse.Inventory.Items = impulse.Inventory.Items or {}
impulse.Inventory.ItemsRef = impulse.Inventory.ItemsRef or {}
impulse.Inventory.ItemsQW = impulse.Inventory.ItemsQW or {}
impulse.Inventory.Benches = impulse.Inventory.Benches or {}
impulse.Inventory.Mixtures = impulse.Inventory.Mixtures or {}
impulse.Inventory.MixturesRef = impulse.Inventory.MixturesRef or {}
impulse.Inventory.CraftInfo = impulse.Inventory.CraftInfo or {}

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

	local craftSound = item.CraftSound
	local craftTime = item.CraftTime

	if craftSound or craftTime then
		impulse.Inventory.CraftInfo[item.UniqueID] = {
			time = craftTime or nil,
			sound = craftSound or nil
		}
	end

	impulse.Inventory.Items[count] = item -- this is done the wrong way round yea yea ik
	impulse.Inventory.ItemsRef[item.UniqueID] = count
	impulse.Inventory.ItemsQW[item.UniqueID] = (item.Weight or 1)
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

	mix.NetworkID = countX

	impulse.Inventory.Mixtures[bench][class] = mix
	impulse.Inventory.MixturesRef[countX] = {bench, class}
	countX = countX + 1
end

function impulse.Inventory.ClassToNetID(class)
	return impulse.Inventory.ItemsRef[class]
end

function impulse.Inventory.GetCraftingTime(mix)
	local items = mix.Input
	local time = 0
	local sounds = {}

	for v,k in pairs(items) do
		local hasCustom = impulse.Inventory.CraftInfo[v]

		for i=1, k.take do
			if hasCustom and hasCustom.sound then
				table.insert(sounds, {time, hasCustom.sound})
			else
				table.insert(sounds, {time, "generic"})
			end

			time = time + ((hasCustom and hasCustom.time) or 3)
		end
	end

	return time, sounds
end

local sounds = {
	["chemical"] = 3,
	["electronics"] = 3,
	["fabric"] = 6,
	["fuel"] = 3,
	["generic"] = 3,
	["gunmetal"] = 3,
	["metal"] = 3,
	["nuclear"] = 2,
	["plastic"] = 4,
	["powder"] = 3,
	["rock"] = 4,
	["water"] = 3,
	["wood"] = 6
}

function impulse.Inventory.PickRandomCraftSound(crafttype)
	local max = sounds[crafttype]

	if not max then
		crafttype = "generic"
	end

	return "impulse/craft/"..crafttype.."/"..math.random(1, max)..".wav"
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