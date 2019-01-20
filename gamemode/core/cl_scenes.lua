impulse.Scenes = impulse.Scenes or {}

function impulse.Scenes.Play(sceneData)
	impulse.Scenes.pos = nil
	impulse.Scenes.ang = nil
	hook.Add("CalcView", "impulseScene", function()
		impulse.Scenes.pos = impulse.Scenes.pos or sceneData.pos
		impulse.Scenes.ang = impulse.Scenes.ang or sceneData.ang

		if impulse.Scenes.pos:Distance(sceneData.endpos) < 1 then hook.Remove("CalcView", "impulseScene") end
		local view = {}
		impulse.Scenes.pos = LerpVector(FrameTime() * sceneData.speed, impulse.Scenes.pos, sceneData.endpos)
		impulse.Scenes.ang = LerpAngle(FrameTime() * sceneData.speed, impulse.Scenes.ang, (sceneData.endang or sceneData.ang))

		view.origin = impulse.Scenes.pos
		view.angles = impulse.Scenes.ang
		view.farz = 15000
		view.drawviewer = true
		PrintTable(view)
		return view
	end)
end