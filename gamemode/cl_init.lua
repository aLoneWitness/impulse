/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

DeriveGamemode("sandbox")
MsgC( Color( 83, 143, 239 ), "[IMPULSE] Starting client load...\n" )

impulse = {} -- defining global function table
impulse.meta = FindMetaTable( "Player" )
impulse.lib = {}

include("shared.lua")
MsgC( Color( 0, 255, 0 ), "[IMPULSE] Completed client load...\n" )
