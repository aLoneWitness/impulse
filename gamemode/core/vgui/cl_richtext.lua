local PANEL = {}

function PANEL:Init()
	local bar = self:GetVBar()

	self.barPaint = bar.Paint
	self.btnUpPaint = bar.btnUp.Paint
	self.btnDownPaint = bar.btnDown.Paint
	self.btnGripPaint = bar.btnGrip.Paint
end

function PANEL:SetTextRaw(text, draw)
	local panel = markup.Parse(text, self:GetWide())
	panel.OnDrawText = draw

	self:SetTall(object:GetHeight())
	self.Paint = function(self, w, h)
		panel:Draw(0, 0)
	end
end

local function OnDrawText(text, font, x, y, color, alignX, alignY, alpha)
	alpha = alpha or 255

	surface.SetTextPos(x+1, y+1)
	surface.SetTextColor(0, 0, 0, alpha)
	surface.SetFont(font)
	surface.DrawText(text)

	surface.SetTextPos(x, y)
	surface.SetTextColor(color.r, color.g, color.b, alpha)
	surface.SetFont(font)
	surface.DrawText(text)
end

function PANEL:SetScrollBarVisible(visible)
	local bar = self:GetVBar()

	if visible == true then
		bar.btnUp.Paint = self.btnUpPaint
		bar.btnDown.Paint = self.btnDownPaint
		bar.btnGrip.Paint = self.btnGripPaint
		bar.Paint = self.barPaint
	else
		bar.btnUp.Paint = function() end
		bar.btnDown.Paint = function() end
		bar.btnGrip.Paint = function() end
		bar.Paint = function() end
	end
end

function PANEL:ScrollToChild(panel)
	self:PerformLayout()

	local x, y = self.pnlCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()

	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

function PANEL:AddText(...)
	local text = "<font=".."Impulse-Chat"..impulse.GetSetting("chat_fontsize")..">"
	local plainText = ""
	local luaMsg = {}

	if impulse.customChatFont then
		text = "<font="..impulse.customChatFont..">"
		impulse.customChatFont = nil
	end
	
	for k, v in ipairs({...}) do
		if (type(v) == "table" and v.r and v.g and v.b) then
			text = text.."<color="..v.r..","..v.g..","..v.b..">"

			table.insert(luaMsg, Color(v.r, v.g, v.b, 255))
		elseif (type(v) == "Player") then
			local color = team.GetColor(v:Team())
			local str = v:KnownName():gsub("<", "&lt;"):gsub(">", "&gt;")

			text = text.."<color="..color.r..","..color.g..","..color.b..">"..str
			painText = plainText..v:Name()
			
			table.insert(luaMsg, color)
			table.insert(luaMsg, str)
		else
			local str = tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
			text = text..str
			plainText = plainText..str

			table.insert(luaMsg, str)
		end
	end

	text = text.."</font>"

	local textElement = self:Add("DPanel")
	textElement:SetWide(self:GetWide() - 15)
	textElement:SetDrawBackground(false)
	textElement:SetMouseInputEnabled(true)
	textElement.plainText = plainText

	local mrkup = markup.Parse(text, self:GetWide() - 15)
	mrkup.OnDrawText = drawText

	textElement:SetTall(mrkup:GetHeight())
	textElement.Paint = function(self, w, h)
		mrkup:Draw(0, 0)
	end

	textElement.start = CurTime() + impulse.GetSetting("chat_fadetime")
	textElement.finish = textElement.start + 10
	textElement.Think = function(this)
		if self.active then
			this:SetAlpha(255)
		else
			this:SetAlpha((1 - math.TimeFraction(this.start, this.finish, CurTime())) * 255)
		end
	end

	textElement.OnMousePressed = function()
		local subMenu = DermaMenu()

		subMenu.Think = function()
			subMenu:MoveToFront()
		end

		local copyText = subMenu:AddOption("Copy text to clipboard", function()
			SetClipboardText(textElement.plainText)
			chat.AddText(color_white, "Text copied to clipboard.")
		end)
		copyText:SetIcon("icon16/page_copy.png")

		subMenu:Open()
		subMenu:SetPos(gui.MouseX(), gui.MouseY())
	end

	textElement:Dock(TOP)
	textElement:InvalidateParent(true)

	if not self.BlockScroll then
		self:ScrollToChild(textElement)
	else
		self.BlockScroll = false
	end

	self.lastChildMessage = textElement

	MsgC(unpack(luaMsg))
	MsgN("")
end

vgui.Register("impulseRichText", PANEL, "DScrollPanel")