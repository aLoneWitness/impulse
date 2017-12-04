/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

DeriveGamemode("sandbox")

MsgC(Color(83, 143, 239), '[IMPULSE] Starting boot sequence...')
print('Copyright (c) 2017 Jake Green')
print('No permission is granted to USE, REPRODUCE, EDIT or SELL this software.')

MsgC( Color( 83, 143, 239 ), "[IMPULSE] Starting server load...\n" )
impulse = {} -- defining global function table

impulse.meta = FindMetaTable( "Player" )
impulse.lib = {}

AddCSLuaFile("shared.lua")
include("shared.lua")

MsgC( Color( 0, 255, 0 ), "[IMPULSE] Completed server load...\n" )


