/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

-- Define gamemode information.
GM.Name = "impulse"
GM.Author = "vin"
GM.Website = "https://www.vingard.ovh"
GM.Version = 0.8
MsgC( Color( 83, 143, 239 ), "[impulse] Starting shared load...\n" )
IMPULSE = GM
meta = FindMetaTable("Player")

-- Called after the gamemode has loaded.
function IMPULSE:Initialize()
	impulse.reload()
end

-- Called when a file has been modified.
function IMPULSE:OnReloaded()
	impulse.reload()
end

if (SERVER) then
	concommand.Remove("gm_save")
	concommand.Remove("gmod_admin_cleanup")
	RunConsoleCommand("sv_defaultdeployspeed", 1)
end

-- disable widgets cause it uses like 30% server cpu lol
function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")

function impulse.lib.LoadFile(fileName)
	if (!fileName) then
		error("[impulse] File to include has no name!")
	end

	if fileName:find("sv_") then
		if (SERVER) then
			include(fileName)
		end
	elseif fileName:find("sh_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end
		include(fileName)
	elseif fileName:find("cl_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	elseif fileName:find("rq_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		_G[string.sub(fileName, 26, string.len(fileName) - 4)] = include(fileName)
	end
end

function impulse.lib.includeDir(directory, fromLua)
	for k, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
    	impulse.lib.LoadFile(directory.."/"..v)
	end
end

local function GetDBCFG(name, isInt)
	local name = "impulse_db_"..name
	local convar = GetConVar(name)

	if isInt then
		if convar:GetInt() == convar:GetDefault() then
			return nil
		end

		return convar:GetInt()
	else
		if convar:GetString() == convar:GetDefault() then
			return nil
		end

		return convar:GetString()
	end
end

-- Loading 3rd party libs
impulse.lib.includeDir("impulse/gamemode/libs")
-- Load config
impulse.Config = impulse.Config or {}

-- Load DB
if SERVER then
	CreateConVar("impulse_db_ip", "0", FCVAR_PROTECTED)
	CreateConVar("impulse_db_username", "0", FCVAR_PROTECTED)
	CreateConVar("impulse_db_password", "0", FCVAR_PROTECTED)
	CreateConVar("impulse_db_database", "0", FCVAR_PROTECTED)
	CreateConVar("impulse_db_port", 0, FCVAR_PROTECTED)

	impulse.DB = {
		ip = GetDBCFG("ip") or "localhost",
		username = GetDBCFG("username") or "root",
		password = GetDBCFG("password") or "",
		database = GetDBCFG("database") or "impulse_development",
		port = GetDBCFG("port", true) or 3306
	}

	mysql:Connect(impulse.DB.ip, impulse.DB.username, impulse.DB.password, impulse.DB.database, 3306)
end
-- Load core
impulse.lib.includeDir("impulse/gamemode/core")
-- Load core vgui elements
impulse.lib.includeDir("impulse/gamemode/core/vgui")
-- Load hooks
impulse.lib.includeDir("impulse/gamemode/core/hooks")
-- Create impulse folder
file.CreateDir("impulse")

function impulse.reload()
    MsgC( Color( 83, 143, 239 ), "[impulse] Reloading gamemode...\n" )
    impulse.lib.includeDir("impulse/gamemode/core")

	local files, folders = file.Find("impulse/plugins/*", "LUA")

    for v, plugin in ipairs(folders) do
        MsgC( Color( 83, 143, 239 ), "[impulse] Loading plugin '"..plugin.."'\n" )
        impulse.lib.includeDir("impulse/plugins/"..plugin.."/setup")
	    impulse.lib.includeDir("impulse/plugins/"..plugin)
	    impulse.lib.includeDir("impulse/plugins/"..plugin.."/vgui")
	    impulse.lib.includeDir("impulse/plugins/"..plugin.."/hooks")
    end
end


MsgC( Color( 0, 255, 0 ), "[impulse] Completeing shared load...\n" )
