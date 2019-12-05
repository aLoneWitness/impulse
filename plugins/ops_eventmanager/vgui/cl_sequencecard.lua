local PANEL = {}

function PANEL:Init()
end

function PANEL:SetSequence(key, data)
	self.main = vgui.Create("DCollapsibleCategory", self)
	self.main:Dock(FILL)
	self.main:SetLabel("Sequence: "..key)
	self.main.Header:SetTall(25)

	self.mainScroll = vgui.Create("DScrollPanel", self.main)
	self.mainScroll:Dock(FILL)
	self.main:SetContents(self.mainScroll)

	self.mainList = vgui.Create("DIconLayout", self.mainScroll)
	self.mainList:Dock(FILL)
	self.mainList:SetSpaceY(5)
	self.mainList:SetSpaceX(5)

	self.Sequence = key

	for v,k in pairs(data.Events) do
		self:AddEvent(v, k)
	end

	local panel = self

	local newSeq = vgui.Create("DButton", self.main)
	newSeq:SetPos(540, 0)
	newSeq:SetSize(100, 20)
	newSeq:SetText("Add event")
	newSeq:SetImage("icon16/script_add.png")

	function newSeq:DoClick()
		local id = table.insert(impulse.Ops.EventManager.Sequences[key].Events, {
			Type = "chat",
			Prop = impulse.Ops.EventManager.Config.Events["chat"].Prop,
			UID = nil,
			Delay = 0
		})

		panel:AddEvent(id, impulse.Ops.EventManager.Sequences[key].Events[id])
	end

	local remSeq = vgui.Create("DButton", self.main)
	remSeq:SetPos(435, 0)
	remSeq:SetSize(100, 20)
	remSeq:SetText("Close")
	remSeq:SetImage("icon16/delete.png")

	function remSeq:DoClick()
		impulse.Ops.EventManager.Sequences[key] = nil
		panel.Dad:ReloadSequences()
	end

	local saveSeq = vgui.Create("DButton", self.main)
	saveSeq:SetPos(330, 0)
	saveSeq:SetSize(100, 20)
	saveSeq:SetText("Save")
	saveSeq:SetImage("icon16/script_save.png")

	function saveSeq:DoClick()
		if not impulse.Ops.EventManager.Sequences[key].FileName then
			Derma_StringRequest("impulse", "Enter sequence file name:", nil, function(name)
				impulse.Ops.EventManager.Sequences[key].FileName = name
				impulse.Ops.EventManager.SequenceSave(key)
				LocalPlayer():Notify("Saved sequence: "..key..".")
			end)
		else
			impulse.Ops.EventManager.SequenceSave(key)
			LocalPlayer():Notify("Saved sequence: "..key..".")
		end
	end

	local uploadSeq = vgui.Create("DButton", self.main)
	uploadSeq:SetPos(225, 0)
	uploadSeq:SetSize(100, 20)
	uploadSeq:SetText("Push")
	uploadSeq:SetImage("icon16/server_connect.png")

	function uploadSeq:DoClick()
		impulse.Ops.EventManager.SequencePush(key)
	end

	function self.main:Toggle() -- allowing them to accordion causes bugs
		return
	end
end

