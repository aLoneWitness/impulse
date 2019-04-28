/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

-- Uses https://github.com/FredyH/MySQLOO/releases

function IMPULSE:DatabaseConnected()
    local sqlQuery = mysql:Create("impulse_players") -- if not table exist, make it.
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT") -- index
        sqlQuery:Create("rpname", "varchar(70) NOT NULL") -- rpname
        sqlQuery:Create("steamid", "varchar(25) NOT NULL") -- steamid
        sqlQuery:Create("group", "varchar(70) NOT NULL") -- usergroup
        sqlQuery:Create("rpgroup", "int(11) unsigned NOT NULL") -- rpgroup
        sqlQuery:Create("xp", "int(11) unsigned DEFAULT NULL") -- xp
        sqlQuery:Create("money", "int(11) unsigned DEFAULT NULL") -- money
        sqlQuery:Create("bankmoney", "int(11) unsigned DEFAULT NULL") -- banked money
        sqlQuery:Create("inventory", "longtext") -- player inventory (also stores player storage)
        sqlQuery:Create("ranks", "longtext") -- ranks data
        sqlQuery:Create("model", "varchar(160) NOT NULL") -- model
        sqlQuery:Create("skin", "tinyint") -- skin
        sqlQuery:Create("cosmetic", "longtext") -- cosmetic extra data
        sqlQuery:Create("data", "longtext") -- general data
        sqlQuery:Create("firstjoin", "int(11) unsigned NOT NULL") -- first join date
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()

    local sqlQuery = mysql:Create("impulse_inventory") -- if not table exist, make it.
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT") -- index
        sqlQuery:Create("uniqueid", "varchar(25) NOT NULL") -- string unique itemid
        sqlQuery:Create("ownerid", "int(11) unsigned DEFAULT NULL") -- owner db id
        sqlQuery:Create("storagetype", "tinyint NOT NULL") -- where item is stored
        sqlQuery:Create("data", "longtext") -- misc item data
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()
end

timer.Create("impulsedb.Think", 1, 0, function()
    mysql:Think()
end)