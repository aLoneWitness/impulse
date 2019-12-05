function impulse.Ops.EventManager.GetEventMode()
    return GetGlobalBool("opsEventMode", false)
end

function impulse.Ops.EventManager.GetSequence()
    return GetGlobalBool("opsEventMode", false)
end

function impulse.Ops.EventManager.SetEventMode(val)
	return SetGlobalBool("opsEventMode", val)
end

function impulse.Ops.EventManager.SetSequence(val)
	return SetGlobalString("opsEventSequence", val)
end

function impulse.Ops.EventManager.GetEvent()
	return impulse_OpsEM_CurEvent
end

function meta:IsEventAdmin()
	return self:IsSuperAdmin() or (self:IsAdmin() and impulse.Ops.EventManager.GetEventMode())
end