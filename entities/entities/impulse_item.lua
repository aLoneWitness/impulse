AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Category = "impulse"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ItemID")
end

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)  
		self:SetMoveType(SOLID_VPHYSICS)  
		self:SetSolid(SOLID_VPHYSICS)   
		self:SetUseType(SIMPLE_USE)

    	local physObj = self:GetPhysicsObject()
    	self.nodupe = true

    	if IsValid(physObj) then
			physObj:Wake()
		end
	end

	function ENT:SetItem(itemclass, owner)
		local item = impulse.Inventory.Items[itemclass]
		self:SetItemID(itemclass)
		self:SetModel(item.DropModel or item.Model)
		self:SetSkin(item.Skin or 0)
		self.Item = item

		if owner and IsValid(owner) then
			self.ItemOwner = owner
		end
	end

	function ENT:Use(activator)
		if activator:IsPlayer() and activator:CanHoldItem(self.Item.UniqueID) then
			self:Remove()
			activator:GiveInventoryItem(self.Item.UniqueID)
			activator:Notify("You have picked up a "..self.Item.Name..".")
		else
			activator:Notify("This item is too heavy to pick up.")
		end
	end

	function ENT:Think()
		if self.RemoveIn and CurTime() > self.RemoveIn then
			self:Remove()
		end
		self:NextThink(CurTime() + 5)
	end
else
	function ENT:Think()
		local itemid = self:GetItemID()

		if itemid and itemid != (self.lastItemID or -1) then
			local item = impulse.Inventory.Items[itemid]
			
			if item then
				self.HUDName = item.Name or "Unknown Item"
				self.HUDDesc = item.Desc or ""
				self.lastItemID = itemid
			end
		end
	end
end

	