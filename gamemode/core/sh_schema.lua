impulse.schema = impulse.schema or {} 

function impulse.schema.boot()
    SCHEMA = {GM.FolderName}
    -- PLUGIN LOADING AND TEAM/CONFIG LOADING HERE
    hook.Run('SchemaLoad')
end