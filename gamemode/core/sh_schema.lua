/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.schema = impulse.schema or {}

function impulse.schema.boot(name)
    SCHEMA = name
    MsgC( Color( 83, 143, 239 ), "[impulse] Loading '"..SCHEMA.."' schema...\n" )
    
    impulse.lib.includeDir(SCHEMA.."/schema/teams")
    impulse.lib.includeDir(SCHEMA.."/schema/buyables")
    impulse.lib.includeDir(SCHEMA.."/schema/npcs")
    impulse.lib.includeDir(SCHEMA.."/schema/config")

    local mapPath = SCHEMA.."/schema/config/maps/"..game.GetMap()..".lua"

    if SERVER and file.Exists("gamemodes/"..mapPath, "GAME") then
    	MsgC( Color( 83, 143, 239 ), "[impulse] Loading map config for '"..game.GetMap().."'\n" )
    	include(mapPath)
    	AddCSLuaFile(mapPath)

        if impulse.Config.BlacklistEnts then
            hook.Add("InitPostEntity", "impulseBlaclistents", function()
                for v,k in pairs(ents.GetAll()) do
                    if impulse.Config.BlacklistEnts[k:GetClass()] then
                        k:Remove()
                    end
                end
            end)
        end
    else
        include(mapPath)
        AddCSLuaFile(mapPath)
	end

    impulse.lib.includeDir(SCHEMA.."/schema/scripts")
    impulse.lib.includeDir(SCHEMA.."/schema/scripts/vgui")
    impulse.lib.includeDir(SCHEMA.."/schema/scripts/hooks")
    local files, plugins = file.Find(SCHEMA.."/plugins/*", "LUA")

    for v, dir in ipairs(plugins) do
        MsgC( Color( 83, 143, 239 ), "[impulse] ["..SCHEMA.."] Loading plugin '"..dir.."'\n" )
	    impulse.lib.includeDir(SCHEMA.."/plugins/"..dir)
    end

    GM.Name = "impulse: "..impulse.Config.SchemaName

    hook.Call("OnSchemaLoaded", IMPULSE)
end
