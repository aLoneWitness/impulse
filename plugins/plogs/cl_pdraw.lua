plogs.draw = {} -- Plop it in the plogs table otherwise this creates conflicts

local surface 	= surface
local render 	= render

local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local function surface_DrawRectBold(x, y, w, h, t)
	if not t then t = 1 end
	surface_DrawRect(x, y, w, t)
	surface_DrawRect(x, y + (h - t), w, t)
	surface_DrawRect(x, y, t, h)
	surface_DrawRect(x + (w - t), y, t, h)
end

function plogs.draw.Box(x, y, w, h, col)
	surface_SetDrawColor(col)
	surface_DrawRect(x, y, w, h)
end

function plogs.draw.Outline(x, y, w, h, col, thickness)
	surface_SetDrawColor(col)
	surface_DrawRectBold(x, y, w, h, thickness)
end

function plogs.draw.OutlinedBox(x, y, w, h, col, bordercol, thickness)
	surface_SetDrawColor(col)
	surface_DrawRect(x + 1, y + 1, w - 2, h - 2)

	surface_SetDrawColor(bordercol)
	surface_DrawRectBold(x, y, w, h, thickness)
end

local blur = Material('pp/blurscreen')
function plogs.draw.Blur(panel, amount) -- Thanks nutscript
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat('$blur', (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end