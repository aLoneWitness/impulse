local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 600)
	self:Center()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
 	self:MoveToFront()
 	self:SetBackgroundBlur(true)

 	http.Fetch("http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr="..game.GetIPAddress(), function(json)
 		if not IsValid(self) then
 			return
 		end
 		
 		local data = util.JSONToTable(json)

 		if not data["response"]["servers"] then
 			self.ServerIsOff = true
 			self:DoLamar()
 		else
 			self.ServerIsOff = false
 		end
 	end, function()
 		self.ServerIsOff = false
 	end)
end

function PANEL:DoLamar()
	local function wait(s, f)
		timer.Simple(s, function()
			if IsValid(self) then
				f()
			end
		end)
	end

	local function doAnim()
		self.lamar = vgui.Create("DModelPanel", self)
	 	self.lamar:SetSize(700, 400)
	 	self.lamar:SetPos(0, 200)
	 	self.lamar:SetFOV(100)
	 	self.lamar:SetModel("models/lamarr.mdl")
	 	self.lamar:SetAnimated(true)

	 	function self.lamar:LayoutEntity(ent)
	 		ent:FrameAdvance()
	 		return
	 	end

	 	local badcarb = self.lamar:GetEntity():LookupSequence("lamarr_crow")

	 	self.lamar:GetEntity():ResetSequence(badcarb)

	 	local pos = Vector(120, 50, 50)
	 	self.lamar:SetCamPos(pos)
	 	self.lamar:SetLookAt(pos + Vector(-10, -70, -10))
	end

	local r = math.random(2, 6)
	wait(r, function()
		surface.PlaySound("npc/headcrab/pain1.wav")

		local x = 0
		x = x + 1
		wait(x, function()
			surface.PlaySound("vo/k_lab/kl_comeout.wav")
		end)

		x = x + 2.3
		wait(x, function()
			surface.PlaySound("npc/headcrab/alert1.wav")
		end)

		x = x + 2
		wait(x, function()
			surface.PlaySound("vo/k_lab/kl_lamarr.wav")
		end)

		x = x + 2.6
		wait(x, function()
			surface.PlaySound("npc/headcrab/pain3.wav")
		end)

		x = x + 2
		wait(x, function()
			surface.PlaySound("vo/k_lab/kl_nocareful.wav")
		end)

		x = x + 2.1
		wait(x, doAnim)

		x = x + 1.6
		wait(x, function()
			surface.PlaySound("npc/headcrab/attack2.wav")
		end)
	end)
end

function PANEL:Think()
	self:MoveToFront()
end

function PANEL:PaintOver()
	local w = ScrW() * 0.3
	local h = ScrH() * 0.3
	w = 20
	h = 30

	draw.SimpleText(":( Connection lost", "Impulse-Elements72-Shadow", w, h)

	if self.ServerIsOff == nil then
		draw.SimpleText("Checking server status...", "Impulse-Elements22-Shadow", w, h + 70)
		return
	end

	if self.ServerIsOff then
		draw.SimpleText("The server has gone offline. Try reconnecting in a few minutes.", "Impulse-Elements22-Shadow", w, h + 70)
		draw.SimpleText("You will be refunded automatically.", "Impulse-Elements19-Shadow", w, h + 90)
	else
		draw.SimpleText("You've lost connection to the server. Try reconnecting in a few minutes.", "Impulse-Elements22-Shadow", w, h + 70)
		draw.SimpleText("Check your router or internet connection.", "Impulse-Elements19-Shadow", w, h + 90)
	end
end

vgui.Register("impulseCrashScreen", PANEL, "DFrame")
