local PANEL = {}

function PANEL:Init()
	self:SetSize(SizeW(600), 260)
	self:SetPos(ScrW()/2-(SizeW(600)/2),ScrH()/9)
	self:SetTitle("Character Menu")

	self.model = self:Add("DModelPanel") -- Resolution scaling may we weird here, needs testing.
	self.model:SetSize(200,260)
	self.model:SetPos(-50,0)
	self.model:SetModel(LocalPlayer():GetModel())
	self.model:SetFOV(19) -- Zoom in
	function self.model:LayoutEntity() return end
	self.model:SetCamPos(Vector(190,0,40))

	self.name = self:Add("DLabel")
	self.name:SetPos(SizeW(150), 50)
	self.name:SetText(LocalPlayer():Nick())
end


vgui.Register("impulsePlayerOptions", PANEL, "DFrame")
