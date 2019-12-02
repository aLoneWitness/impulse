function impulse.Ops.EventManager.GetEventMode()
    return GetGlobalBool("opsEventMode", false)
end

function impulse.Ops.EventManager.SetEventMode(val)
	return SetGlobalBool("opsEventMode", val)
end

function meta:IsEventAdmin()
	return self:IsSuperAdmin() or (self:IsAdmin() and impulse.Ops.EventManager.GetEventMode())
end

function impulse.Ops.EventManager.SequenceLoad(filename, sequence)
	local fileData = file.Read("impulse/ops/eventmanager/"..filename..".json")
	local json = util.JSONToTable(fileData)

	if not json or not istable(json) then
		return false, "Corrupted sequence file"
	end


end