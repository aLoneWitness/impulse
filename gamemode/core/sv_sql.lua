/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

-- Uses https://facepunch.com/showthread.php?t=1515853
require("mysqloo")

local baseTables = [[
CREATE TABLE IF NOT EXISTS `impulse_pd` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`name` varchar(70) NOT NULL,
	`group` text NOT NULL,
	`cosmetic` varchar(180) NOT NULL,
	`attributes` varchar(180) DEFAULT NULL,
	`rpgroup` int(11) unsigned NOT NULL,
	`steamid` bigint(20) unsigned NOT NULL,
	`playtime` bigint(25) unsigned NOT NULL,
	`data` longtext,
	`money` int(11) unsigned DEFAULT NULL,
	`bankmoney` int(11) unsigned DEFAULT NULL,
	`rank` varchar(50) NOT NULL,
	`blacklists` varchar(180) NOT NULL,
	PRIMARY KEY (`_id`)
);
]]

function impulse.DB.boot()
    impulse.DB.object = mysqloo.connect( impulse.DB.ip, impulse.DB.username, impulse.DB.password, impulse.DB.database, 3306 )
    local database = impulse.DB.object
    function database:onConnected()
        MsgC(Color(0,255,0),"[IMPULSE] Database connection established.\n")
        hook.Run('DbLoad',self)
    end
	function database:onConnectionFailed(error)
	    return MsgC(Color(255,0,0),"[IMPULSE] Database connection failure. Error dump: ("..error..")\n")
	end
	database:connect()

	impulse.DB.object:query(baseTables):start()
end

function impulse.DB.escape(val)
   return impulse.DB.object:escape(val)
end

function impulse.DB.query(data,name)
    local query = impulse.DB.object:query(data)

    function query:onError(err,sql)
        if name then
            MsgC(Color(255,0,0),"[IMPULSE] Query failure! (NAME: "..name.." ERROR: "..err.." QUERY: "..sql..")")
        else
            MsgC(Color(255,0,0),"[IMPULSE] Query failure! (ERROR: "..err.." QUERY: "..sql..")")
        end

       -- Logging system coming soon.
    end

	function query:onSuccess(data)
		return data
	end

    query:start()
end

function meta:GetData()
    local id = self:SteamID()
    return pon.decode(impulse.DB.query("SELECT data FROM impulse_pd WHERE steamid = '"..id.."'","IMPULSE GET DATA"))
end


local function dbAuth(player,id)
    local check = impulse.DB.query("SELECT steamid FROM impulse_pd WHERE steamid = '"..id.."'","IMPULSE-PC-CHECK")
	print("auth")
    if not check then
        impulse.DB.query("INSERT INTO impulse_pd (`steamid`) VALUES (`"..id.."`)", "IMPULSE FIRST TIME JOIN")
    end
    hook.Run('PlayerDbAuth', player)
end
hook.Add("PlayerAuthed","IMPULSE-DATABASE-AUTH",dbAuth)
