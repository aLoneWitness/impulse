impulse.Loot = impulse.Loot or {}

function impulse.Loot.GenerateFromPool(pool)
	local lootPool = impulse.Config.LootPools[pool]
	local count = 0
	local rarityCount = 0
	local loot = {}

	for v,k in RandomPairs(lootPool.Items) do
		print(v)
		
		for i=1, (k.Rep or 1) do
			local rGen = math.random(1, 1000)

			if rGen >= k.Rarity then
				if lootPool.MaxItems and count >= lootPool.MaxItems then
					break
				end

				if lootPool.MaxRarity and rarityCount >= lootPool.MaxRarity then
					break
				end

				count = count + 1
				rarityCount = rarityCount + k.Rarity

				loot[v] = (loot[v] and loot[v] + 1) or 1
			end
		end
	end

	if count == 0 then -- warning this might get stuck?!
		return impulse.Loot.GenerateFromPool(pool)
	end

	return loot
end