function LoadSaveEnts()
	if file.Exists( "impulse/"..string.lower(game.GetMap())..".txt", "DATA") then
		local savedEnts = util.JSONToTable( file.Read( "impulse/" .. string.lower( game.GetMap() ) .. ".txt" ) )
		for v,k in pairs(savedEnts) do
			local x = ents.Create(k.class)
			x:SetPos(k.pos)
			x:SetAngles(k.angle)
			
			if k.class == "prop_physics" or k.class == "prop_dynamic" then
				x:SetModel(k.model)
			end
			x.impulseSaveEnt = true

			if k.keyvalue then
				x.impulseSaveKeyValue = k.keyvalue
			end

			x:Spawn()
			x:Activate()

			local phys = x:GetPhysicsObject()

			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end
		end
	end
end

concommand.Add("impulse_save_saveall", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	local savedEnts = {}

	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			table.insert(savedEnts, {pos =  k:GetPos(), angle = k:GetAngles(), class = k:GetClass(), model = k:GetModel(), keyvalue = (k.impulseSaveKeyValue or nil)})
		end
	end

	file.Write("impulse/"..string.lower(game.GetMap())..".txt", util.TableToJSON(savedEnts))

	ply:AddChatText("All marked ents have been saved, all un-marked ents have been omitted from the save.")
end)

concommand.Add("impulse_save_reload", function(ply)
	if not ply:IsSuperAdmin() then return end
	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt then
			k:Remove()
		end
	end

	LoadSaveEnts()

	ply:AddChatText("All saved ents have been reloaded.")
end)

concommand.Add("impulse_save_mark", function(ply)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) then
		ent.impulseSaveEnt = true
		ply:AddChatText("Marked "..ent:GetClass().." for saving.")
	end
end)

concommand.Add("impulse_save_unmark", function(ply)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) then
		ent.impulseSaveEnt = nil
		ent:Remove()
		ply:AddChatText("Removed "..ent:GetClass().." for saving.")
	end
end)

concommand.Add("impulse_save_keyvalue", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity
	local key = args[1]
	local value = args[2]

	if not key or not value then
		return ply:AddChatText("Missing key/value.")
	end

	if IsValid(ent) then
		if ent.impulseSaveEnt then
			if tonumber(value) then
				value = tonumber(value)
			end

			ent.impulseSaveKeyValue = ent.impulseSaveKeyValue or {}
			ent.impulseSaveKeyValue[key] = value
			ply:AddChatText("Key/Value ("..key.."="..value..") pair set on "..ent:GetClass()..".")
		else
			ply:AddChatText("Mark this entity for saving first.")
		end
	end
end)

concommand.Add("impulse_save_printkeyvalues", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) then
		if ent.impulseSaveEnt then
			if not ent.impulseSaveKeyValue then
				return ply:AddChatText("Entity has no keyvalue table.")
			end

			ply:AddChatText(table.ToString(ent.impulseSaveKeyValue))
		else
			ply:AddChatText("Entity not saving marked.")
		end
	end
end)

concommand.Add("impulse_save_help", function(ply)
	if not ply:IsSuperAdmin() then return end
	
	ply:AddChatText("Mark entities you want to save with save_mark and save_unmark. Ensure all entities are in correct state/position before using save_saveall to save them. Then use save_reload to cleanup.")
end)