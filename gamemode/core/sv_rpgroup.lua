--- Handles the creation and editing of player groups
-- @module Group

local DEFAULT_RANKS = pon.encode({
	["Owner"] = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[99] = true
	},
	["Member"] = {
		[0] = true,
		[1] = true,
		[2] = true
	}
})

function impulse.Group.DBCreate(name, ownerid, maxsize, maxstorage, ranks, callback)
	impulse.Group.IsNameUnique(name, function(unique)
		if unique then
			local query = mysql:Insert("impulse_rpgroups")
			query:Insert("ownerid", ownerid)
			query:Insert("name", name)
			query:Insert("maxsize", maxsize)
			query:Insert("maxstorage", maxstorage)
			query:Insert("ranks", ranks and pon.encode(ranks) or DEFAULT_RANKS)
			query:Callback(function(result, status, id)
				if callback then
					callback(id)
				end
			end)

			query:Execute()
		end
	end)
end

function impulse.Group.DBAddPlayer(steamid, groupid, rank)
	local query = mysql:Update("impulse_players")
	query:Update("rpgroup", groupid)
	query:Update("rpgrouprank", rank or impulse.Group.GetDefaultRank(name, groupid))
	query:Where("steamid", steamid)
	query:Execute()
end

function impulse.Group.DBRemovePlayer(steamid, groupid)
	local query = mysql:Update("impulse_players")
	query:Update("rpgroup", nil)
	query:Update("rpgrouprank", "")
	query:Where("steamid", steamid)
	query:Execute()
end

function impulse.Group.ComputeMembers(name, callback)
	local id = impulse.Group.Groups[name].ID

	local query = mysql:Select("impulse_players")
	query:Select("steamid")
	query:Select("rpname")
	query:Select("rpgroup")
	query:Select("rpgrouprank")
	query:Where("rpgroup", id)
	query:Callback(function(result)
		local members = {}
		local membercount = 0

		if type(result) == "table" and #result > 0 then
			for v,k in pairs(result) do
				membercount = membercount + 1
				members[k.steamid] = {Name = k.rpname, Rank = k.rpgrouprank or impulse.Group.GetDefaultRank(name)}
			end
		end

		impulse.Group.Groups[name].Members = members
		impulse.Group.Groups[name].MemberCount = membercount

		if callback then
			callback()
		end
	end)

	query:Execute()
end

function impulse.Group.GetDefaultRank(name)
	local data = impulse.Group.Groups[name]

	for v,k in pairs(data.Ranks) do
		if k[0] then
			return v
		end
	end

	return "Member"
end

function impulse.Group.NetworkMember(to, name, sid)
	local member = impulse.Group.Groups[name].Members[sid]

	net.Start("impulseGroupMember")
	net.WriteString(sid)
	net.WriteString(member.Name)
	net.WriteString(member.Rank)
	net.Send(to)
end

function impulse.Group.NetworkMemberToOnline(name, sid)
	local member = impulse.Group.Groups[name].Members[sid]

	local rf = RecipientFilter()

	for v,k in pairs(player.GetAll()) do
		local x = k:GetSyncVar(SYNC_GROUP_NAME, nil)

		if x and x == name then
			rf:AddPlayer(k)
		end
	end

	net.Start("impulseGroupMember")
	net.WriteString(sid)
	net.WriteString(member.Name)
	net.WriteString(member.Rank)
	net.Send(rf)
end

function impulse.Group.NetworkMemberRemoveToOnline(name, sid)
	local rf = RecipientFilter()

	for v,k in pairs(player.GetAll()) do
		local x = k:GetSyncVar(SYNC_GROUP_NAME, nil)

		if x and x == name then
			rf:AddPlayer(k)
		end
	end

	net.Start("impulseGroupMemberRemove")
	net.WriteString(sid)
	net.Send(rf)
end

function impulse.Group.NetworkAllMembers(to, name)
	local members = impulse.Group.Groups[name].Members

	for v,k in pairs(members) do
		impulse.Group.NetworkMember(to, name, v)
	end
end

function impulse.Group.NetworkRanks(to, name)
	local ranks = impulse.Group.Groups[name].Ranks
	local data = pon.encode(ranks)

	net.Start("impulseGroupRanks")
	net.WriteUInt(#data, 32)
	net.WriteData(data, #data)
	net.Send(to)
end

function meta:GroupAdd(name, rank)
	local id = impulse.Group.Groups[name].ID
	impulse.Group.DBAddPlayer(self:SteamID(), id, rank or impulse.Group.GetDefaultRank())
	impulse.Group.ComputeMembers(name, function()
		if not IsValid(self) then
			return
		end

		impulse.Group.NetworkMemberToOnline(name, self:SteamID())

		self:SetSyncVar(SYNC_GROUP_NAME, name, true)
		self:SetSyncVar(SYNC_GROUP_RANK, rank, true)
		impulse.Group.NetworkAllMembers(self, name)

		if self:HasGroupPermission(5) or self:HasGroupPermission(6) then
			impulse.Group.NetworkRanks(self, name)
		end
	end)
end

function meta:GroupRemove(name)
	local id = impulse.Group.Groups[name].ID
	impulse.Group.DBRemovePlayer(self:SteamID())
	impulse.Group.ComputeMembers(name)

	self:SetSyncVar(SYNC_GROUP_NAME, nil, true)
	self:SetSyncVar(SYNC_GROUP_RANK, nil, true)
end

function meta:GroupLoad(groupid, rank)
	impulse.Group.Load(groupid, function(name)
		if not IsValid(self) then
			return
		end

		impulse.Group.ComputeMembers(name, function()
			if not IsValid(self) then
				return
			end

			impulse.Group.NetworkAllMembers(self, name)

			if self:GroupHasPermission(5) or self:GroupHasPermission(6) then
				impulse.Group.NetworkRanks(self, name)
			end
		end)

		if rank then
			if not impulse.Group.Groups[name].Ranks[rank] then
				rank = impulse.Group.GetDefaultRank(name)
			end
		end

		rank = rank or impulse.Group.GetDefaultRank(name)
		self:SetSyncVar(SYNC_GROUP_NAME, name, true)
		self:SetSyncVar(SYNC_GROUP_RANK, rank, true)
	end)
end

function impulse.Group.IsNameUnique(name, callback)
	local query = mysql:Select("impulse_rpgroups")
	query:Select("name")
	query:Where("name", name)
	query:Callback(function(result)
		if type(result) == "table" and #result > 0 then
			return callback(false)
		else
			return callback(true)
		end
	end)

	query:Execute()
end

function impulse.Group.Load(id, onLoaded)
	local query = mysql:Select("impulse_rpgroups")
	query:Select("ownerid")
	query:Select("name")
	query:Select("type")
	query:Select("maxsize")
	query:Select("maxstorage")
	query:Select("ranks")
	query:Select("data")
	query:Where("id", id)
	query:Callback(function(result)
		if type(result) == "table" and #result > 0 then
			local data = result[1]

			if impulse.Group.Groups[data.name] then
				return onLoaded(data.name)
			end

			impulse.Group.Groups[data.name] = {
				ID = id,
				OwnerID = data.ownerid,
				Type = data.type,
				MaxSize = data.maxsize,
				MaxStorage = data.maxstorage,
				Ranks = pon.decode(data.ranks),
				Data = data.data or {}
			}

			if onLoaded then
				onLoaded(data.name)
			end
		end
	end)

	query:Execute()
end