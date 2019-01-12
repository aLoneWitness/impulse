local PANEL = {}

local baseSizeW, baseSizeH = 300, 20

function PANEL:Init()
	self.message = markup.Parse("")
	self:SetPos(ScrW()-baseSizeW-10, ScrH()-baseSizeH-80)
	self:SetSize(baseSizeW, baseSizeH)
end

function PANEL:SetMessage(msgData)
	self.message = markup.Parse("<font=Impulse-Elements18>"..msgData.."</font>", baseSizeW-20)
	local shiftHeight = self.message:GetHeight()
	self:SetHeight(shiftHeight+baseSizeH)
	local pos = self:GetPos()
	self:SetPos(pos, ScrH()-baseSizeH-shiftHeight-10)
end

local gradient = Material("vgui/gradient-r")
local darkCol = Color(30,30,30,180)
local hudBlackGrad = Color(40,40,40,120)
local lifetime = 10

function PANEL:Paint(w,h)
	surface.SetDrawColor(darkCol)
	surface.DrawRect(0,0,w,h)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,0,w,h)

	self.message:Draw(10,10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register("impulseNotify", PANEL, "DPanel")