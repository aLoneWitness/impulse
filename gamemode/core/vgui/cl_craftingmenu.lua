local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 610)
	self:Center()
	self:SetTitle("")
	self:MakePopup()
end

local bodyCol = Color(50, 50, 50, 210)
function PANEL:SetupCrafting()
	local lp = LocalPlayer()

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 85
	trace.filter = lp

	local tr = util.TraceLine(trace)

	if not tr.Entity or not IsValid(tr.Entity) or tr.Entity:GetClass() != "impulse_bench" then
		return self:Remove()
	end

	local benchType = tr.Entity:GetBenchType()
	local benchClass = impulse.Inventory.Benches[benchType]
	local panel = self

	self:SetTitle(benchClass.Name)

	self.upper = vgui.Create("DPanel", self)
	self.upper:SetTall(40)
	self.upper:Dock(TOP)
	self.upper:DockMargin(0, 0, 0, 5)

	function self.upper:Paint(w, h)
		return true
	end

	self.searchLbl = vgui.Create("DLabel", self.upper)
	self.searchLbl:SetPos(410, 10)
	self.searchLbl:SetFont("Impulse-Elements19-Shadow")
	self.searchLbl:SetText("Search:")
	self.searchLbl:SizeToContents()

	self.search = vgui.Create("DTextEntry", self.upper)
	self.search:SetPos(475, 8)
	self.search:SetSize(280, 24)
	self.search:SetFont("Impulse-Elements18")
	self.search:SetText("")
	self.search:SetUpdateOnType(true)

	self.mixes = {}

	local strMatch = string.match
	function self.search:OnValueChange(search)
		search = search:upper()

		for v,k in pairs(panel.mixes) do
			local name = k.Item.Name
			local x, y = k:GetPos()

			if strMatch(name, search) then
				print(name)
				panel.scroll:GetVBar():AnimateTo(y, 0.2)
				break
			end
		end
	end

	self.craftLbl = vgui.Create("DLabel", self.upper)
	self.craftLbl:SetPos(5, 5)
	self.craftLbl:SetFont("Impulse-Elements22-Shadow")
	self.craftLbl:SetText("Crafting Level: "..LocalPlayer():GetSkillLevel("craft"))
	self.craftLbl:SizeToContents()

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:Dock(FILL)

	self.availibleMixes = vgui.Create("DCollapsibleCategory", self.scroll)
	self.availibleMixes:SetLabel("Available mixes")
	self.availibleMixes:Dock(TOP)

	function self.availibleMixes:Paint()
		self:SetBGColor(colInv)
	end

	self.availibleMixesLayout = vgui.Create("DListLayout")
	self.availibleMixesLayout:Dock(FILL)
	self.availibleMixes:SetContents(self.availibleMixesLayout)

	self.unAvailibleMixes = self.scroll:Add("DCollapsibleCategory")
	self.unAvailibleMixes:SetLabel("Unavailable mixes")
	self.unAvailibleMixes:Dock(TOP)

	function self.unAvailibleMixes:Paint()
		self:SetBGColor(colInv)
	end

	for v,k in pairs(impulse.Inventory.Mixtures[benchType]) do
		local cat = self.availibleMixesLayout

		for i=1,11 do
			local mix = cat:Add("impulseCraftingItem")
			mix:Dock(TOP)
			mix:SetMix(k)

			table.insert(self.mixes, mix)
		end
	end
end

vgui.Register("impulseCraftingMenu", PANEL, "DFrame")