local PANEL = {}

function PANEL:Init()
	self:SetDrawBackground(false)
end

function PANEL:SetText(text, draw)
	local panel = markup.Parse(text, self:GetWide())
	panel.OnDrawText = draw

	self:SetTall(object:GetHeight())
	self.Paint = function(self, w, h)
		panel:Draw(0, 0)
	end
end

vgui.Register("impulseSmartText", PANEL, "DPanel")