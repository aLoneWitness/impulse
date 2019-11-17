local setHealthCommand = {
    description = "Sets health of the specified player.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local targ = impulse.FindPlayer(arg[1])
        local hp = arg[2]

        if not hp then
            return
        end

        if targ and IsValid(targ) then
            targ:SetHealth(hp)
            ply:Notify("You have set "..targ:Nick().."'s health to "..hp..".")
        else
            return ply:Notify("Could not find player: "..tostring(arg[1]))
        end
    end
}

impulse.RegisterChatCommand("/sethp", setHealthCommand)

local kickCommand = {
    description = "Kicks the specified player from the server.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local plyTarget = impulse.FindPlayer(name)

        local reason = ""

        for v,k in pairs(arg) do
            if v != 1 then
                reason = reason.." "..k
            end
        end

        reason = string.Trim(reason)

        if reason == "" then reason = nil end

        if plyTarget and ply != plyTarget then
            ply:Notify("You have kicked "..plyTarget:Name().." from the server.")
            plyTarget:Kick(reason or "Kicked by a game moderator.")
        else
            return ply:Notify("Could not find player: "..tostring(name))
        end
    end
}

impulse.RegisterChatCommand("/kick", kickCommand)


if GExtension then
    local banCommand = {
        description = "Bans the specified player from the server. (time in minutes)",
        requiresArg = true,
        adminOnly = true,
        onRun = function(ply, arg, rawText)
            local name = arg[1]
            local plyTarget = impulse.FindPlayer(name)

            local time = arg[2]

            if not time or not isnumber(time) then
                return ply:Notify("No time value supplied.")
            end

            time = tonumber(time)

            if time < 0 then
                return ply:Notify("Negative time values are not allowed.")
            end

            local reason = ""

            for v,k in pairs(arg) do
                if v > 2 then
                    reason = reason.." "..k
                end
            end

            reason = string.Trim(reason)

            if plyTarget and ply != plyTarget then
                if ply:GE_CanBan(plyTarget:SteamID64(), time) then
                    plyTarget:GE_Ban(time, reason, ply:SteamID64())
                    ply:Notify("You have banned "..plyTarget:SteamName().." for "..time.." minutes.")
                else
                    ply:Notify("This user can not be banned.")
                end
            else
                return ply:Notify("Could not find player: "..tostring(name))
            end
        end
    }

    impulse.RegisterChatCommand("/ban", banCommand)

    local banIdCommand = {
        description = "Bans the specified SteamID from the server. (time in minutes)",
        requiresArg = true,
        adminOnly = true,
        onRun = function(ply, arg, rawText)
            local steamid = arg[1]
            local time = arg[2]

            if util.SteamIDTo64(steamid) then
                steamid = util.SteamIDTo64(steamid)
            elseif util.SteamIDFrom64(steamid) then
                steamid = steamid
            else
                ply:Notify("Invalid SteamID.")
            end

            if not time or not isnumber(time) then
                return ply:Notify("No time value supplied.")
            end

            time = tonumber(time)

            if time < 0 then
                return ply:Notify("Negative time values are not allowed.")
            end

            local reason = ""

            for v,k in pairs(arg) do
                if v > 2 then
                    reason = reason.." "..k
                end
            end

            reason = string.Trim(reason)

            if steamid then
                if ply:GE_CanBan(steamid, time) then
                    GExtension:Ban(steamid, time, reason, ply:SteamID64())
                    ply:Notify("You have banned "..steamid.." for "..time.." minutes.")
                else
                    ply:Notify("This user can not be banned.")
                end
            end
        end
    }

    impulse.RegisterChatCommand("/banid", banIdCommand)

    local warnCommand = {
        description = "Warns the specified player (reason is required).",
        requiresArg = true,
        adminOnly = true,
        onRun = function(ply, arg, rawText)
            local name = arg[1]
            local plyTarget = impulse.FindPlayer(name)
            local reason = ""

            for v,k in pairs(arg) do
                if v > 1 then
                    reason = reason.." "..k
                end
            end

            reason = string.Trim(reason)

            if reason == "" then
                return ply:Notify("No reason provided.")
            end

            if plyTarget and ply != plyTarget then
                if not ply:GE_HasPermission("warnings_add") then 
                    return ply:Notify("You don't have permission do this.")
                end
                
                GExtension:Warn(plyTarget:SteamID64(), reason, ply:SteamID64())
                ply:Notify("You have warned "..plyTarget:SteamName().." for "..reason..".")
            else
                return ply:Notify("Could not find player: "..tostring(name))
            end
        end
    }

    impulse.RegisterChatCommand("/warn", warnCommand)
end