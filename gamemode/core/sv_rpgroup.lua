function impulse.Group.Create(name)

end

function impulse.Group.Load(id)
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
				return
			end

			impulse.Group.Groups[data.name] = {
				ID = id,
				OwnerID = data.ownerid,
				Type = data.type,
				MaxSize = data.maxsize,
				MaxStorage = data.maxstorage,
				Ranks = data.ranks,
				Data = data.data
			}
		end
	end)
	query:Execute()
end