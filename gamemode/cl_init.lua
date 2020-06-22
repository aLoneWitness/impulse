/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

DeriveGamemode("sandbox")
MsgC( Color( 83, 143, 239 ), "[impulse] Starting client load...\n" )

impulse = impulse or {} -- defining global function table
impulse.meta = FindMetaTable( "Player" )
impulse.lib = {}

include("shared.lua")
MsgC( Color( 0, 255, 0 ), "[impulse] Completed client load...\n" )

timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")
hook.Remove("PreDrawHalos", "PropertiesHover")
RunConsoleCommand("cl_showhints",  "0") -- disable annoying gmod hints by default
