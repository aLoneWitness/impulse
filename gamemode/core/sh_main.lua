/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

if SERVER then
	util.AddNetworkString( "IMPULSE-ColoredMessage" )
	util.AddNetworkString( "IMPULSE-SurfaceSound" )

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

function meta:IsDeveloper()
    return (self:SteamID() == "STEAM_0:1:95921723")
end

function meta:IsDonator()
    return self:IsUserGroup("vip")
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

function meta:Notify(...)
    if CLIENT then
        local notice = vgui.Create("impulseNotify")
        local i = table.insert(impulse.notices, notice)
        local package = {...}

        notice:SetMessage(unpack(package))
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
        local package = {...}
        netstream.Start(self, "impulseNotify", package)
    end
end