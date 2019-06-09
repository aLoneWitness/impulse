local PANEL = {}

function PANEL:Init()
	self:SetSize(350, 500)
	self:Center()
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:SetPos(0, 25)
	self.scroll:SetSize(350, 440)

	self.taking = {}
end

local bodyCol = Color(50, 50, 50, 210)
local red = Color(255, 0, 0)
function PANEL:SetInv(invdata)
	local panel = self

	for v,k in pairs(invdata) do
		local bg = self.scroll:Add("DPanel")
		bg:SetTall(38)
		bg:DockMargin(5, 3, 5, 3)
		bg:Dock(TOP)
		bg.ItemName = k.Name
		bg.ItemIllegal = k.Illegal or false
		bg.ItemClass = k.UniqueID

		function bg:Paint(w, h)
			surface.SetDrawColor(bodyCol)
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(self.ItemName, "Impulse-Elements18-Shadow", 10, 5, color_white)

			if self.ItemIllegal then
				draw.SimpleText("Contraband", "Impulse-Elements16-Shadow", 10, 22, red)	
			end

			return true
		end


		local takeBtn = vgui.Create("DCheckBox", bg)
		takeBtn:SetPos(300, 10)
		takeBtn:SetValue(0)
		takeBtn.ItemClass = k.UniqueID

		function takeBtn:OnChange(val)
			if val then
				table.insert(panel.taking, self.ItemClass)
			else
				table.RemoveByValue(panel.taking, self.ItemClass)
			end
		end
			
		local takeLbl = vgui.Create("DLabel", bg)
		takeLbl:SetPos(250, 10)
		takeLbl:SetText("Remove")
		takeLbl:SizeToContents()
	end

	self.finish = vgui.Create("DButton", self)
	self.finish:SetPos(0, 470)
	self.finish:SetSize(350, 30)
	self.finish:SetText("Close")

	function self.finish:Think()
		local count = table.Count(panel.taking)

		if count > 0 then
			self:SetText("Close (removing "..count.." items)")
		else
			self:SetText("Close")
		end
	end

	function self.finish:DoClick()
		panel:Remove()
	end
end

function PANEL:SetPlayer(ent)
	self:SetTitle(ent:Nick().."'s Inventory")
end

vgui.Register("impulseSearchMenuAdmin", PANEL, "DFrame")