/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

loadCache = loadCache or {} -- Lua refresh support.

function impulse.PrepModelForLoad(model)
    local generatedtable = {model, 1}
    if not impulse.loaded then -- if we have not loaded in yet
        table.insert(loadCache,generatedtable) -- prepare for load
    else
        util.PrecacheModel(model) -- load now
    end
end

function impulse.PrepSoundForLoad(sound)
    local generatedtable = {sound, 2}
    if not impulse.loaded then
        table.insert(loadCache,generatedtable)
    else
        util.PrecacheSound(sound)
    end
end

function impulse.TriggerLoad(table) -- will load assets from a impulse loadCache table, you can get this with impulse.GetLoadCache()
   if table[2] == 1 then -- if type is model
       util.PrecacheModel(table[1])
   elseif table[2] == 2 then -- if type is sound
       util.PrecacheSound(table[1])
   end
end

function impulse.GetLoadCache()
    return loadCache
end