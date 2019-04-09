/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

function IMPULSE:ForceDermaSkin()
	return "impulse"
end

local blur = Material("pp/blurscreen")

local superTesters = {
	"STEAM_0:1:19935486" -- engima
}

local mappers = {
	"STEAM_0:0:24607430" -- stranger
}

impulse.Badges = {
	staff = {Material("icon16/shield.png"), "This player is a staff member.", function(ply) return ply:IsAdmin() end},
	donator = {Material("icon16/coins.png"), "This player is a donator.", function(ply) return ply:IsDonator() end},
	dev = {Material("icon16/cog.png"), "This player is a impulse developer.", function(ply) return ply:IsDeveloper() end},
	vin = {Material("impulse/vin.png"), "This player is the creator of impulse.", function(ply) return (ply:SteamID() == "STEAM_0:1:95921723") end},
	supertester = {Material("icon16/bug.png"), "This player made large contributions to the testing of impulse.", function(ply) return (superTesters[ply:SteamID()] or false) end},
	competition = {Material("icon16/rosette.png"), "This player has won a competition.", function(ply) return false end},
	mapper = {Material("icon16/map.png"), "This player is a mapper that has collaborated with impulse.", function(ply) return mappers[ply:SteamID()] end}
}

function impulse.blur(panel, layers, density, alpha)
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
end

local myscrw, myscrh = 1920, 1080

function SizeW(width)
    local screenwidth = myscrw
    return width*ScrW()/screenwidth
end

function SizeH(height)
    local screenheight = myscrh
    return height*ScrH()/screenheight
end

function SizeWH(width, height)
    local screenwidth = myscrw
    local screenheight = myscrh
    return width*ScrW()/screenwidth, height*ScrH()/screenheight
end