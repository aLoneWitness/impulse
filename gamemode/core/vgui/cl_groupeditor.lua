local PANEL = {}

function PANEL:Init()
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("Group Menu")
	self:MakePopup()

	local panel = self

	if LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "") != "" then
		self:ShowGroup()
	else
		self:NoGroup()
	end
end

function PANEL:AddSheet(name, icon)
	local sheet = vgui.Create("DPanel", self.sheet)
	sheet.Paint = function() end
	sheet:DockMargin(5, 5, 5, 5)
	sheet:Dock(FILL)

	self.sheet:AddSheet(name, sheet, icon)

	return sheet
end

function PANEL:NoGroup()
	local panel = self
	local darkText = Color(150, 150, 150, 210)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("You are not a member of a group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(60)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Once you get invited to a group you'll be able to accept the invite here.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Create a new group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(90)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Creating a new group will cost "..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost.." and will require at least "..impulse.Config.GroupXPRequirement.."XP.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local newGroup = vgui.Create("DButton", self)
	newGroup:SetTall(25)
	newGroup:SetWide(300)
	newGroup:SetText("Create new group ("..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost..")")
	newGroup:DockMargin(160, 0, 160, 0)
	newGroup:Dock(TOP)
end

function PANEL:ShowGroup()
	self.sheet = vgui.Create("DColumnSheet", self)
	self.sheet:Dock(FILL)

	local sheet = self:AddSheet("Overview", "icon16/vcard.png")

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText(LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "Unknown Name"))
	lbl:SetFont("Impulse-CharacterInfo-NO")
	lbl:SetPos(5, 0)
	lbl:SizeToContents()

	local group = impulse.Group.Groups[1]

	if not group then
		LocalPlayer():Notify("Failed to load group data!")
		return
	end

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Total members: "..table.Count(group.Members))
	lbl:SetFont("Impulse-Elements20-Shadow")
	lbl:SetPos(5, 32)
	lbl:SizeToContents()

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Your rank: "..LocalPlayer():GetSyncVar(SYNC_GROUP_RANK, "Unknown Rank"))
	lbl:SetFont("Impulse-Elements20-Shadow")
	lbl:SetPos(5, 47)
	lbl:SizeToContents()

	local inv = vgui.Create("DButton", sheet)
	inv:SetText("Invite a new member")
	inv:SetPos(5, 70)
	inv:SetSize(500, 20)

	function inv:DoClick()
		local m = DermaMenu()

		local gname = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, " ")
		for v,k in pairs(player.GetAll()) do
			if k:GetSyncVar(SYNC_GROUP_NAME, "") == gname then
				continue
			end

			m:AddOption(k)
		end

		m:Open()
	end

	if not LocalPlayer():GroupHasPermission(3) then
		inv:SetDisabled(true)
	end

	local members = vgui.Create("DListView", sheet)
	members:SetPos(5, 100)
	members:SetSize(500, 360)
	members:SetMultiSelect(false)
	members:AddColumn("Name")
	members:AddColumn("Rank")

	for v,k in SortedPairsByMemberValue(group.Members, "Rank") do
		local line = members:AddLine(k.Name, k.Rank)
		line.SteamID = v
	end

	function members:OnRowSelected(index, row)
		local sid = row.SteamID

		local m = DermaMenu()

		if LocalPlayer():GroupHasPermission(5) then
			local sRank = m:AddOption("Set rank")
			sRank:SetIcon("icon16/user_edit.png")
			local sub = sRank:AddSubMenu(a)

			for a,b in SortedPairs(group.Ranks) do
				sub:AddOption(a)
			end
		end

		if LocalPlayer():GroupHasPermission(4) then
			local sRmv = m:AddOption("Remove")
			sRmv:SetIcon("icon16/user_delete.png")
		end

		m:Open()
	end

	if LocalPlayer():GroupHasPermission(6) then
		self:ShowRanks()
	end
end

local function addGroup(s, name)
	local sheet = vgui.Create("DPanel", s.ranks)
	sheet.Paint = function() end
	sheet:DockMargin(5, 5, 5, 5)
	sheet:Dock(FILL)

	s:AddSheet(name, sheet)

	return sheet
end


function PANEL:ShowRanks()
	local group = impulse.Group.Groups[1]
	local sheet = self:AddSheet("Ranks", "icon16/group_edit.png")

	self.ranks = vgui.Create("DColumnSheet", sheet)
	self.ranks:Dock(FILL)

	self.ranks.Navigation:SetWide(150)

	for v,k in pairs(group.Ranks) do
		local group = addGroup(self.ranks, v)

		local scroll = vgui.Create("DScrollPanel", group)
		scroll:Dock(FILL)

		local lbl = vgui.Create("DLabel", scroll)
		lbl:SetText("")
		lbl:SetColor(Color(220, 20, 60))
		lbl:SetFont("Impulse-Elements16-Shadow")
		lbl:Dock(TOP)

		local removable = true
		if k[99] or k[0] then
			lbl:SetText("this group can not be removed")
			removable = false
		end

		local lbl = vgui.Create("DLabel", scroll)
		lbl:SetText("Name:")
		lbl:SetFont("Impulse-Elements18-Shadow")
		lbl:Dock(TOP)

		local name = vgui.Create("DTextEntry", scroll)
		name:SetValue(v)
		name:Dock(TOP)
		name:DockMargin(0, 0, 0, 5)

		for a,b in pairs(RPGROUP_PERMISSIONS) do
			local check = vgui.Create("DCheckBoxLabel", scroll)
			check:SetValue(k[a] or false)
			check:SetText(b)
			check:Dock(TOP)

			if a == 0 or a == 99 then
				check:SetDisabled(true)
			end
		end

		local del = vgui.Create("DButton", scroll)
		del:SetText("Remove rank")
		del:DockMargin(0, 10, 0, 0)
		del:Dock(TOP)
	end

	local addRank = addGroup(self.ranks, "New group...")

	local scroll = vgui.Create("DScrollPanel", addRank)
	scroll:Dock(FILL)

	local lbl = vgui.Create("DLabel", scroll)
	lbl:SetText("Name:")
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:Dock(TOP)

	local name = vgui.Create("DTextEntry", scroll)
	name:SetValue("Group name")
	name:Dock(TOP)
	name:DockMargin(0, 0, 0, 5)

	for a,b in pairs(RPGROUP_PERMISSIONS) do
		local check = vgui.Create("DCheckBoxLabel", scroll)
		check:SetValue(false)
		check:SetText(b)
		check:Dock(TOP)

		if a == 0 or a == 99 then
			check:SetDisabled(true)
		end
	end

	local create = vgui.Create("DButton", scroll)
	create:SetText("Create rank")
	create:DockMargin(0, 10, 0, 0)
	create:Dock(TOP)
end


vgui.Register("impulseGroupEditor", PANEL, "DFrame")