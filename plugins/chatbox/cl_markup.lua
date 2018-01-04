-- This code was not made by me, it was taken from https://github.com/Chessnut/NutScript/blob/1.1/

local PANEL = {}
	function PANEL:Init()
		self:SetDrawBackground(false)
	end

	function PANEL:setMarkup(text, onDrawText)
		local object = markup.parse(text, self:GetWide())
		object.onDrawText = onDrawText

		self:SetTall(object:GetHeight())
		self.Paint = function(this, w, h)
			object:Draw(0, 0)
		end
	end
vgui.Register("MarkupPanel", PANEL, "DPanel")
