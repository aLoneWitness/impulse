/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.hudEnabled = impulse.hudEnabled or true

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true
hidden["CHudDamageIndicator"] = true

function IMPULSE:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

local blur = Material("pp/blurscreen")
local function BlurRect(x, y, w, h)
	local X, Y = 0,0

	surface.SetDrawColor(255,255,255, 255)
	surface.SetMaterial(blur)

	for i = 1, 2 do
		blur:SetFloat("$blur", (i / 10) * 20)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x+w, y+h, true)
		surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
   
   --draw.RoundedBox(0,x,y,w,h,Color(0,0,0,205))
   surface.SetDrawColor(0,0,0)
   --surface.DrawOutlinedRect(x,y,w,h)
   
end



local vignette = Material("impulse/vignette.png")
local vig_alpha_normal = Color(10,10,10,180)
local lasthealth = 100
local time = 0
local gradient = Material("vgui/gradient-l")
local watermark = Material("impulse/impulse-logo-white.png")
local watermarkCol = Color(255,255,255,90)
local fde = 0
local hudBlackGrad = Color(40,40,40,180)
local hudBlack = Color(20,20,20,140)
local darkCol = Color(30, 30, 30, 190)

function IMPULSE:HUDPaint()
	if impulse.hudEnabled == false or IsValid(impulse.MainMenu) then return end

	local health = LocalPlayer():Health()
	local lp = LocalPlayer()
	local scrW, scrH = ScrW(), ScrH()
	local hudWidth, hudHeight = 300, 178

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

	-- Draw any HUD stuff under this comment

	if health < lasthealth then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255,10,10,80), 1, 0)
	end

	local y = scrH-hudHeight-8-10
	BlurRect(10, y, hudWidth, hudHeight)
	surface.SetDrawColor(darkCol)
	surface.DrawRect(10, y, hudWidth, hudHeight)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(10, y, hudWidth, hudHeight)

	surface.SetFont("Impulse-Elements23")
	surface.SetTextColor(color_white)
	surface.SetTextPos(15, y+5)
	surface.DrawText(LocalPlayer():Name())

	surface.SetFont("Impulse-Elements18")
	surface.SetTextPos(hudWidth/2, y+50)
	surface.DrawText("Health: "..LocalPlayer():Health())

	surface.SetTextPos(hudWidth/2, y+70)
	surface.DrawText("Armour: "..LocalPlayer():Armor())

	surface.SetTextPos(hudWidth/2, y+90)
	surface.DrawText("Tokens: "..LocalPlayer():GetSyncVar(SYNC_MONEY, 0))

	-- watermark
	surface.SetDrawColor(watermarkCol)
	surface.SetMaterial(watermark)
	surface.DrawTexturedRect(10, 10, 112, 30)

	surface.SetTextPos(10, 40)
	surface.DrawText("TEST BUILD - "..IMPULSE.Version.." - "..LocalPlayer():SteamID64().. " - ".. os.date("%H:%M:%S - %d/%m/%Y", os.time()))

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
	if impulse.hudEnabled == false or IsValid(impulse.MainMenu) then return end

	if LocalPlayer():Health() < 20 then
		DrawColorModify(blackandwhite)
	end
end


concommand.Add("impulse_cameratoggle", function()
	impulse.hudEnabled = (!impulse.hudEnabled)
end)