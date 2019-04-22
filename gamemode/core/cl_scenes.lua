impulse.Scenes = impulse.Scenes or {}

function impulse.Scenes.Play(stage, sceneData, onDone)
	impulse.Scenes.pos = nil
	impulse.Scenes.ang = nil
	sceneData.speed = sceneData.speed or 1

	net.Start("impulseScenePVS")
	net.WriteUInt(stage, 8)
	net.SendToServer()

	for k,v in pairs(ents.FindByClass("prop_physics")) do
		v:SetNoDraw(true)
	end

	hook.Add("CalcView", "impulseScene", function()
		impulse.Scenes.pos = impulse.Scenes.pos or sceneData.pos
		impulse.Scenes.ang = impulse.Scenes.ang or sceneData.ang

		local view = {}

		if sceneData.endpos and not sceneData.static then
			impulse.Scenes.pos = LerpVector(FrameTime() * sceneData.speed, impulse.Scenes.pos, sceneData.endpos)
		end

		if sceneData.endang and not sceneData.static then
			impulse.Scenes.ang = LerpAngle(FrameTime() * sceneData.speed, impulse.Scenes.ang, sceneData.endang)
		end

		if not sceneData.time and sceneData.endpos and impulse.Scenes.pos:Distance(sceneData.endpos) < 1 then 
			hook.Remove("CalcView", "impulseScene") 
			hook.Remove("HUDPaint", "impulseScene")
			impulse.hudEnabled = true
			if onDone then
				onDone()
			end

			for k,v in pairs(ents.FindByClass("prop_physics")) do
				v:SetNoDraw(false)
			end
		end

		view.origin = impulse.Scenes.pos
		view.angles = impulse.Scenes.ang
		view.farz = 15000
		view.drawviewer = true
		return view
	end)

	local outputText = ""
	local textPos = 1
	local nextTime = 0

	if sceneData.text then
		hook.Add("HUDPaint", "impulseScene", function()
			if CurTime() > nextTime and textPos != string.len(sceneData.text) then
				textPos = textPos + 1
				nextTime = CurTime() + .08
				surface.PlaySound("impulse/typewriter"..tostring(math.random(1,4))..".wav")
			end

			impulse.Scenes.markup = markup.Parse("<font=Impulse-Elements27-Shadow>"..string.sub(sceneData.text, 1, textPos).."</font>", ScrW() * .7)
			impulse.Scenes.markup:Draw(ScrW()/2, ScrH() * .8, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end)
	end

	if sceneData.fovFrom then
		net.Start("impulseSceneFOV")
		net.WriteUInt(sceneData.fovFrom, 8)
		net.WriteUInt(0, 8)
		net.SendToServer()

		net.Start("impulseSceneFOV")
		net.WriteUInt(0, 8)
		net.WriteUInt(0, sceneData.fovTime)
		net.SendToServer()
	end

	if sceneData.time then
		timer.Simple(sceneData.time, function()
			hook.Remove("CalcView", "impulseScene")
			hook.Remove("HUDPaint", "impulseScene")
			impulse.hudEnabled = true
			if onDone then
				onDone()
			end
		end)

		for k,v in pairs(ents.FindByClass("prop_physics")) do
			v:SetNoDraw(false)
		end
	end

	impulse.hudEnabled = false
end