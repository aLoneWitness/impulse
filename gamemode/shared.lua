/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/


-- Define gamemode information.
GM.Name = "IMPULSE"
GM.Author = "TheVingard"
GM.Website = "https://www.apex-roleplay.com"
MsgC( Color( 83, 143, 239 ), "[IMPULSE] Starting shared load...\n" )
IMPULSE = GM

-- Called after the gamemode has loaded.
function IMPULSE:Initialize()
    if (SERVER) then
        impulse.DB.boot() -- Load database
    end
	impulse.reload()
end

-- Called when a file has been modified.
function IMPULSE:OnReloaded()
	impulse.reload()
end



if (SERVER and game.IsDedicated()) then
	concommand.Remove("gm_save")
end


function impulse.lib.LoadFile(fileName, state)
	if (!fileName) then
		error("[IMPULSE] File to include has no name!")
	end

	if ((state == "server" or fileName:find("sv_")) and SERVER) then
		include(fileName)
	elseif (state == "shared" or fileName:find("sh_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		include(fileName)
	elseif (state == "client" or fileName:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	end
end


function impulse.lib.includeDir(directory, fromLua)
	local baseDir = "impulse"
	for k, v in ipairs(file.Find((fromLua and "" or baseDir)..directory.."/*.lua", "LUA")) do
    	impulse.lib.include(directory.."/"..v)
	end
end

-- Loading 3rd party libs
impulse.lib.includeDir("impulse/gamemode/libs")
-- Load config
impulse.lib.includeDir("impulse/gamemode/config")
-- Load core
impulse.lib.includeDir("impulse/gamemode/core")
-- Load core third party
impulse.lib.includeDir("impulse/gamemode/core/3p")

function impulse.reload()
    MsgC( Color( 83, 143, 239 ), "[IMPULSE] Reloading gamemode...\n" )
    impulse.lib.includeDir("impulse/gamemode/core")

    for files, dir in ipairs(file.Find("impulse/plugins/*", "LUA")) do
        MsgC( Color( 83, 143, 239 ), "[IMPULSE] Loading plugin '"..dir.."'\n" )
	    impulse.lib.includeDir("impulse/plugins/"..dir)
    end

end


MsgC( Color( 0, 255, 0 ), "[IMPULSE] Completeing shared load...\n" )
