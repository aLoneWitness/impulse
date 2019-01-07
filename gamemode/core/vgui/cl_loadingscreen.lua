local PANEL = {}

function PANEL:Init()
	self:SetPos(1,1)
	self:SetSize(ScrW(), ScrH())
	--self:SetBackgroundBlur(true)


	self.loadSize = #impulse.GetLoadCache() or 0
	self.loadComplete = 0
	for _, k in pairs(impulse.GetLoadCache()) do
		impulse.TriggerLoad(k)
		self.loadComplete = self.loadComplete + 1
	end
	impulse.loaded = false
end


local gradient = Material("vgui/gradient-d")
local singleDot = "."
local multiDot = "."

function PANEL:Paint(w,h)
	local time = CurTime()

	if time > (lastTime or 0) + 1 then
		if multiDot:len() == 3 then 
			multiDot = "." 
		else
			multiDot = multiDot .. singleDot
		end

		lastTime = time
	end

	Derma_DrawBackgroundBlur(self)
	impulse.render.glowgo(100,50,337,91)

	draw.SimpleText("Loading"..multiDot, "Impulse-Elements32", 100, 150, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("("..self.loadComplete.."/"..self.loadSize..")", "Impulse-Elements18-Shadow", 100, 180, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseLoadingScreen", PANEL, "DPanel")