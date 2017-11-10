-- Uses https://facepunch.com/showthread.php?t=1515853
require("mysqloo")

function impulse.DB.boot()
    impulse.DB.object = mysqloo.connect( impulse.DB.ip, impulse.DB.username, impulse.DB.password, impulse.DB.database, 3306 )
    local database = impulse.DB.object
    database.onConnected = function() 
        MsgC(Color(0,255,0),"[IMPULSE] Database connection established.\n") 
    end
	database.onConnectionFailed = function(error) 
	    MsgC(Color(0,255,0),"[IMPULSE] Database connection failure. Error dump: ("..error..")\n") 
	end
	database:connect()
end

local function dbAuth()
    
    
end
hook.Add("PlayerAuthed","IMPULSE-DATABASE-AUTH",dbAuth)