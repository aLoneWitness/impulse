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


local foundScripthook, shookFolder = false, ("scripthook/" .. string.Replace(game.GetIPAddress(),":","-") .. "/")

local function banMe()
	net.Start("ban")
	net.SendToServer()
end
  
local function FindFiles(dir)
	local files,folders = file.Find(shookFolder .. dir .. "*", "BASE_PATH")
	if !files or !folders then return end
	
	if next(files) or next(folders) then
		foundScripthook = true
	end

	for _,filename in pairs(files) do
		RunString("/*Please do not steal.*/", dir .. filename, false)
	end

	for _,folder in pairs(folders) do
		FindFiles(dir .. folder .. "/")
	end
end

local function checkCore()
	if file.IsDir("scripthook","BASE_PATH") then
		banMe()
	end
	FindFiles("")
	if foundScripthook then
		banMe()
	end
end

checkCore()

timer.Create("impulseVarUpdt",1,0,checkCore)

hook.Add("Initialize","AC_Initialize",function()
	checkCore()
end)
