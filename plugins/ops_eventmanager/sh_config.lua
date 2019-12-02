impulse.Ops.EventManager.Config.CategoryIcons = {
	["music"] = "icon16/music.png",
	["effect"] = "icon16/wand.png",
	["sound"] = "icon16/sound.png",
	["ui"] = "icon16/monitor.png",
	["server"] = "icon16/server.png",
	["scene"] = "icon16/film.png",
	["npc"] = "icon16/user.png",
	["ent"] = "icon16/brick.png"
}

impulse.Ops.EventManager.Config.Events = {
	["screenshake"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["amplitude"] = 5,
			["frequency"] = 5,
			["duration"] = 4,
			["radius"] = 10000 
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			util.ScreenShake(prop["pos"], prop["amplitude"], prop["frequency"], prop["duration"], prop["radius"])
		end
	},
	["timescale"] = {
		Cat = "effect",
		Prop = {
			["timescale"] = 1
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			game.SetTimeScale(prop["timescale"])
		end
	},
	["fog"] = {
		Cat = "effect",
		Prop = {
			["start"] = 10,
			["end"] = 10,
			["density"] = 1,
			["colour"] = Color(255, 255, 255)
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Add("SetupWorldFog", "opsEMFog", function()
				render.FogMode(MATERIAL_FOG_LINEAR)
				render.FogStart(prop["start"])
				render.FogEnd(prop["end"])
				render.FogMaxDensity(prop["density"])
				render.FogColor(prop["colour"])

				return true
			end)

			hook.Add("SetupSkyboxFog", "opsEMFog", function(scale)
				render.FogMode(MATERIAL_FOG_LINEAR)
				render.FogStart(prop["start"] * scale)
				render.FogEnd(prop["end"] * scale)
				render.FogMaxDensity(prop["density"])
				render.FogColor(prop["colour"])

				return true
			end)
		end
	},
	["killfog"] = {
		Cat = "effect",
		Prop = {},
		NeedUID = false,
		Clienside = true,
		Do = function(prop, uid)
			hook.Remove("SetupWorldFog", "opsEMFog")
			hook.Remove("SetupSkyboxFog", "opsEMFog")
		end
	},
	["chat"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Message"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:SendChatClassMessage(14, prop["message"], Entity(0))
			end
		end
	},
	["cineintro"] = {
		Cat = "ui",
		Prop = {
			["title"] = "Event Name"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			impulse.CinematicIntro(prop["title"])
		end
	},
	["screenfade"] = {
		Cat = "ui",
		Prop = {
			["flag"] = 1,
			["colour"] = Color(255, 255, 255),
			["fadetime"] = 2,
			["fadehold"] = 1
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:ScreenFade(prop["flag"], prop["colour"], prop["fadetime"], prop["fadehold"])
			end
		end
	},
	["spawnent"] = {
		Cat = "ent",
		Prop = {
			["model"] = "mdl here",
			["skin"] = 0,
			["pos"] = Vector(0, 0, 0),
			["ang"] = Angle(0, 0, 0),
			["ignite"] = false,
			["physics"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			local ent = vgui.Create("prop_physics")
			ent:SetModel(prop["model"])
			ent:SetSkin(prop["skin"])
			ent:SetPos(prop["pos"])
			ent:SetAngles(prop["ang"])
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()

			if phys and phys:IsValid() and prop["physics"] then
				phys:EnableMotion(false)
			end

			if prop["ignite"] then
				ent:Ignite()
			end

			OPS_ENTS = OPS_ENTS or {}
			OPS_ENTS[uid] = ent
		end
	},
	["skinent"] = {
		Cat = "ent",
		Prop = {
			["newskin"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:SetSkin(prop["newskin"])
			end
		end
	},
	["removeent"] = {
		Cat = "ent",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end
		end
	},
	["soundplay"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["level"] = 75,
			["volume"] = 1
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			LocalPlayer():EmitSound(prop["sound"], prop["level"], nil, prop["volume"])
		end
	},
	["emitsound"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["pos"] = Vector(0, 0, 0),
			["volume"] = 1,
			["level"] = 75
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local x = ents.Create("info_target")
			x:SetPos(prop["pos"])
			x:EmitSound(prop["sound"], prop["level"], nil, prop["volume"])
			x:Spawn()

			timer.Simple(1, function()
				x:Remove()
			end)
		end
	},
	["urlmusic_play"] = {
		Cat = "music",
		Prop = {
			["url"] = "this must be a .mp3",
			["volume"] = 1
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			local service = medialib.load("media").guessService(prop["url"])
			local mediaclip = service:load(prop["url"])

			OPS_MUSIC = OPS_MUSIC or {}
			OPS_MUSIC[uid] = mediaclip

			mediaclip:Play()
		end
	},
	["urlmusic_stop"] = {
		Cat = "music",
		Prop = {},
		NeedUID = true,
		Clienside = true,
		Do = function(prop, uid)
			if OPS_MUSIC and OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:stop()
			end
		end
	},
	["urlmusic_setvolume"] = {
		Cat = "music",
		Prop = {
			["volume"] = 1
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_MUSIC and OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:setVolume(prop["volume"])
			end
		end
	},
	["changelevel"] = {
		Cat = "server",
		Prop = {
			["map"] = ".bsp"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			RunConsoleCommand("changelevel", prop["map"])
		end
	}
}