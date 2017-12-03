local module = {}
worldview = module

module.Requests = module.Requests or {}
module.Rendering = false

function module.Request(id, renderData)
	local t = module.Requests[id]
	if not t then t={} module.Requests[id] = t end
	
	t.time = CurTime()
	t.data = renderData
	
	if not t.mat then
		t.mat = CreateMaterial("WorldViewReq." .. id, "UnlitGeneric", {})
	end
	
	return t.mat
end

hook.Add("PostRenderVGUI", "WorldViewRenderer", function()
	module.Rendering = true
	
	for id, req in pairs(module.Requests) do
		local isValid = req.time > CurTime() - 0.5
		
		if isValid then
			local data = req.data
			
			local w, h = data.w or 256, data.h or 256
			
			local rt = GetRenderTarget("WorldViewReqRT." .. id, w, h)
			
			render.PushRenderTarget(rt)
				render.Clear( 0, 0, 0, 255, true )
				
						local CamData = {}
						CamData.angles = data.ang or Angle(0, 0, 0)
						CamData.origin = data.pos or Vector(0, 0, 0)
						CamData.x = 0
						CamData.y = 0
						CamData.w = w
						CamData.h = h
						CamData.fov = data.fov or 90
						CamData.drawviewmodel = false
						CamData.drawhud = false
						
				cam.Start2D()
					render.RenderView(CamData)
				cam.End2D()
			render.PopRenderTarget()
			
			req.mat:SetTexture("$basetexture", rt)
		end
	end
end)