impulse.schema = impulse.schema or {} 

function impulse.schema.boot()
    SCHEMA = {GM.FolderName}
    MsgC( Color( 83, 143, 239 ), "[IMPULSE] Loading '"..SCHEMA.."' schema...\n" )
    impulse.lib.includeDir(SCHEMA.."/config")
    impulse.lib.includeDir(SCHEMA.."/autorun")

    for files, dir in ipairs(file.Find(SCHEMA.."/plugins/*", "LUA")) do
        MsgC( Color( 83, 143, 239 ), "[IMPULSE] ["..SCHEMA.."] Loading plugin '"..dir.."'\n" )
	    impulse.lib.includeDir(dir)
    end

end
    hook.Run('SchemaLoad')
end