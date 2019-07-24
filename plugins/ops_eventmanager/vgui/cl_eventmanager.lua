local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 610)
	self:Center()
	self:SetSkin("default")
	self:SetTitle("ops event manager")

	self.sheet = vgui.Create("DColumnSheet", self)
	self.sheet:Dock(FILL)

	local music = vgui.Create("DPanel", sheet)
	music:Dock(FILL)
	self.sheet:AddSheet("Music", music, "icon16/ipod_sound.png")
end

vgui.Register("impulseEventManager", PANEL, "DFrame")