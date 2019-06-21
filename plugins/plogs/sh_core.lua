function plogs.Register(type, network, color)
	plogs.types[type] = plogs.types[type] or {
		Type 	= type, 
		Network = network and plogs.cfg.EchoServer or network, 
		Color 	= color
	}
	plogs.data[type] = plogs.data[type] or {}
	return t
end

local count = 0
function plogs.AddHook(hook_name, func)
	if (SERVER) then
		hook.Add(hook_name, 'plogs.loghook.' .. hook_name, func)
	end
end

function plogs.Encode(data)
	return util.Compress(pon1.encode(data))
end

function plogs.Decode(data)
	return pon1.decode(util.Decompress(data))
end

function plogs.GetSaves()
	local files = file.Find('plogs/saves/*.dat', 'DATA', 'datedesc')
	for k, v in ipairs(files) do
		files[k] = string.StripExtension(v)
	end
	return files
end

function plogs.OpenSave(name)
	return plogs.Decode(file.Read('plogs/saves/' .. name .. '.dat', 'DATA'))
end

function plogs.DeleteSave(name)
	file.Delete('plogs/saves/' .. name .. '.dat')
end

function plogs.SaveExists(name)
	return file.Exists('plogs/saves/' .. string.Trim(name) .. '.dat', 'DATA')
end

function plogs.SaveLog(name, tbl)
	file.Write('plogs/saves/' .. string.Trim(name) .. '.dat', plogs.Encode(tbl)) 
end

local logsCommand = {
    description = "Opens the event logs.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        plogs.OpenMenu(ply)
    end
}

impulse.RegisterChatCommand("/logs", logsCommand)