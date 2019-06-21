local PANEL = {}

function PANEL:Init()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()
	
	self.lblTitle:SetText('Logs')
	
	self:SetSkin('impulse')
	self:SetDraggable(true)
	self:MakePopup()

	self:SetAlpha(0)
	self:FadeIn(0.2)

	hook.Add('Think', self, function()
		if (self.animation) then
			self.animation:Run()
		end
	end)
end

function PANEL:FadeIn(speed, cback)
	self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(delta * 255)
		if (animation.Finished) then
			self.animation = nil
			if cback then cback() end
		end
	end)
	if (self.animation) then
		self.animation:Start(speed)
	end
end

function PANEL:FadeOut(speed, cback)
	self.animation = Derma_Anim('Fade Panel', self, function(panel, animation, delta, data)
		panel:SetAlpha(255 - (delta * 255))
		if (animation.Finished) then
			self.animation = nil
			if cback then cback() end
		end
	end)
	if (self.animation) then
		self.animation:Start(speed)
	end
end

function PANEL:PerformLayout()
	self.lblTitle:SizeToContents()
	self.lblTitle:SetPos(5, 3)

	self.btnClose:SetPos(self:GetWide() - 30, 0)
	self.btnClose:SetSize(30, 30)
end

function PANEL:Close(cback)
	self.Think = function() end
	self:FadeOut(0.2, function()
		self:Remove()
		if cback then cback() end
	end)
end

vgui.Register('plogs_frame', PANEL, 'DFrame')