DeriveGamemode("sandbox")
MsgC( Color( 83, 143, 239 ), "[IMPULSE] Starting client load...\n" )

impulse = {} -- defining global function table
impulse.meta = FindMetaTable( "Player" )
impulse.lib = {}

include("shared.lua")
MsgC( Color( 0, 255, 0 ), "[IMPULSE] Completed client load...\n" )
