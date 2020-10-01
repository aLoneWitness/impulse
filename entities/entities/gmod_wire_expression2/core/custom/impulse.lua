if not E2Lib then
	return
end

E2Lib.RegisterExtension("impulse", true, "Allows E2 to interact with certain methods in the impulse framework.")

local function checkOwner(self)
	return IsValid(self.player);
end

__e2setcost(35)
e2function number impulseGetPlayerMoney(entity ent)
	if not IsValid(ent) then return end
	if not ent:IsPlayer() then
		return 0
	end

	return ent:GetMoney() or 0
end

e2function number impulseGetPlayerHunger(entity ent)
	if not IsValid(ent) then return end
	if not ent:IsPlayer() then
		return 0
	end

	return ent:GetSyncVar(SYNC_HUNGER, 0) or 0
end

e2function number impulseGetPlayerXP(entity ent)
	if not IsValid(ent) then return end
	if not ent:IsPlayer() then
		return 0
	end

	return ent:GetXP()
end

e2function string impulseGetItemClass(entity ent)
	if not IsValid(ent) then return end
	if ent:GetClass() != "impulse_item" or not ent.Item then
		return
	end

	return ent.Item.UniqueID or "unknown"
end

e2function number impulseGetMoneyValue(entity ent)
	if not IsValid(ent) then return 0 end
	if ent:GetClass() != "impulse_money" or not ent.money then
		return 0
	end

	return ent.money
end

e2function number impulseGetPlayerFirstJoinDate(entity ent)
	if not IsValid(ent) then return end
	if not ent:IsPlayer() or not ent.impulseFirstJoin then
		return 0
	end

	return ent.impulseFirstJoin
end

__e2setcost(60)
e2function number impulsePickupMoney(entity ent)
	if not IsValid(ent) then return end
	if not IsValid(self.entity) then return end
	if not IsValid(self.player) then return end
	if ent:GetClass() != "impulse_money" or not ent.money then
		return 0
	end

	if ent:GetPos():DistToSqr(self.entity:GetPos()) > (100 ^ 2) then
		return 0
	end

	local m = ent.money
	local tax = math.Clamp(math.ceil(m * 0.08), 1, 500)
	local delta = m - tax

	if delta < 1 then
		tax = 0
		delta = m
	end

	ent:Remove()

	self.player:GiveMoney(delta)
	self.player:Notify("You have gained "..impulse.Config.CurrencyPrefix..delta.." from your E2 chip ("..impulse.Config.CurrencyPrefix..tax.." taxed).")

	return tax
end
