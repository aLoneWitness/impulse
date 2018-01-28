
local PANEL = {}
	function PANEL:Init()
		self:SetDrawBackground(true)
	end

	function PANEL:SetMarkup(text, onDrawText)
		local object = markup.parse(text, self:GetWide())
		object.onDrawText = onDrawText

		self:SetTall(object:getHeight())
		self.Paint = function(this, w, h)
			object:draw(0, 0)
		end
	end
vgui.Register("NotificationPanel", PANEL, "DPanel")
