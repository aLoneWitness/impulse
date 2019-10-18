local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 700)
	self:Center()
	self:SetTitle("")
	self:MakePopup()
end

function PANEL:SetupVendor()
	local lp = LocalPlayer()

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 120
	trace.filter = lp

	local tr = util.TraceLine(trace)

	if not tr.Entity or not IsValid(tr.Entity) or tr.Entity:GetClass() != "impulse_vendor" then
		return self:Remove()
	end

	local npc = tr.Entity
	local vendorType = npc:GetVendor()

	if not vendorType then
		return print("[impulse] Vendor has no VendorType set!")
	end

	if not impulse.Vendor.Data[vendorType] then
		return print("[impulse] "..vendorType.." invalid.")
	end

	self.NPC = npc
	self.Vendor = impulse.Vendor.Data[vendorType]

	if self.Vendor.Talk then
		surface.PlaySound(impulse.GetRandomAmbientVO(self.Vendor.Gender))
	end

	local vNameLbl = vgui.Create("DLabel", self)
	vNameLbl:SetText(self.Vendor.Name)
	vNameLbl:SetFont("Impulse-Elements27-Shadow")
	vNameLbl:SetPos(10, 33)
	vNameLbl:SizeToContents()

	local vDescLbl = vgui.Create("DLabel", self)
	vDescLbl:SetText(self.Vendor.Desc)
	vDescLbl:SetFont("Impulse-Elements17-Shadow")
	vDescLbl:SetPos(10, 58)
	vDescLbl:SetSize(300, 20)

	local yNameLbl = vgui.Create("DLabel", self)
	yNameLbl:SetText("You")
	yNameLbl:SetFont("Impulse-Elements27-Shadow")
	yNameLbl:SetPos(450, 33)
	yNameLbl:SizeToContents()

	local yDescLbl = vgui.Create("DLabel", self)
	yDescLbl:SetText("You have "..impulse.Config.CurrencyPrefix..LocalPlayer():GetMoney())
	yDescLbl:SetFont("Impulse-Elements17-Shadow")
	yDescLbl:SetPos(450, 58)
	yDescLbl:SetSize(300, 20)
end

local headerDark = Color(20, 20, 20, 180)
local listDark = Color(100, 100, 100, 18)
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h)

	surface.SetDrawColor(headerDark)
	surface.DrawRect(0, 25, 340, 58)
	surface.DrawRect(440, 25, 340, 58)

	surface.SetDrawColor(listDark)
	surface.DrawRect(0, 83, 340, h)
	surface.DrawRect(440, 83, 340, h)
end

vgui.Register("impulseVendorMenu", PANEL, "DFrame")