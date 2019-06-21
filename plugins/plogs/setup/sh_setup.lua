local include_sv = (SERVER) and include or function() end
local include_cl = (SERVER) and AddCSLuaFile or include
local include_sh = function(path) include_sv(path) include_cl(path) end

plogs		= plogs			or {}
plogs.cfg 	= plogs.cfg 	or {}
plogs.types	= plogs.types	or {}
plogs.data	= plogs.data	or {}

plogs.Version = '2.7.1'

function plogs.Error(str)
	return ErrorNoHalt('[logs] ' .. str)
end

if (not file.IsDir('plogs/saves', 'data')) then
	file.CreateDir('plogs/saves')
end

--
-- General configs
--

-- User groups that can access the logs.
plogs.cfg.UserGroups = {
	['superadmin'] 	= true,
	['admin'] 		= true,
	['supermod']    = true,
	['moderator'] 	= true
}
-- User groups that can access IP logs
plogs.cfg.IPUserGroups = {
	['superadmin']  = true
}

-- Window width percentage, I recomend no lower then 0.75
plogs.cfg.Width = 0.75

-- Window height percentage, I recomend no lower then 0.75
plogs.cfg.Height = 0.75

-- Some logs print to your client console. Enable this to print them to your server console too
plogs.cfg.EchoServer = false

-- Allow me to use logs on your server. (Disable if you're paranoid)
plogs.cfg.DevAccess = false

-- Do you want to store IP logs and playerevents? If enabled make sure to edit plogs_mysql_cfg.lua!
plogs.cfg.EnableMySQL = false

-- The log entry limit, the higher you make this the longer the menu will take to open.
plogs.cfg.LogLimit = 128

-- Format names with steamids? If true "aStoned(STEAMID)", if false just "aStoned"
plogs.cfg.ShowSteamID = true

-- Enable/Disable log types here. Set them to true to disable
plogs.cfg.LogTypes = {
	['chat'] 		= false,
	['commands']	= false,
	['connections'] = false,
	['kills'] 		= false,
	['props'] 		= false,
	['tools'] 		= false
}

--
-- Specific configs, if you disabled the log type that uses one of these the config it doesn't matter
--

-- Command log blacklist, blacklist commands here that dont need to be logged
plogs.cfg.CommandBlacklist = {}

-- Tool log blacklist, blacklist tools here that dont need to be logged
plogs.cfg.ToolBlacklist = {}