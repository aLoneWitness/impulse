local PANEL = {}

local gradient = Material("vgui/gradient-l")
local outlineCol = Color(190,190,190,240)
local darkCol = Color(30,30,30,200)

function PANEL:Paint(w,h)
	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.SetMaterial(gradient)
	surface.SetDrawColor(outlineCol)
	surface.DrawTexturedRect(1, 1, w - 1, h - 1)
end

function PANEL:OnMousePressed()

end

vgui.Register("impulseInventoryCard", PANEL, "DPanel")