local function Search(command)
	local w, h = ScrW() * .3, 120
	local posx, posy = ScrW()/2 - w/2, ScrH()/2 - h/2

	if IsValid(plogs.SearchMenu) then
		plogs.SearchMenu:Remove()
	end

	if IsValid(plogs.Menu) then
		local x, y = plogs.Menu:GetPos()
		posy = plogs.Menu:GetTall() + y + 10
	end

	local fr = vgui.Create('plogs_frame')
	fr:SetTitle('Search')
	fr:SetSize(w, h)
	fr:SetPos(posx, posy)
	plogs.SearchMenu = fr

	local lbl = vgui.Create('DLabel', fr)
	lbl:SetPos(5, 35)
	lbl:SetText('Enter a SteamID to search')
	lbl:SetFont('Impulse-Elements18')
	lbl:SizeToContents()

	local txt = vgui.Create('DTextEntry', fr)
	txt:SetPos(5, 60)
	txt:SetSize(w - 10, 25)
	txt:SetFont('Impulse-Elements18')

	local srch = vgui.Create('DButton', fr)
	srch:SetPos(5, 90)
	srch:SetSize(w - 10, 25)
	srch:SetText('Search')
	srch.DoClick = function(self)
		LocalPlayer():ConCommand('plogs "' .. command .. '" "' .. txt:GetValue() .. '"')
		fr:Close()
	end
end

local function LogMenu(title, data)
	if IsValid(plogs.Menu) then
		plogs.Menu:SetVisible(false)
	end
	if IsValid(plogs.LogMenu) then
		plogs.LogMenu:Remove()
	end
	
	local w, h = plogs.cfg.Width * ScrW(), plogs.cfg.Height * ScrH()

	local fr = vgui.Create('plogs_frame')
	fr:SetTitle('Search')
	fr:SetSize(w, h)
	fr:SetTitle(title)
	fr:Center()
	fr._Close = fr.Close
	fr.Close = function(self)
		if IsValid(plogs.Menu) then
			plogs.Menu:SetVisible(true)
		end
		fr:_Close()
	end
	plogs.LogMenu = fr

	local logList = vgui.Create('DListView', fr)
	logList:SetPos(0, 29)
	logList:SetSize(fr:GetWide(), fr:GetTall() - 29)
	logList:SetMultiSelect(false)
	logList:AddColumn('Date'):SetFixedWidth(175)
	logList:AddColumn('Data')
	logList.OnRowSelected = function(parent, line)
		local column 	= logList:GetLine(line)
		local log 		= column:GetColumnText(2)
		local menu 		= DermaMenu()

		menu:SetSkin('impulse')
		menu:AddOption('Copy Line', function() 
			SetClipboardText(log)
			LocalPlayer():ChatPrint('Copied Line')
		end)
		menu:Open()
	end

	for k, v in ipairs(data) do
		logList:AddLine(isstring(v.Date) and v.Date or os.date('%X - %d/%m/%Y', v.Date), v.Data)
	end
end

local c = 1
local saveList
local function OpenMenu()
	local w, h = plogs.cfg.Width * ScrW(), plogs.cfg.Height * ScrH()
	c = 1

	local fr = plogs.Menu

	if IsValid(fr) then
		fr:Remove()
	end

	local count = table.Count(plogs.data)
	local fr = vgui.Create('plogs_frame')
	fr:SetSize(w, h)
	fr:Center()
	fr._Close = fr.Close
	fr.Close = function(self)
		if IsValid(plogs.SearchMenu) then
			plogs.SearchMenu:Close()
		end
		fr:_Close()
	end
	fr.PaintOver = function(self, w, h)
		if (c < count) then
			plogs.draw.Box(0, 0, w * c/count , 4, impulse.Config.MainColour)
		end
	end
	plogs.Menu = fr

	local tabs = vgui.Create('plogs_tablist', fr)
	tabs:SetPos(0, 29)
	tabs:SetSize(w, h - 29)
	plogs.Menu.Tabs = tabs
	
	local pnl =	vgui.Create('DPanel', tabs)
	tabs:AddTab('Saves', pnl, true)

	local logList = vgui.Create('DListView', pnl)
	logList:SetPos(0, 0)
	logList:SetSize(pnl:GetWide(), pnl:GetTall() - 150)
	logList:SetMultiSelect(false)
	logList:AddColumn('Time'):SetFixedWidth(75)
	logList:AddColumn('Data')
	logList.OnRowSelected = function(parent, line)
		local column 	= logList:GetLine(line)
		local log 		= column:GetColumnText(2)
		local menu 		= DermaMenu()

		menu:SetSkin('impulse')
		menu:AddOption('Copy Line', function() 
			SetClipboardText(log)
			LocalPlayer():ChatPrint('Copied Line')
		end)
		for name, value in SortedPairs(column.Copy or {}) do
			menu:AddOption('Copy ' .. name, function() 
				SetClipboardText(value or 'ERROR')
				LocalPlayer():ChatPrint('Copied ' .. name)
			end)
		end
		menu:Open()
	end
	logList.AddLogs = function(self, name)
		for k, v in pairs(self:GetLines()) do
			self:RemoveLine(k)
		end
		for _, log in SortedPairs(plogs.OpenSave(name)) do
			local line 	= self:AddLine(log.Date, log.Data)
			line.Copy 	= log.Copy
		end
	end

	local save
	saveList = vgui.Create('DListView', pnl)
	saveList:SetPos(5, pnl:GetTall() - 145)
	saveList:SetSize(pnl:GetWide()/2 - 7.5, 140)
	saveList:SetMultiSelect(false)
	saveList:AddColumn('Saves')
	saveList.OnRowSelected = function(parent, line)
		save = saveList:GetLine(line):GetColumnText(1)
	end
	saveList.AddSaves = function(self)
		for k, v in pairs(self:GetLines()) do
			self:RemoveLine(k)
		end
		for k, v in ipairs(plogs.GetSaves()) do
			self:AddLine(v)
			if (k == 1) then save = v end
		end
	end
	saveList:AddSaves()

	local btn = vgui.Create('DButton', pnl)
	btn:SetPos(pnl:GetWide()/2 + 2.25, pnl:GetTall() - 145)
	btn:SetSize(pnl:GetWide()/2 - 7.5, 25)
	btn:SetText('Open')
	btn.DoClick = function()
		logList:AddLogs(save)
	end

	btn = vgui.Create('DButton', pnl)
	btn:SetPos(pnl:GetWide()/2 + 2.25, pnl:GetTall() - 115)
	btn:SetSize(pnl:GetWide()/2 - 7.5, 25)
	btn:SetText('Delete')
	btn.DoClick = function()
		plogs.DeleteSave(save)
		saveList:AddSaves()
	end

	if plogs.cfg.EnableMySQL then
		tabs:AddButton('Player Events', function()
			Search('playerevents')
		end)

		if plogs.cfg.IPUserGroups[string.lower(LocalPlayer():GetUserGroup())] then
			tabs:AddButton('IP logs', function()
				Search('ipsearch')
			end)
		end
	end
