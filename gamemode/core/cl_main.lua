/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

function IMPULSE:ForceDermaSkin()
	return "impulse"
end

local blur = Material("pp/blurscreen")

local superTesters = {
	["STEAM_0:1:9592dsdsd"] = true 
}

local mappers = {
	["STEAM_0:0:24607430"] = true -- stranger
}


-- Please don't ever remove credit or users/badges from this section. People worked hard on this. Thanks!
impulse.Badges = {
	staff = {Material("icon16/shield.png"), "This player is a staff member.", function(ply) return ply:IsAdmin() end},
	donator = {Material("icon16/coins.png"), "This player is a donator.", function(ply) return ply:IsDonator() end},
	dev = {Material("icon16/cog.png"), "This player is a impulse developer.", function(ply) return ply:IsDeveloper() end},
	vin = {Material("impulse/vin.png"), "Hi, it's me vin! The creator of impulse.", function(ply) return (ply:SteamID() == "STEAM_0:1:95921723") end},
	supertester = {Material("icon16/bug.png"), "This player made large contributions to the testing of impulse.", function(ply) return (superTesters[ply:SteamID()] or false) end},
	competition = {Material("icon16/rosette.png"), "This player has won a competition.", function(ply) return false end},
	mapper = {Material("icon16/map.png"), "This player is a mapper that has collaborated with impulse.", function(ply) return mappers[ply:SteamID()] end}
}

local cheapBlur = Color(0, 0, 0, 205)
function impulse.blur(panel, layers, density, alpha)
	local x, y = panel:LocalToScreen(0, 0)

	if not impulse.GetSetting("perf_blur") then
		draw.RoundedBox(0, -x, -y, ScrW(), ScrH(), cheapBlur)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawOutlinedRect(-x, -y, ScrW(), ScrH())
	else
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(blur)

		for i = 1, 3 do
			blur:SetFloat("$blur", (i / layers) * density)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		end
	end
end

function impulse.MakeWorkbar(time, text, onDone, popup)
	local bar = vgui.Create("impulseWorkbar")
	bar:SetEndTime(CurTime() + time)

	if text then
		bar:SetText(text)
	end
	
	if onDone then
		bar.OnEnd = onDone
	end

	if popup then
		bar:MakePopup()
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