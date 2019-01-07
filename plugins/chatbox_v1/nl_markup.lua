-- This code was not made by me, it was taken from https://github.com/Chessnut/NutScript/blob/1.1/

local PANEL = {}
function PANEL:Init()
	self:SetDrawBackground(false)
	self:SetMouseInputEnabled(true)
end

function PANEL:setMarkup(text, onDrawText)
	local object = markup.parse(text, self:GetWide())
	object.onDrawText = onDrawText

	self:SetTall(object:getHeight())
	self.Paint = function(this, w, h)
		object:draw(0, 0)
	end
end

function PANEL:OnMouseReleased(mousecode)
	self:MouseCapture( false )

	if ( !self.Hovered ) then return end

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClick()
	end
end

function PANEL:DoClick()
end

function PANEL:DoRightClick()
end

vgui.Register("MarkupPanel", PANEL, "DPanel")
