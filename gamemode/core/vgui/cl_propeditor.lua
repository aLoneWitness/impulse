local PANEL = {}

function PANEL:Init()
	self:MakePopup()
end

function PANEL:SetTable(prop)
	self.props = vgui.Create("DProperties", self)
	--self.props:DockMargin(0, 30, 0, 0)
	self.props:Dock(FILL)

	for v,k in pairs(prop) do
		if isbool(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Boolean")
			row:SetValue(k)
		elseif isnumber(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Float", {min = -5, max = 120})
			row:SetValue(k)
		elseif isstring(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue(k)
		elseif IsColor(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("VectorColor")
			row:SetValue(Vector(k.r / 255, k.g / 255, k.b / 255))
		elseif isvector(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue("Vector("..k.x..", "..k.y..", "..k.z..")")
		end
	end
end

vgui.Register("impulsePropertyEditor", PANEL, "DFrame")