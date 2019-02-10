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
local vig_alpha_normal = Color(10,10,10,190)
local lasthealth = 100
local time = 0
local gradient = Material("vgui/gradient-l")
local watermark = Material("impulse/impulse-logo-white.png")
local watermarkCol = Color(255,255,255,120)
local fde = 0
local hudBlackGrad = Color(40,40,40,180)
local hudBlack = Color(20,20,20,140)
local darkCol = Color(30, 30, 30, 190)

local healthIcon = Material("impulse/icons/heart-128.png")
local healthCol = Color(254, 0, 0, 255)
local armourIcon = Material("impulse/icons/shield-128.png")
local armourCol = Color(255, 255, 0, 255)
local hungerIcon = Material("impulse/icons/bread-128.png")
local hungerCol = Color(205, 133, 63, 255)
local moneyIcon = Material("impulse/icons/banknotes-128.png")
local moneyCol = Color(133, 187, 101, 255)
local timeIcon = Material("impulse/icons/clock-128.png")
local xpIcon = Material("impulse/icons/star-128.png")
local warningIcon = Material("impulse/icons/warning-128.png")
local infoIcon = Material("impulse/icons/info-128.png")
local announcementIcon = Material("impulse/icons/megaphone-128.png")

local lastModel = ""
local lastSkin = ""
local lastTeam = 99

local function DrawOverheadInfo(target, alpha)
	local pos = target:EyePos()

	pos.z = pos.z + 5
	pos = pos:ToScreen()
	pos.y = pos.y - 50

	draw.DrawText(target:Name(), "Impulse-Elements18-Shadow", pos.x, pos.y, ColorAlpha(team.GetColor(target:Team()), alpha), 1)
end

local function DrawDoorInfo(target)
	local pos = target:GetPos():ToScreen()
	local scrW = ScrW()
	local scrH = ScrH()
	local doorData = target:GetDoorData()
	local ownedBy = "Owner(s):"

	if doorData then
		if doorData.name then
			draw.DrawText(doorData.name, "Impulse-Elements18-Shadow", scrW * .5, scrH * .6, impulse.Config.MainColour, 1)
		elseif doorData.group then
			draw.DrawText(impulse.Config.DoorGroups[doorData.group], "Impulse-Elements18-Shadow", scrW * .5, scrH * .6, impulse.Config.MainColour, 1)
		elseif doorData.owners then
			for ownerID,v in pairs(doorData.owners) do
				local owner = Player(ownerID)

				if IsValid(owner) and owner:IsPlayer() then
					ownedBy = ownedBy.."\n"..owner:Name()
				end
			end
			draw.DrawText(ownedBy, "Impulse-Elements18-Shadow", scrW * .5, scrH * .6, impulse.Config.MainColour, 1)
		end
	end

	if LocalPlayer():CanBuyDoor(doorData) then
		draw.DrawText("Ownable door (LALT)", "Impulse-Elements18-Shadow", scrW * .5, scrH * .6, impulse.Config.MainColour, 1)
	end
end

