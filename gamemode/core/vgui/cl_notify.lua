local PANEL = {}

local baseSizeW, baseSizeH = 300, 20

function PANEL:Init()
	self.message = markup.Parse("")
	self:SetPos(ScrW()-baseSizeW-10, ScrH()-baseSizeH-80)
	self:SetSize(baseSizeW, baseSizeH)
	self.startTime = CurTime()
	self.endTime = CurTime() + 5
end

function PANEL:SetMessage(...)
	-- Encode message into markup
	local msg = "<font=Impulse-Elements18>"

	for k, v in ipairs({...}) do
		if type(v) == "table" then
			msg = msg.."<color="..v.r..","..v.g..","..v.b..">"
		else
			msg = msg..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end
	msg = msg.."</font>"

	-- parse
	self.message = markup.Parse(msg, baseSizeW-20)


	-- set frame position and height to suit the markup
	local shiftHeight = self.message:GetHeight()
	self:SetHeight(shiftHeight+baseSizeH)
	local pos = self:GetPos()
	self:SetPos(pos, ScrH()-baseSizeH-shiftHeight-10)
end

local gradient = Material("vgui/gradient-r")
local darkCol = Color(30, 30, 30, 190)
local lightCol = Color(20,20,20,80)
local hudBlackGrad = Color(40,40,40,120)
local lifetime = 10

function PANEL:Paint(w,h)
	-- draw frame
	impulse.blur(self, 10, 20, 255)
	surface.SetDrawColor(darkCol)
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(darkCol)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,0,w,h)

	-- draw message
	self.message:Draw(10,10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	-- draw timebar
	local w2 = math.TimeFraction(self.startTime, self.endTime, CurTime()) * w
	surface.SetDrawColor(Color(255,255,255))
	surface.DrawRect(w2, h-2, w - w2, 2)
end

vgui.Register("impulseNotify", PANEL, "DPanel")