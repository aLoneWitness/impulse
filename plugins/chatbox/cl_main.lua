-- This code was not made by me, it was taken from https://github.com/Chessnut/NutScript/blob/1.1/

local PANEL = {}
	local gradient = Material("vgui/gradient-d")
	local gradient2 = Material("vgui/gradient-u")

	local COLOR_FADED = Color(200, 200, 200, 100)
	local COLOR_ACTIVE = color_white
	local COLOR_WRONG = Color(255, 100, 80)
	--local CHAT_FONT = impulse.GetSetting("ChatFontSize") or "Impulse-ChatSmall"
	local CHAT_FONT = "Impulse-ChatSmall"

	function PANEL:Init()
		local border = 32
		local scrW, scrH = ScrW(), ScrH()
		local w, h = scrW * 0.4, scrH * 0.375

		--impulse.chatbox = self

		self:SetSize(w, h)
		self:SetPos(border, scrH - h - border)

		self.active = false

		self.tabs = self:Add("DPanel")
		self.tabs:Dock(TOP)
		self.tabs:SetTall(24)
		self.tabs:DockPadding(3, 3, 3, 3)
		self.tabs:DockMargin(4, 4, 4, 4)
		self.tabs:SetVisible(false)

		self.arguments = {}

		self.scroll = self:Add("DScrollPanel")
		self.scroll:SetPos(4, 30)
		self.scroll:SetSize(w - 8, h - 70)
		self.scroll:GetVBar():SetWide(0)
		self.scroll.PaintOver = function(this, w, h)
			local entry = self.text

			if (self.active and IsValid(entry)) then
				local text = entry:GetText()

				if (text:sub(1, 1) == "/") then
					local arguments = self.arguments or {}
					local command = string.PatternSafe(arguments[1] or ""):lower()

					impulse.blur( this, 10, 20, 255 )

					surface.SetDrawColor(0, 0, 0, 200)
					surface.DrawRect(0, 0, w, h)

					local i = 0
					local color = Color(255,255,255,255)

 					for k, v in pairs(impulse.chatcommands) do
 						local k2 = "/"..v[1]

 						if (k2:match(command)) then
							draw.DrawText(v[1], "Impulse-ChatSmall", w,h, color, TEXT_ALIGN_LEFT)
 						end
 					end
				end
			end
		end

		self.lastY = 0

		self.list = {}
		self.filtered = {}

		chat.GetChatBoxPos = function()
			return self:LocalToScreen(0, 0)
		end

		chat.GetChatBoxSize = function()
			return self:GetSize()
		end
	end

	function PANEL:Paint(w, h)
		if (self.active) then
			impulse.blur( self, 10, 20, 255 )

			surface.SetDrawColor(250, 250, 250, 2)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 0, 240)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	local TEXT_COLOR = Color(255, 255, 255, 200)

	function PANEL:setActive(state)
		self.active = state

		if (state) then
			self.entry = self:Add("EditablePanel")
			self.entry:SetPos(self.x + 4, self.y + self:GetTall() - 32)
			self.entry:SetWide(self:GetWide() - 8)
			self.entry.Paint = function(this, w, h)
			end
			self.entry.OnRemove = function()
				hook.Run("FinishChat")
			end
			self.entry:SetTall(28)

			local chathistory = chathistory or {}

			self.text = self.entry:Add("DTextEntry")
			self.text:Dock(FILL)
			self.text.History = chathistory
			self.text:SetHistoryEnabled(true)
			self.text:DockMargin(3, 3, 3, 3)
			self.text:SetFont(CHAT_FONT)
			self.text.OnEnter = function(this)
				local text = this:GetText()

				this:Remove()

				self.tabs:SetVisible(false)
				self.active = false
				self.entry:Remove()

				if (text:find("%S")) then
					if (!(lastLine or ""):find(text, 1, true)) then
						chathistory[#chathistory + 1] = text
						local lastLine = text
					end

					netstream.Start("msg", text)
				end
			end
			self.text:SetAllowNonAsciiCharacters(true)
			self.text.Paint = function(this, w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawOutlinedRect(0, 0, w, h)

				this:DrawTextEntryText(TEXT_COLOR, Color(255,255,255,255), TEXT_COLOR)
			end
			self.text.OnTextChanged = function(this)
				local text = this:GetText()

				hook.Run("ChatTextChanged", text)

			end

			self.entry:MakePopup()
			self.text:RequestFocus()
			self.tabs:SetVisible(true)

			hook.Run("StartChat")
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
		--draw.SimpleTextOutlined(text, font, x, y, ColorAlpha(color, alpha), 0, alignY, 1, ColorAlpha(color_black, alpha * 0.6))
	end

	function PANEL:addText(...)
		local text = "<font="..CHAT_FONT..">"

		if (CHAT_CLASS) then
			text = "<font="..CHAT_FONT..">"
		end

		for k, v in ipairs({...}) do
			if (type(v) == "IMaterial") then
				local ttx = tostring(v):match("%[[a-z0-9/]+%]")
				ttx = ttx:sub(2, ttx:len() - 1)
				text = text.."<img="..ttx..","..v:Width().."x"..v:Height()..">"
			elseif (type(v) == "table" and v.r and v.g and v.b) then
				text = text.."<color="..v.r..","..v.g..","..v.b..">"
			elseif (type(v) == "Player") then
				local color = team.GetColor(v:Team())

				text = text.."<color="..color.r..","..color.g..","..color.b..">"..v:Name():gsub("<", "&lt;"):gsub(">", "&gt;")
			else
				text = text..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
			end
		end

		text = text.."</font>"
		print(text)

		local panel = self.scroll:Add("MarkupPanel")
		panel:SetWide(self:GetWide() - 8)
		panel:setMarkup(text, OnDrawText)
		panel.start = CurTime() + 15
		panel.finish = panel.start + 20
		panel.Think = function(this)
			if (self.active) then
				this:SetAlpha(255)
			else
				this:SetAlpha((1 - math.TimeFraction(this.start, this.finish, CurTime())) * 255)
			end
		end

		self.list[#self.list + 1] = panel

		panel:SetPos(0, self.lastY)
		self.lastY = self.lastY + panel:GetTall()
		self.scroll:ScrollToChild(panel)


		panel.filter = class

		return panel:IsVisible()
	end

	function PANEL:Think()
		if (gui.IsGameUIVisible() and self.active) then
			self.tabs:SetVisible(false)
			self.active = false

			if (IsValid(self.entry)) then
				self.entry:Remove()
			end
		end
	end
vgui.Register("ChatBox", PANEL, "DPanel")



local function createChat()
	if (IsValid(impulse.chatbox)) then
		return
	end
	impulse.chatbox = vgui.Create("ChatBox")
end

hook.Add("InitPostEntity","IMPULSE-CHATSTART", function()
	createChat()
end)

hook.Add("HUDShouldDraw", "IMPULSE-CHATNODRAW", function(element)
	if (element == "CHudChat") then
			return false
	end
end)

hook.Add("PlayerBindPress", "IMPULSE-CHAT-OPEN", function(client, bind, pressed)
	if not impulse.chatbox then return createChat() end

	bind = bind:lower()

	if (bind:find("messagemode") and pressed) then
		impulse.chatbox:setActive(true)

		return true
	end
end)


chat.impulseAddText = chat.impulseAddText or chat.AddText

function chat.AddText(...)
	local show = true
	if (IsValid(impulse.chatbox)) then
		show = impulse.chatbox:addText(...)
	end

	if (show) then
		chat.impulseAddText(...)
		chat.PlaySound()
	end
end

hook.Add("ChatText", "IMPULSE-CHATCORE", function(index, name, text, messageType)
	if (messageType == "none" and IsValid(impulse.chatbox)) then
		impulse.chatbox:addText(text)
		chat.PlaySound()
	end
end)

