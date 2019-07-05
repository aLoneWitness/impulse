impulse.Doors = impulse.Doors or {}
impulse.Doors.Data = impulse.Doors.Data or {}

function meta:CanLockUnlockDoor(doorOwners, doorGroup)
	if not doorOwners and not doorGroup then return end

	hook.Run("playerCanUnlockLock", self, doorOwners, doorGroup)

	local teamDoorGroups = impulse.Teams.Data[self:Team()].doorGroup

	if doorOwners and doorOwners[self:EntIndex()] then
		return true
	elseif doorGroup and teamDoorGroups and table.HasValue(teamDoorGroups, doorGroup) then
		return true
	end
end

function meta:IsDoorOwner(doorOwners)
	if doorOwners and doorOwners[self:EntIndex()] then
		return true
	end
	return false
end

function meta:CanBuyDoor(doorOwners, doorBuyable)
	if doorOwners or doorBuyable == false then
			return false
	end
	return true
end