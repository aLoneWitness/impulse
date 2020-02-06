impulse.Group = impulse.Group or {}
impulse.Group.Groups = impulse.Group.Groups or {}

RPGROUP_PERMISSIONS = {
	[1] = "See group chat",
	[2] = "Post to group chat",
	[3] = "Can add members",
	[4] = "Can remove members",
	[5] = "Can promote/demote members",
	[6] = "Can edit ranks"
	--[7] = "Access group storage",
	--[8] = ""
}

function meta:GroupHasPermission(act)
	local group = self:GetSyncVar(SYNC_GROUP_NAME, nil)
	local rank = self:GetSyncVar(SYNC_GROUP_RANK, nil)

	if not group or not rank then
		return false
	end

	local groupData = impulse.Group.Groups[group]

	if not groupData then
		return false
	end
	
	if not groupData.Ranks[rank] then
		return false
	end

	if not groupData.Ranks[rank][act] then
		return false
	end

	return true
end