function IMPULSE:HUDPaint()
	if impulse.hudEnabled == false or IsValid(impulse.MainMenu) then
		if IsValid(PlayerIcon) then
			PlayerIcon:Remove()
		end
		return
	end


	local health = LocalPlayer():Health()
	local lp = LocalPlayer()
	local lpTeam = lp:Team()
	local scrW, scrH = ScrW(), ScrH()
	local hudWidth, hudHeight = 300, 178
	local seeColIcons = impulse.GetSetting("hud_iconcolours")

	if not lp:Alive() then
		local ft = FrameTime()
		fde = math.Clamp(fde+ft*0.2, 0, 1)

		surface.SetDrawColor(0,0,0,math.ceil(fde*255))
		surface.DrawRect(-1, -1, ScrW()+2, ScrH()+2)

		draw.SimpleText("You have died", "Impulse-Elements23", ScrW()/2,ScrH()/2, Color(255,255,255,math.ceil(fde*255)),TEXT_ALIGN_CENTER)

		if IsValid(PlayerIcon) then
			PlayerIcon:Remove()
		end
		
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
	surface.SetDrawColor(color_white)
	surface.SetTextPos(30, y+10)
	surface.DrawText(LocalPlayer():Name())

	surface.SetTextColor(team.GetColor(lpTeam))
	surface.SetTextPos(30, y+30)
	surface.DrawText(team.GetName(lpTeam))

	surface.SetTextColor(color_white)
	surface.SetFont("Impulse-Elements19")

	surface.SetTextPos(136, y+53)
	surface.DrawText("Health: "..LocalPlayer():Health())
	if seeColIcons == true then surface.SetDrawColor(healthCol) end
	surface.SetMaterial(healthIcon)
	surface.DrawTexturedRect(110, y+55, 18, 16)

	surface.SetTextPos(136, y+75)
	surface.DrawText("Armour: "..LocalPlayer():Armor())
	if seeColIcons == true then surface.SetDrawColor(armourCol) end
	surface.SetMaterial(armourIcon)
	surface.DrawTexturedRect(110, y+75, 18, 18)

	surface.SetTextPos(136, y+95)
	surface.DrawText("Hunger: "..LocalPlayer():GetSyncVar(SYNC_HUNGER, 100))
	if seeColIcons == true then surface.SetDrawColor(hungerCol) end
	surface.SetMaterial(hungerIcon)
	surface.DrawTexturedRect(110, y+95, 18, 18)

	surface.SetTextPos(136, y+115)
	surface.DrawText("Money: "..impulse.Config.CurrencyPrefix..LocalPlayer():GetSyncVar(SYNC_MONEY, 0))
	if seeColIcons == true then surface.SetDrawColor(moneyCol) end
	surface.SetMaterial(moneyIcon)
	surface.DrawTexturedRect(110, y+115, 18, 18)

	surface.SetDrawColor(color_white)

	draw.DrawText("23:23", "Impulse-Elements19", hudWidth-27, y+150, color_white, TEXT_ALIGN_RIGHT)
	surface.SetMaterial(timeIcon)
	surface.DrawTexturedRect(hudWidth-20, y+150, 18, 18)

	draw.DrawText(lp:GetSyncVar(SYNC_XP, 0).."XP", "Impulse-Elements19", 55, y+150, color_white, TEXT_ALIGN_LEFT)
	surface.SetMaterial(xpIcon)
	surface.DrawTexturedRect(30, y+150, 18, 18)

	local weapon = LocalPlayer():GetActiveWeapon()
	if IsValid(weapon) then
		if weapon:Clip1() != -1 then
			surface.SetDrawColor(darkCol)
			surface.DrawRect(scrW-70, scrH-45, 70, 30)
			surface.SetTextPos(scrW-60, scrH-40)
			surface.DrawText(weapon:Clip1().."/"..LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType()))
		elseif weapon:GetClass() == "weapon_physgun" or weapon:GetClass() == "gmod_tool" then
			draw.DrawText("Make sure you dont have this weapon out in RP. You may be punished.", "Impulse-Elements16", 35, y-30, color_white, TEXT_ALIGN_LEFT)
			surface.SetMaterial(warningIcon)
			surface.DrawTexturedRect(10, y-30, 18, 18)
		end
	end

	if not IsValid(PlayerIcon) and impulse.hudEnabled == true then
		PlayerIcon = vgui.Create("SpawnIcon")
		PlayerIcon:SetPos(30, y+60)
		PlayerIcon:SetSize(64, 64)
		PlayerIcon:SetModel(LocalPlayer():GetModel())
	end

	if (lp:GetModel() != lastModel or lp:GetSkin() != lastSkin or lastTeam != lp:Team()) and IsValid(PlayerIcon) then
		PlayerIcon:SetModel(lp:GetModel(), lp:GetSkin())
		lastModel = lp:GetModel()
		lastSkin = lp:GetSkin()
		lastTeam = lp:Team()
	end

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 85
	trace.filter = lp

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) and traceEnt:IsDoor() then
		DrawDoorInfo(traceEnt)
	end

	-- watermark
	surface.SetDrawColor(watermarkCol)
	surface.SetMaterial(watermark)
	surface.DrawTexturedRect(10, 10, 112, 30)

	surface.SetTextPos(10, 40)
	surface.SetTextColor(watermarkCol)
	surface.SetFont("Impulse-Elements18-Shadow")
	surface.DrawText("TEST BUILD - "..IMPULSE.Version.." - "..LocalPlayer():SteamID64().. " - ".. os.date("%H:%M:%S - %d/%m/%Y", os.time()))

	lasthealth = health
end

local nextOverheadCheck = 0
local lastEnt
local trace = {}
local approach = math.Approach
overheadEntCache = {}
-- overhead info is HEAVILY based off nutscript. I'm not taking credit for it. but it saves clients like 70 fps so its worth it
function IMPULSE:HUDPaintBackground()

	if impulse.GetSetting("hud_vignette") == true then
		surface.SetMaterial(vignette)
		surface.SetDrawColor(vig_alpha_normal)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	if nextOverheadCheck < realTime then
		nextOverheadCheck = realTime + 0.5
		
		trace.start = lp.GetShootPos(lp)
		trace.endpos = trace.start + lp.GetAimVector(lp) * 300
		trace.filter = lp
		trace.mins = Vector(-4, -4, -4)
		trace.maxs = Vector(4, 4, 4)
		trace.mask = MASK_SHOT_HULL

		lastEnt = util.TraceHull(trace).Entity

		if IsValid(lastEnt) then
			overheadEntCache[lastEnt] = true
		end
	end

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then
			local goal = shouldDraw and 255 or 0
			local alpha = approach(entTarg.overheadAlpha or 0, goal, frameTime * 1000)

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha > 0 then
				if entTarg:IsPlayer() then
					DrawOverheadInfo(entTarg, alpha)
				end
			end

			entTarg.overheadAlpha = alpha

			if alpha == 0 and goal == 0 then
				overheadEntCache[entTarg] = nil
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
	--PrintTable(overheadEntCache)
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