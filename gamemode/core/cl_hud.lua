/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true

function IMPULSE:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

local vignette = Material("impulse/vignette.png")
local vig_alpha_normal = Color(10,10,10,180)
local lasthealth = 100
local time = 0
local gradient = Material("vgui/gradient-d")
local fde = 0

function IMPULSE:HUDPaint()
	local health = LocalPlayer():Health()
	local lp = LocalPlayer()

	if not lp:Alive() then
		local ft = FrameTime()
		fde = math.Clamp(fde+ft*0.2, 0, 1)

		surface.SetDrawColor(0,0,0,math.ceil(fde*255))
		surface.DrawRect(-1, -1, ScrW()+2, ScrH()+2)

		draw.SimpleText("You have died", "Impulse-Elements23", ScrW()/2,ScrH()/2, Color(255,255,255,math.ceil(fde*255)),TEXT_ALIGN_CENTER)
		return
	else
		fde = 0
	end

	if health < 45 then
		healthstate = Color(255,0,0,240)
	elseif health < 70 then
		healthstate = Color(255,0,0,190)
	else
		healthstate = nil
	end

	-- Health bar
	surface.SetDrawColor(healthstate or vig_alpha_normal)
	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	surface.SetDrawColor(30,30,30,155)
	surface.DrawRect(0, 0, SizeW(500), 20)
	surface.DrawOutlinedRect(0,0,SizeW(500), 20)

	surface.SetDrawColor(255,0,0,150)
	surface.DrawRect(1,1,SizeW(499)/100*health, 19)

	surface.SetDrawColor(200,200,200, 90)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,0,SizeW(500),20)

	-- Food bar

	surface.SetDrawColor(30,30,30,155)
	surface.DrawRect(0, 21, SizeW(500), 20)
	surface.DrawOutlinedRect(0,21,SizeW(500), 20)

	surface.SetDrawColor(0,255,0,150)
	surface.DrawRect(1,22,SizeW(499)/100*health, 19)

	surface.SetDrawColor(200,200,200, 90)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,21,SizeW(500),20)

	-- Stamina bar

	surface.SetDrawColor(30,30,30,155)
	surface.DrawRect(0, 40, SizeW(500), 20)
	surface.DrawOutlinedRect(0,20,SizeW(500), 20)

	surface.SetDrawColor(255,165,0)
	surface.DrawRect(1,41,SizeW(499)/100*health, 19)

	surface.SetDrawColor(200,200,200, 90)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,40,SizeW(500),20)

	-- Draw any HUD stuff under this comment


	if health < lasthealth then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255,255,255,120), 1, 0)
	end




	-- Don't edit anything under this comment
	lasthealth = health
end

local blackandwhite = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}


function IMPULSE:RenderScreenspaceEffects()
	if LocalPlayer():Health() < 20 then
		DrawColorModify(blackandwhite)
	end
end