function PANEL:AddEvent(id, eventdata)
	local event = self.mainList:Add("DPanel")
	event:Dock(TOP)

	local panel = self

	function event:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))
		draw.RoundedBox(0, 0, h-2, w, 2, Color(100, 100, 100, 150))

		if panel.Sequence == impulse.Ops.EventManager.GetSequence() and impulse.Ops.EventManager.GetEvent() == id then
			draw.RoundedBox(0, 0, 0, w, h, Color(127, 255, 0, 30))
		end
	end

	event.etypeicon = vgui.Create("DImage", event)
	event.etypeicon:SetPos(2, 2)
	event.etypeicon:SetSize(16, 16)
	event.etypeicon:SetImage(impulse.Ops.EventManager.Config.CategoryIcons[impulse.Ops.EventManager.Config.Events[eventdata.Type].Cat])

	event.etype = vgui.Create("DLabel", event)
	event.etype:SetPos(20, 2)
	event.etype:SetText("Event: "..eventdata.Type)
	event.etype:SizeToContents()

	local delay = vgui.Create("DLabel", event)
	delay:SetPos(530, 2)
	delay:SetText("Delay:")
	delay:SizeToContents()

	event.edelay = vgui.Create("DNumberWang", event)
	event.edelay:SetDecimals(0)
	event.edelay:SetPos(575, 2)
	event.edelay:SetSize(40, 18)
	event.edelay:SetMin(0)
	event.edelay:SetUpdateOnType(true)
	event.edelay:SetMinMax(0, 9999)
	event.edelay:SetValue(eventdata.Delay)

	function event.edelay:OnValueChanged(new)
		if tonumber(new) then
			local realNew = math.Clamp(tonumber(new), 0, 9999)
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Delay = realNew
		end
	end

	event.eremove = vgui.Create("DImageButton", event)
	event.eremove:SetPos(626, 2)
	event.eremove:SetImage("icon16/script_delete.png")
	event.eremove:SizeToContents()

	function event.eremove:DoClick()
		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		panel.Dad:ReloadSequences()
	end

	event.etypebtn = vgui.Create("DImageButton", event)
	event.etypebtn:SetPos(226, 2)
	event.etypebtn:SetImage("icon16/textfield_rename.png")
	event.etypebtn:SizeToContents()

	function event.etypebtn:DoClick()
		local m = DermaMenu()
		local cats = {}

		for v,k in pairs(impulse.Ops.EventManager.Config.Events) do
			if not cats[k.Cat] then
				local c, p = m:AddSubMenu(k.Cat)
				p:SetIcon(impulse.Ops.EventManager.Config.CategoryIcons[k.Cat])
				cats[k.Cat] = c
			end

			local parent = cats[k.Cat]
			parent:AddOption(v, function()
				impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Type = v
				impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop = impulse.Ops.EventManager.Config.Events[v].Prop
				panel.Dad:ReloadSequences()
			end)
		end

		m:Open()
	end

	event.eprop = vgui.Create("DImageButton", event)
	event.eprop:SetPos(246, 2)
	event.eprop:SetImage("icon16/script_edit.png")
	event.eprop:SizeToContents()

	function event.eprop:DoClick()
		if panel.Dad.Properties and IsValid(panel.Dad.Properties) then
			panel.Dad.Properties:Remove()
		end

		panel.Dad.Properties = vgui.Create("impulsePropertyEditor")
		panel.Dad.Properties:SetTable(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop, function(key, val)
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop[key] = val
		end)
		panel.Dad.Properties:SetTitle(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Type.." properties")

		local x, y = panel.Dad:GetPos()
		panel.Dad.Properties:SetPos(x + panel.Dad:GetWide() + 10, y)
		panel.Dad.Properties:SetSize(300, 300)
	end

	local delay = vgui.Create("DLabel", event)
	delay:SetPos(320, 2)
	delay:SetText("UID:")
	delay:SizeToContents()

	event.euid = vgui.Create("DTextEntry", event)
	event.euid:SetPos(360, 2)
	event.euid:SetSize(140, 20)
	event.euid:SetText(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID or "")
	event.euid:SetUpdateOnType(true)

	function event.euid:OnValueChange(new)
		local new = string.Trim(new, " ")

		if new == "" then
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID = nil
			return
		end

		impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID = new
	end

	event.emup = vgui.Create("DImageButton", event)
	event.emup:SetPos(270, 2)
	event.emup:SetImage("icon16/arrow_up.png")
	event.emup:SizeToContents()

	function event.emup:DoClick()
		local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
		local oldId = id
		local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)

		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, math.Clamp(oldId - 1, 1, size), me)

		panel.Dad:ReloadSequences()
	end

	event.emdown = vgui.Create("DImageButton", event)
	event.emdown:SetPos(286, 2)
	event.emdown:SetImage("icon16/arrow_down.png")
	event.emdown:SizeToContents()

	function event.emdown:DoClick()
		local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
		local oldId = id
		local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)

		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, math.Clamp(oldId + 1, 1, size), me)

		panel.Dad:ReloadSequences()
	end

	self:SetTall(self:GetTall() + event:GetTall())
end

local normal = Color(90, 90, 90, 255)
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, normal)
end

vgui.Register("impulseSequenceCard", PANEL, "DPanel")