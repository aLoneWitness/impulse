function meta:DropSpecificWeapon(weapon)
	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())

	self:DropWeapon(weapon)

	local drop = ents.Create("impulse_weapon")
	drop:SetPos(self:GetShootPos() + self:GetAimVector() * 30) -- replace me
	drop:SetModel(weapon:GetModel())
	drop:SetSkin(weapon:GetSkin())
	drop.class = weapon:GetClass()
	drop.nodupe = true
	drop.clip1 = weapon:Clip1()
	drop.clip2 = weapon:Clip2()
	drop.ammo = ammo

	self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

	drop:Spawn()

	weapon:Remove()
end