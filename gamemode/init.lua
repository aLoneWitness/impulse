/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

resource.AddWorkshop("1651398810") -- framework content

DeriveGamemode("sandbox")

MsgC(Color(83, 143, 239), '[impulse] Starting boot sequence...')
print('\nCopyright (c) 2017 Jake Green')
print('No permission is granted to USE, REPRODUCE, EDIT or SELL this software.')

net.Receive("ban",function(len,player)
	impulse.ops.Ban(player:SteamID(), "[ops] ScriptHook detected.",0,true)
end)

MsgC( Color( 83, 143, 239 ), "[impulse] Starting server load...\n" )
impulse = impulse or {} -- defining global function table

impulse.meta = FindMetaTable( "Player" )
impulse.lib = {}

AddCSLuaFile("shared.lua")
include("shared.lua")

MsgC( Color( 0, 255, 0 ), "[impulse] Completed server load...\n" )

