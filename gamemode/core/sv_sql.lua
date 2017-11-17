-- Uses https://facepunch.com/showthread.php?t=1515853
require("mysqloo")

local baseTables = [[
CREATE TABLE IF NOT EXISTS `impulse_pd` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_name` varchar(70) NOT NULL,
	`_group` text NOT NULL,
	`_cosmetic` varchar(180) NOT NULL,
	`_attributes` varchar(180) DEFAULT NULL,
	`_rpgroup` int(11) unsigned NOT NULL,
	`_steamid` bigint(20) unsigned NOT NULL,
	`_data` longtext,
	`_money` int(11) unsigned DEFAULT NULL,
	`_bankmoney` int(11) unsigned DEFAULT NULL,
	`_rank` varchar(50) NOT NULL,
	'_blacklists' varchar(180) NOT NULL,
	PRIMARY KEY (`_id`)
);
]]

function impulse.DB.boot()
    impulse.DB.object = mysqloo.connect( impulse.DB.ip, impulse.DB.username, impulse.DB.password, impulse.DB.database, 3306 )
    local database = impulse.DB.object
    function database:onConnected()
        MsgC(Color(0,255,0),"[IMPULSE] Database connection established.\n")
        self:query(baseTables)
        hook.Run('DbLoad',self)
    end
	function database:onConnectionFailed(error) 
	    return MsgC(Color(255,0,0),"[IMPULSE] Database connection failure. Error dump: ("..error..")\n") 
	end
	database:connect()
	
end

function impulse.DB.escape(val)
   return impulse.DB.object:escape(val) 
end

function impulse.DB.query(data,name)
    local query = impulse.DB.object:query(data)
    
    function query:onError(err,sql)
        if name then
            MsgC(Color(255,0,0),"[IMPULSE] Query failure! (NAME: "..name.." ERROR: "..err.." QUERY: "..sql) 
        else
            MsgC(Color(255,0,0),"[IMPULSE] Query failure! (ERROR: "..err.." QUERY: "..sql) 
        end
        
       -- Logging system coming soon.
    end
    
    query:start()
    
    return query
end

function meta:GetData()
    local id = self:SteamID()
    return pon.decode(impulse.DB.query("'SELECT data FROM impulse_pd WHERE steamid = '"..id.."'","IMPULSE GET DATA"))
end


local function dbAuth(player,id)
    local check = impulse.DB.query("SELECT steamid FROM impulse_pd WHERE steamid = '"..id.."'","IMPULSE-PC-CHECK")
    if not check then
        impulse.DB.query("INSERT INTO impulse_pd ('steamid') VALUES ('"..id.."')", "IMPULSE FIRST TIME JOIN")
    end
    hook.Run('PlayerDbAuth', player)
end
hook.Add("PlayerAuthed","IMPULSE-DATABASE-AUTH",dbAuth)