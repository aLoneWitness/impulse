/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

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
else
	netstream.Hook("IMPULSE-ColoredMessage",function(msg)
		chat.AddText(unpack(msg))
	end)

	net.Receive("IMPULSE-SurfaceSound",function()
        surface.PlaySound(net.ReadString())
    end)
end

meta.SteamName = meta.SteamName or meta.Name
function meta:Name()
    return self:GetSyncVar(SYNC_RPNAME, self:SteamName())
end
meta.GetName = meta.Name
meta.Nick = meta.Name

function meta:IsDeveloper()
    return (self:SteamID() == "STEAM_0:1:95921723" or self:SteamID() == "STEAM_0:1:102639297")
end

function meta:IsDonator()
    return (self:IsUserGroup("vip") or self:IsAdmin())
end 

function meta:InSpawn()
    return self:GetPos():WithinAABox(impulse.Config.SpawnPos1, impulse.Config.SpawnPos2)
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
    else
        net.Start("impulseNotify")
        net.WriteString(message)
        net.Send(self)
    end
end

function meta:IsFemale()
    return string.find(self:GetModel(), "female")
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