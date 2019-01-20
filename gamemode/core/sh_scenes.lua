netstream.Hook("impulseSceneFOV", function(ply, fov, time) -- for some reason setfov is broken on client
	ply:SetFOV(fov, time)
end)

if SERVER then return end

impulse.Scenes = impulse.Scenes or {}

function impulse.Scenes.Play(sceneData, onDone)
	impulse.Scenes.pos = nil
	impulse.Scenes.ang = nil
	sceneData.speed = sceneData.speed or 1

	if sceneData.text then
		impulse.Scenes.markup = markup.Parse("<font=Impulse-Elements27-Shadow>"..sceneData.text.."</font>")
	end

	hook.Add("CalcView", "impulseScene", function()
		impulse.Scenes.pos = impulse.Scenes.pos or sceneData.pos
		impulse.Scenes.ang = impulse.Scenes.ang or sceneData.ang

		if not sceneData.time and impulse.Scenes.pos:Distance(sceneData.endpos) < 1 and not sceneData.time then 
			hook.Remove("CalcView", "impulseScene") 
			hook.Remove("HUDPaint", "impulseScene")
			impulse.hudEnabled = true
			if onDone then
				onDone()
			end
		end

		local view = {}
		impulse.Scenes.pos = LerpVector(FrameTime() * sceneData.speed, impulse.Scenes.pos, (sceneData.endpos or sceneData.pos))
		impulse.Scenes.ang = LerpAngle(FrameTime() * sceneData.speed, impulse.Scenes.ang, (sceneData.endang or sceneData.ang))

		view.origin = impulse.Scenes.pos
		view.angles = impulse.Scenes.ang
		view.farz = 15000
		view.drawviewer = true
		return view
	end)

	if sceneData.text then
		hook.Add("HUDPaint", "impulseScene", function()
			impulse.Scenes.markup:Draw(ScrW()/2, ScrH() * .8, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end)
	end

	if sceneData.fovFrom then
		netstream.Start("impulseSceneFOV", sceneData.fovFrom, 0)
		netstream.Start("impulseSceneFOV", 0, sceneData.fovTime)
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
	end

	impulse.hudEnabled = false
end