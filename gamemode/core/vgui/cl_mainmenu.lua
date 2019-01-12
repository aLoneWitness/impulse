local PANEL = {}

function PANEL:Init()
	if IsValid(impulse.MainMenu) then
		impulse.MainMenu:Remove()
	end
	impulse.MainMenu = self
	impulse.hudEnabled = false

	self:SetPos(0,0)
	self:SetSize(ScrW(), ScrH())
	self:MakePopup()
	self:SetPopupStayAtBack(true)
	--self:SetBackgroundBlur(true)


--	self.loadSize = #impulse.GetLoadCache() or 0
--	self.loadComplete = 0
--	self.loading = false
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
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	local selfPanel = self
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:DoClick()
		if impulse_isNewPlayer == true then
			vgui.Create("impulseCharacterCreator", selfPanel)
		else
			selfPanel:Remove()
			impulse.hudEnabled = true
		end
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,250)
	button:SetFont("Impulse-Elements32")
	button:SetText("Settings")
	button:SizeToContents()
	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	function button:DoClick()
		vgui.Create("impulseSettings", selfPanel)
	end

	local button = vgui.Create("DButton", self)
	button:SetPos(100,280)
	button:SetFont("Impulse-Elements32")
	button:SetText("Community")
	button:SizeToContents()
	local normalCol = button:GetColor()
	local highlightCol = Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)
	function button:Paint()
		if self:IsHovered() then
			self:SetColor(highlightCol)
		else
			self:SetColor(color_white)
		end
	end

	local year = os.date("%Y", os.time())
	local copyrightLabel = vgui.Create("DLabel", self)
	copyrightLabel:SetFont("Impulse-Elements14")
	copyrightLabel:SetText("Powered by impulse\nCopyright vin "..year.."\nimpulse version: "..IMPULSE.Version)
	copyrightLabel:SizeToContents()
	copyrightLabel:SetPos(ScrW()-copyrightLabel:GetWide(), ScrH()-copyrightLabel:GetTall()-5)

	local schemaLabel = vgui.Create("DLabel", self)
	schemaLabel:SetFont("Impulse-Elements32")
	schemaLabel:SetText(impulse.Config.SchemaName)
	--schemaLabel:SetTextColor(Color(impulse.Config.MainColour.r, impulse.Config.MainColour.g, impulse.Config.MainColour.b)) not sure if i like this
	schemaLabel:SizeToContents()
	schemaLabel:SetPos(100,140)
end

function PANEL:OnChildAdded(child)
	if IsValid(self.openElement) then
		self.openElement:Remove()
	end
	self.openElement = child
end

function PANEL:IsLoading(isLoading)
	self.loading = isLoading
end

local gradient = Material("vgui/gradient-d")
local singleDot = "."
local multiDot = "."

function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur(self)

	surface.SetDrawColor(Color( 30, 30, 30, 190 )) -- menu body
	surface.DrawRect(70,0,400,h)
	impulse.render.glowgo(100,50,337,91)


--	if self.loading == false then return end
--
--	local time = CurTime()
--
--	if time > (lastTime or 0) + 1 then
--		if multiDot:len() == 3 then 
--			multiDot = "." 
--		else
--			multiDot = multiDot .. singleDot
--		end
--
--		lastTime = time
--	end
--
--	draw.SimpleText("Loading"..multiDot, "Impulse-Elements32", 100, 150, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
--	draw.SimpleText("("..self.loadComplete.."/"..self.loadSize..")", "Impulse-Elements18-Shadow", 100, 180, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseMainMenu", PANEL, "DPanel")