end

net.Receive('plogs.OpenMenu', function()
	if (not IsValid(plogs.Menu)) then OpenMenu() end

	local name = net.ReadString()
	local size = net.ReadUInt(16)
	local data = plogs.Decode(net.ReadData(size))

	PrintTable(data)

	plogs.data[name] = data

	local tabs = plogs.Menu.Tabs
	local pnl =	vgui.Create('DPanel', tabs)
	tabs:AddTab(name, pnl)

	local lbl = Label('Search:', pnl)
	lbl:SetFont('Impulse-Elements18')
	lbl:SetPos(5, pnl:GetTall() - 28)
	lbl:SetColor(Color(0, 0, 0))
	
	local txt = vgui.Create('DTextEntry', pnl)
	txt:SetPos(75, pnl:GetTall() - 30)
	txt:SetSize(pnl:GetWide() - 145, 25)
	txt:SetFont('Impulse-Elements18')

	local save = vgui.Create('DButton', pnl)
	save:SetPos(pnl:GetWide() - 65, pnl:GetTall() - 30)
	save:SetSize(60, 25)
	save:SetText('Save')
	save.DoClick = function()
		Derma_StringRequest('Save Log', 'What do you want to name this save?', '', function(name)
			if (#pnl.Data == 0) then
				LocalPlayer():ChatPrint('There are no results to save!')
			else
				plogs.SaveLog(name, pnl.Data)
				LocalPlayer():ChatPrint('Saved Log')
			end
			if IsValid(saveList) then saveList:AddSaves() end
		end,
		function(text)
		end)--:SetSkin('pLogs')
	end

	local logList = vgui.Create('DListView', pnl)
	logList:SetPos(0, 0)
	logList:SetSize(pnl:GetWide(), pnl:GetTall() - 35)
	logList:SetMultiSelect(false)
	logList:AddColumn('Time'):SetFixedWidth(75)
	logList:AddColumn('Data')
	logList.OnRowSelected = function(parent, line)
		local column 	= logList:GetLine(line)
		local log 		= column:GetColumnText(2)
		local menu 		= DermaMenu()

		menu:SetSkin('impulse')
		menu:AddOption('Copy Line', function() 
			SetClipboardText(log)
			LocalPlayer():ChatPrint('Copied Line')
		end)
		for name, value in SortedPairs(column.Copy or {}) do
			menu:AddOption('Copy ' .. name, function() 
				SetClipboardText(value or 'ERROR')
				LocalPlayer():ChatPrint('Copied ' .. name)
			end)
		end
		menu:Open()
	end
	logList.LastSearch = ''
	pnl.Data = {}
	logList.Clear = function(self)
		for k, v in pairs(self:GetLines()) do
			self:RemoveLine(k)
		end
		pnl.Data = {}
	end
	logList.AddLogs = function(self)
		for _, log in SortedPairs(data) do
			local line 	= self:AddLine(log.Date, log.Data)
			line.Copy 	= log.Copy
			pnl.Data[#pnl.Data + 1] = log
		end
	end
	logList.Search = function(self, find)
		for _, log in SortedPairs(data) do
			if string.find(string.lower(log.Data), string.lower(find), 1, true) then
				local line 	= self:AddLine(log.Date, log.Data)
				line.Copy 	= log.Copy
				pnl.Data[#pnl.Data + 1] = log
			end
		end
	end
	logList.Think = function(self)
		local tosearch = string.Trim(txt:GetValue())
		if (tosearch ~= '') and (tosearch ~= self.LastSearch) then
			self:Clear()
			self:Search(tosearch)
			self.LastSearch = tosearch
		elseif (tosearch == '') and (tosearch ~= self.LastSearch) then
			self:Clear()
			self:AddLogs()
			self.LastSearch = tosearch
		end
	end
	logList:AddLogs()
	c = c + 1
end)

net.Receive('plogs.LogData', function()
	local title = net.ReadString()
	local size = net.ReadUInt(16)
	local data = plogs.Decode(net.ReadData(size))
	LogMenu(title, data)
end)