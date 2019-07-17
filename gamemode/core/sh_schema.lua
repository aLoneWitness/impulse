/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.Schema = impulse.Schema or {}

function impulse.Schema.Boot(name)
    SCHEMA = name
    MsgC(Color( 83, 143, 239 ), "[impulse] Loading '"..SCHEMA.."' schema...\n")
    
    impulse.lib.includeDir(SCHEMA.."/schema/teams")
    impulse.lib.includeDir(SCHEMA.."/schema/items")
    impulse.lib.includeDir(SCHEMA.."/schema/benches")
    impulse.lib.includeDir(SCHEMA.."/schema/mixtures")
    impulse.lib.includeDir(SCHEMA.."/schema/buyables")
    impulse.lib.includeDir(SCHEMA.."/schema/npcs")
    impulse.lib.includeDir(SCHEMA.."/schema/config")

    local mapPath = SCHEMA.."/schema/config/maps/"..game.GetMap()..".lua"

    if SERVER and file.Exists("gamemodes/"..mapPath, "GAME") then
    	MsgC(Color( 83, 143, 239 ), "[impulse] Loading map config for '"..game.GetMap().."'\n")
    	include(mapPath)
    	AddCSLuaFile(mapPath)
        
        if impulse.Config.MapWorkshopID then
            resource.AddWorkshop(impulse.Config.MapWorkshopID)
        end
    elseif CLIENT then
        include(mapPath)
        AddCSLuaFile(mapPath) 
    else
        MsgC(Color(255, 0, 0), "[impulse] No map config found!'\n")
	end

    impulse.lib.includeDir(SCHEMA.."/schema/scripts")
    impulse.lib.includeDir(SCHEMA.."/schema/scripts/vgui")
    impulse.lib.includeDir(SCHEMA.."/schema/scripts/hooks")
    local files, plugins = file.Find(SCHEMA.."/plugins/*", "LUA")

    for v, dir in ipairs(plugins) do
        MsgC(Color( 83, 143, 239 ), "[impulse] ["..SCHEMA.."] Loading plugin '"..dir.."'\n")
        impulse.lib.includeDir(SCHEMA.."/plugins/"..dir.."/setup")
	    impulse.lib.includeDir(SCHEMA.."/plugins/"..dir)
        impulse.lib.includeDir(SCHEMA.."/plugins/"..dir.."/vgui")
        impulse.lib.includeDir(SCHEMA.."/plugins/"..dir.."/hooks")
    end

    GM.Name = "impulse: "..impulse.Config.SchemaName

    hook.Call("OnSchemaLoaded", IMPULSE)
end

function impulse.Schema.LoadPlugin()
    -- maybe do a object plugin thing to make hook.add neat
end