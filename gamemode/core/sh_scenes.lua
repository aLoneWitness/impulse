if CLIENT then
	impulse.Scenes = impulse.Scenes or {}

	function impulse.Scenes.Play(stage, sceneData, onDone)
		impulse.Scenes.pos = nil
		impulse.Scenes.ang = nil
		sceneData.speed = sceneData.speed or 1

		net.Start("impulseScenePVS")
		net.WriteVector(sceneData.pos)
		net.SendToServer()

		for k,v in pairs(ents.GetAll()) do
			if v.CPPIGetOwner and v:CPPIGetOwner() then
				v:SetNoDraw(true)
			end
		end

		local fov
		local lastAdd = 0
		local lastPosAdd = 0
		hook.Add("CalcView", "impulseScene", function()
			impulse.Scenes.pos = impulse.Scenes.pos or sceneData.pos
			impulse.Scenes.ang = impulse.Scenes.ang or sceneData.ang

			local view = {}

			if sceneData.endpos and not sceneData.static then
			    if sceneData.posNoLerp then
			    	lastPosAdd = lastPosAdd + FrameTime() * sceneData.posSpeed
			    	impulse.Scenes.pos = LerpVector(lastPosAdd, sceneData.pos, sceneData.endpos)
			    else
			    	impulse.Scenes.pos = LerpVector(FrameTime() * sceneData.speed, impulse.Scenes.pos, sceneData.endpos)
			    end
			end

			if sceneData.endang and not sceneData.static then
				impulse.Scenes.ang = LerpAngle(FrameTime() * sceneData.speed, impulse.Scenes.ang, sceneData.endang)
			end

			if sceneData.fovFrom or sceneData.fovTo then
				if sceneData.fovSpeed then
					if sceneData.fovNoLerp then
						lastAdd = lastAdd + FrameTime() * sceneData.fovSpeed
						fov = Lerp(lastAdd, sceneData.fovFrom or 70, sceneData.fovTo or 70)
					else
						fov = Lerp(FrameTime() * sceneData.fovSpeed + ((fov or 0) * 0.000013), fov or (sceneData.fovFrom or 70), sceneData.fovTo or 70)
					end
				else
					fov = sceneData.fovFrom
				end
			end

			view.origin = impulse.Scenes.pos
			view.angles = impulse.Scenes.ang
			view.farz = 15000
			view.drawviewer = true
			view.fov = fov
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

		if sceneData.time then
			timer.Simple(sceneData.time, function()
				hook.Remove("CalcView", "impulseScene")
				hook.Remove("HUDPaint", "impulseScene")
				impulse.hudEnabled = true

				if onDone then
					onDone()
				end

				for k,v in pairs(ents.GetAll()) do
					if v.CPPIGetOwner and v:CPPIGetOwner() then
						v:SetNoDraw(false)
					end
				end
			end)

			if sceneData.fadeOut then
				timer.Simple(sceneData.time - 1, function()
					LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, 0.05)
				end)
			end
		end

		if sceneData.onStart then
			sceneData.onStart()
		end

		if sceneData.fadeIn then
			LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 1, 0)
		end

		impulse.hudEnabled = false
	end

	function impulse.Scenes.PlaySet(set, music, onDone)
		local counter = 1

		local function playScenes()
			if set[counter + 1] then
				counter = counter + 1
				impulse.Scenes.Play(counter, set[counter], playScenes)
			elseif onDone then
				onDone()
			end
		end

		if music then
			if music:find("www.") or music:find("http") then
				if IsValid(SCENE_MUSIC) then
					SCENE_MUSIC:stop()
				end

				local service = medialib.load("media").guessService(link)
				local clip = service:load(music)

				SCENE_MUSIC = clip

				clip:play()
			else
				surface.PlaySound(music)
			end
		end

		impulse.Scenes.Play(1, set[counter], playScenes)
	end
end