if SERVER then
	util.AddNetworkString( "IMPULSE-ColoredMessage" )
	util.AddNetworkString( "IMPULSE-SurfaceSound" )
    util.AddNetworkString("impulseNotify")

	function meta:AddChatText(...)
		local package = {...}
		netstream.Start(self, "IMPULSE-ColoredMessage", package)
	end

	function meta:SurfacePlaySound(sound)
	    net.Start("IMPULSE-SurfaceSound")
	    net.WriteString(sound)
	    net.Send(self)
	end

    function impulse.CinematicIntro(message)
        net.Start("impulseCinematicMessage")
        net.WriteString(message)
        net.Broadcast()
    end

    concommand.Add("impulse_cinemessage", function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        
        impulse.CinematicIntro(args[1] or "")
    end)

    function meta:AllowScenePVSControl(bool)
        self.allowPVS = bool

        if not bool then
            self.extraPVS = nil
            self.extraPVS2 = nil
        end
    end
else
	netstream.Hook("IMPULSE-ColoredMessage",function(msg)
		chat.AddText(unpack(msg))
	end)

	net.Receive("IMPULSE-SurfaceSound",function()
        surface.PlaySound(net.ReadString())
    end)
end

local eMeta = FindMetaTable("Entity")

function meta:IsDeveloper()
    return self:SteamID() == "STEAM_0:1:95921723"
end

function meta:IsDonator()
    return (self:IsUserGroup("donator") or self:IsAdmin())
end


local adminGroups = {
    ["admin"] = true,
    ["leadadmin"] = true
}

function meta:IsAdmin()
    if self.IsSuperAdmin(self) then
        return true
    end
    
    if adminGroups[self.GetUserGroup(self)] then
        return true
    end

    return false
end

function meta:InSpawn()
    return self:GetPos():WithinAABox(impulse.Config.SpawnPos1, impulse.Config.SpawnPos2)
end

function impulse.AngleToBearing(ang)
    return math.Round(360 - (ang.y % 360))
end

impulse.notices = impulse.notices or {}

local function OrganizeNotices(i)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100

    for k, v in ipairs(impulse.notices) do
        local height = lastHeight - v:GetTall() - 10
        v:MoveTo(scrW - (v:GetWide()), height, 0.15, (k / #impulse.notices) * 0.25, nil)
        lastHeight = height
    end
end

function meta:Notify(message)
    if CLIENT then
        if not impulse.hudEnabled then
            return MsgN(message)
        end

        local notice = vgui.Create("impulseNotify")
        local i = table.insert(impulse.notices, notice)

        notice:SetMessage(message)
        notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4) -- needs to be recoded to support variable heights
        notice:MoveToFront() 
        OrganizeNotices(i)

        timer.Simple(7.5, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function() 
                    notice:Remove()

                    for v,k in pairs(impulse.notices) do
                        if k == notice then
                            table.remove(impulse.notices, v)
                        end
                    end

                    OrganizeNotices(i)
                end)
            end
        end)

        MsgN(message)
    else
        net.Start("impulseNotify")
        net.WriteString(message)
        net.Send(self)
    end
end

local modelCache = {}
function eMeta:IsFemale(modelov)
    local model = modelov or self:GetModel()

    if modelCache[model] then
        return modelCache[model]
    end

    local isFemale = string.find(self:GetModel(), "female")

    if isFemale then
        modelCache[model] = true
        return true
    end

    modelCache[model] = false
    return false
end

function meta:IsCharacterFemale()
    if SERVER then
        return self:IsFemale(self.defaultModel)
    else
        return self:IsFemale(impulse_defaultModel)
    end
end

function impulse.FindPlayer(searchKey)
    if not searchKey or searchKey == "" then return nil end
    local searchPlayers = player.GetAll()
    local lowerKey = string.lower(tostring(searchKey))

    for k = 1, #searchPlayers do
        local v = searchPlayers[k]

        if searchKey == v:SteamID() then
            return v
        end

        if string.find(string.lower(v:Name()), lowerKey, 1, true) ~= nil then
            return v
        end

        if string.find(string.lower(v:SteamName()), lowerKey, 1, true) ~= nil then
            return v
        end
    end
    return nil
end

function impulse.SafeString(str)
    local pattern = "[^0-9a-zA-Z%s]+"
    local clean = tostring(str)
    local first, last = string.find(str, pattern)

    if first != nil and last != nil then
        clean = string.gsub(clean, pattern, "") -- remove bad sequences
    end

    return clean
end

local idleVO = {
    "question23.wav",
    "question25.wav",
    "question09.wav",
    "question06.wav",
    "question05.wav"
}

local idleCPVO = {
    "copy.wav",
    "needanyhelpwiththisone.wav",
    "unitis10-8standingby.wav",
    "affirmative.wav",
    "affirmative2.wav",
    "rodgerthat.wav",
    "checkformiscount.wav"
}

local idleFishVO = {
    "fish_cough01.wav",
    "fish_cough02.wav",
    "fish_crabpot01.wav",
    "fish_likeleeches.wav",
    "fish_myback.wav",
    "fish_oldleg.wav",
    "fish_resumetalk02.wav",
    "fish_stayoutwater.wav",
    "fish_wipeouttown01.wav"
}

function impulse.GetRandomAmbientVO(gender)
    if gender == "male" then
        return "vo/npc/male01/"..idleVO[math.random(1, #idleVO)]
    elseif gender == "fisherman" then
        return "lostcoast/vo/fisherman/"..idleFishVO[math.random(1, #idleFishVO)]
    elseif gender == "cp" then
        return "npc/metropolice/vo/"..idleCPVO[math.random(1, #idleCPVO)]
    else
        return "vo/npc/female01/"..idleVO[math.random(1, #idleVO)]
    end
end