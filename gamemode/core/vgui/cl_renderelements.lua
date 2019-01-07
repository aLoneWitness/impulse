impulse.render = impulse.render or {}

local impulseLogo = Material("impulse/impulse-logo-white.png")
local fromCol = Color(255, 45, 85, 255)
local toCol = Color(90, 200, 250, 255)

local function Glow(c, t, m)
    return Color(c.r + ((t.r - c.r) * (m)), c.g + ((t.g - c.g) * (m)), c.b + ((t.b - c.b) * (m)))
end

function impulse.render.glowgo(x,y,w,h)
	local col = Glow(fromCol, toCol, math.abs(math.sin((RealTime() - 0.08) * .2)))

	surface.SetMaterial(impulseLogo)
	surface.SetDrawColor(col)
	surface.DrawTexturedRect(x,y,w,h)
end