local PANEL = {}

function PANEL:Init()
	self:MakePopup()
end

function PANEL:SetTable(prop, callback)
	self.props = vgui.Create("DProperties", self)
	--self.props:DockMargin(0, 30, 0, 0)
	self.props:Dock(FILL)

	for v,k in pairs(prop) do
		if isbool(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Boolean")
			row:SetValue(k)

			function row:DataChanged(newVal)
				callback(v, tobool(newVal))
			end
		elseif isnumber(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Float", {min = -5, max = 120})
			row:SetValue(k)

			function row:DataChanged(newVal)
				callback(v, newVal)
			end
		elseif isstring(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue(k)

			function row:DataChanged(newVal)
				callback(v, newVal)
			end
		elseif IsColor(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("VectorColor")
			row:SetValue(Vector(k.r / 255, k.g / 255, k.b / 255))

			function row:DataChanged(newVal)
				callback(v, Color(newVal.x * 255, newVal.y * 255, newVal.z * 255))
			end
		elseif isvector(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue(k.x..", "..k.y..", "..k.z)

			function row:DataChanged(newValue)
				local vec = string.Split(newValue, ",")
				
				for v,k in pairs(vec) do
					string.Trim(k, " ")

					if not tonumber(k) then
						return Vector(0, 0, 0)
					else
						vec[v] = tonumber(k)
					end
				end

				callback(v, Vector(vec[1], vec[2], vec[3]))
			end
		end
	end
end

vgui.Register("impulsePropertyEditor", PANEL, "DFrame")