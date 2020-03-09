file.CreateDir("impulse/menumsgs")

impulse.MenuMessage = impulse.MenuMessage or {}
impulse.MenuMessage.Data = impulse.MenuMessage.Data or {}

function impulse.MenuMessage.Add(uid, title, xmessage, xcol, url, urlText, expiry)
	if impulse.MenuMessage.Data[uid] then
		return
	end

	impulse.MenuMessage.Data[uid] = {
		type = uid,
		title = title,
		message = xmessage,
		colour = xcol or impulse.Config.MainColour,
		url = url or nil,
		urlText = urlText or nil,
		expiry = expiry or nil
	}
end

function impulse.MenuMessage.Remove(uid)
	local msg = impulse.MenuMessage.Data[uid]
	if not msg then
		return
	end

	impulse.MenuMessage.Data[uid] = nil

	local fname = "impulse/menumsgs/"..uid..".dat"

	if file.Exists(fname, "DATA") then
		file.Delete(fname)
	end
end

function impulse.MenuMessage.Save(uid)
	local msg = impulse.MenuMessage.Data[uid]
	if not msg then
		return
	end

	local compiled = util.TableToJSON(msg)

	file.Write("impulse/menumsgs/"..uid..".dat", compiled)
end

function impulse.MenuMessage.CanSee(uid)
	local msg = impulse.MenuMessage.Data[uid]

	if not msg then
		return
	end

	if not msg.scheduled then
		return true
	end

	if msg.scheduledTime and msg.scheduledTime != 0 then
		if os.time() > msg.scheduledTime then
			return true
		end
	end

	return false
end