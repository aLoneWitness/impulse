local PANEL = {}

function PANEL:Init()
	self:SetPos(1,1)
	self:SetSize(ScrW(), ScrH())
	--self:SetBackgroundBlur(true)


	self.loadSize = #impulse.GetLoadCache() or 0
	self.loadComplete = 0
	self.loading = false
	--for _, k in pairs(impulse.GetLoadCache()) do
	--	impulse.TriggerLoad(k)
	--	self.loadComplete = self.loadComplete + 1
	--end
	--impulse.loaded = false

	local button = vgui.Create("DButton", self)
	button:SetPos(100,200)
	button:SetFont("Impulse-Elements48")
	button:SetText("Play")
	button:SizeToContents()
	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.maincolour.r, impulse.Config.maincolour.g, impulse.Config.maincolour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(normalCol)
		end
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,250)
	button:SetFont("Impulse-Elements32")
	button:SetText("Settings")
	button:SizeToContents()
	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.maincolour.r, impulse.Config.maincolour.g, impulse.Config.maincolour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(normalCol)
		end
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,280)
	button:SetFont("Impulse-Elements32")
	button:SetText("Community")
	button:SizeToContents()
	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.maincolour.r, impulse.Config.maincolour.g, impulse.Config.maincolour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(normalCol)
		end
	end
end

function PANEL:IsLoading(isLoading)
	self.loading = isLoading
end


local gradient = Material("vgui/gradient-d")
local singleDot = "."
local multiDot = "."

function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur(self)
	impulse.render.glowgo(100,50,337,91)

	if self.loading == false then return end

	local time = CurTime()

	if time > (lastTime or 0) + 1 then
		if multiDot:len() == 3 then 
			multiDot = "." 
		else
			multiDot = multiDot .. singleDot
		end

		lastTime = time
	end

	draw.SimpleText("Loading"..multiDot, "Impulse-Elements32", 100, 150, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("("..self.loadComplete.."/"..self.loadSize..")", "Impulse-Elements18-Shadow", 100, 180, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseMainMenu", PANEL, "DPanel")