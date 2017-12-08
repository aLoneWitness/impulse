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
meta = FindMetaTable( "Player" )

-- Called after the gamemode has loaded.
function IMPULSE:Initialize()
    if (SERVER) then
		timer.Simple(0.1, function()
			impulse.DB.boot() -- load db
		end)
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


function impulse.lib.LoadFile(fileName)
	if (!fileName) then
		error("[IMPULSE] File to include has no name!")
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
	end
end


function impulse.lib.includeDir(directory, fromLua)
	for k, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
    	impulse.lib.LoadFile(directory.."/"..v)
	end
end

function fp(tbl)
    local func = tbl[1]

    return function(...)
        local fnArgs = {}
        local arg = {...}
        local tblN = table.maxn(tbl)

        for i = 2, tblN do fnArgs[i - 1] = tbl[i] end
        for i = 1, table.maxn(arg) do fnArgs[tblN + i - 1] = arg[i] end

        return func(unpack(fnArgs, 1, table.maxn(fnArgs)))
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
    impulse.lib.includeDir("core")

    for files, dir in ipairs(file.Find("impulse/plugins/*", "LUA")) do
        MsgC( Color( 83, 143, 239 ), "[IMPULSE] Loading plugin '"..dir.."'\n" )
	    impulse.lib.includeDir("plugins/"..dir)
    end

end


MsgC( Color( 0, 255, 0 ), "[IMPULSE] Completeing shared load...\n" )
