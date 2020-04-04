impulse.Ops.EventManager.Config.CategoryIcons = {
	["music"] = "icon16/music.png",
	["effect"] = "icon16/wand.png",
	["sound"] = "icon16/sound.png",
	["ui"] = "icon16/monitor.png",
	["server"] = "icon16/server.png",
	["scene"] = "icon16/film.png",
	["npc"] = "icon16/user.png",
	["ent"] = "icon16/brick.png",
	["cookies"] = "icon16/database.png"
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

				local col = prop["colour"]
				render.FogColor(col.r, col.g, col.b)

				return true
			end)

			hook.Add("SetupSkyboxFog", "opsEMFog", function(scale)
				render.FogMode(MATERIAL_FOG_LINEAR)
				render.FogStart(prop["start"] * scale)
				render.FogEnd(prop["end"] * scale)
				render.FogMaxDensity(prop["density"])

				local col = prop["colour"]
				render.FogColor(col.r, col.g, col.b)

				return true
			end)
		end
	},
	["killfog"] = {
		Cat = "effect",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Remove("SetupWorldFog", "opsEMFog")
			hook.Remove("SetupSkyboxFog", "opsEMFog")
		end
	},
	["explode"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["magnitude"] = 200
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local explodeEnt = ents.Create("env_explosion")
	        explodeEnt:SetPos(prop["pos"])
	        explodeEnt:Spawn()
	        explodeEnt:SetKeyValue("iMagnitude", prop["magnitude"])
	        explodeEnt:Fire("explode", "", 0)
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
	["hudoff"] = {
		Cat = "ui",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			impulse.hudEnabled = false
		end
	},
	["hudon"] = {
		Cat = "ui",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			impulse.hudEnabled = true
		end
	},
	["webvideo"] = {
		Cat = "ui",
		Prop = {
			["url"] = ".mp4 plz"
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			local service = medialib.load("media").guessService(prop["url"])
			local mediaclip = service:load(prop["url"])

			OPS_VIDS = OPS_VIDS or {}

			if OPS_VIDS[uid] then
				OPS_VIDS[uid]:stop()
				OPS_VIDS[uid] = nil
			end

			OPS_VIDS[uid] = mediaclip

			mediaclip:play()

			hook.Add("HUDPaint", "opsEMVideo", function()
				if OPS_VIDS[uid] then
					OPS_VIDS[uid]:draw(0, 0, w, h)
				end
			end)
		end
	},
	["text"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Sample Text",
			["pos_x"] = 0.5,
			["pos_y"] = 0.5,
			["message_fadein"] = 3,
			["message_fadeout"] = 3,
			["message_hold"] = 5,
			["message_colour"] = Color(255, 255, 255, 255),
			["message_align"] = TEXT_ALIGN_CENTER
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			local text = vgui.Create("impulseFadeText")
			text:Setup(prop["message"], prop["pos_x"], prop["pos_y"], prop["message_fadein"], prop["message_fadeout"], prop["message_hold"], prop["message_colour"], prop["message_align"])
		end
	},
	["spawnent"] = {
		Cat = "ent",
		Prop = {
			["model"] = "mdl here",
			["skin"] = 0,
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["ignite"] = false,
			["physics"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS = OPS_ENTS or {}

			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end

			local ent = ents.Create(prop["physics"] and "prop_physics" or "prop_dynamic")
			ent:SetModel(prop["model"])
			ent:SetSkin(prop["skin"])
			ent:SetPos(prop["pos"])
			ent:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()

			if phys and phys:IsValid() and prop["physics"] then
				phys:EnableMotion(true)
			elseif phys and phys:IsValid() then
				phys:EnableMotion(false)
			end

			if prop["ignite"] then
				ent:Ignite(120)
			end

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
	["scaleent"] = {
		Cat = "ent",
		Prop = {
			["newscale"] = 2,
			["time"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:SetModelScale(prop["newscale"], prop["time"])
			end
		end
	},
	["animent"] = {
		Cat = "ent",
		Prop = {
			["sequence"] = "idle"
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:ResetSequence(prop["sequence"])
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
	["advsoundplay"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["level"] = 75,
			["volume"] = 1,
			["volumetime"] = 0
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			OPS_SOUNDS = OPS_SOUNDS or {}

			if OPS_SOUNDS[uid] then
				OPS_SOUNDS[uid]:Stop()
				OPS_SOUNDS[uid] = nil
			end

			OPS_SOUNDS[uid] = CreateSound(LocalPlayer(), prop["sound"])
			OPS_SOUNDS[uid]:SetSoundLevel(prop["level"])
			OPS_SOUNDS[uid]:ChangeVolume(prop["volume"])
			OPS_SOUNDS[uid]:Play()
		end
	},
	["advsoundsetvolume"] = {
		Cat = "sound",
		Prop = {
			["newvolume"] = 1,
			["time"] = 0
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_SOUNDS and OPS_SOUNDS[uid] and OPS_SOUNDS[uid] and OPS_SOUNDS[uid]:IsPlaying() then
				OPS_SOUNDS[uid]:ChangeVolume(prop["newvolume"], prop["time"])
			end
		end
	},
	["advsoundstop"] = {
		Cat = "sound",
		Prop = {},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_SOUNDS and OPS_SOUNDS[uid] and OPS_SOUNDS[uid] and OPS_SOUNDS[uid]:IsPlaying() then
				OPS_SOUNDS[uid]:Stop()
				OPS_SOUNDS[uid] = nil
			end
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

			if OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:stop()
				OPS_MUSIC[uid] = nil
			end

			OPS_MUSIC[uid] = mediaclip

			mediaclip:play()
		end
	},
	["urlmusic_stop"] = {
		Cat = "music",
		Prop = {},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_MUSIC and OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:stop()
				OPS_MUSIC[uid] = nil
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
	},
	["achievementgive"] = {
		Cat = "server",
		Prop = {
			["achievementid"] = ""
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:AchievementGive(prop["achievementid"])
			end
		end
	},
	["fire"] = {
		Cat = "server",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["class"] = "func_button",
			["arg"] = "Use"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(ents.GetAll()) do
				if k:GetClass() == prop["class"] and k:GetPos() == prop["pos"] then
					k:Fire(prop["arg"])
				end
			end
		end
	},
	["setcookie"] = {
		Cat = "cookies",
		Prop = {
			["name"] = "do_intro",
			["value"] = ""
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			cookie.Set("impulse_em_"..prop["name"], prop["value"])
		end
	},
	["npc_spawn"] = {
		Cat = "npc",
		Prop = {
			["class"] = "npc_combine_s",
			["weapon"] = "",
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["cpsarefriendly"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			OPS_NPCS[uid] = ents.Create(prop["class"])
 			OPS_NPCS[uid]:SetPos(prop["pos"])
 			OPS_NPCS[uid]:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
 			OPS_NPCS[uid]:Spawn()
 			OPS_NPCS[uid]:Activate()

 			if prop["weapon"] != "" then
 				OPS_NPCS[uid]:Give(prop["weapon"])
 			end

 			if prop["cpsarefriendly"] then
 				for v,k in pairs(player.GetAll()) do
 					if k:IsCP() then
 						OPS_NPCS[uid]:AddEntityRelationship(k, D_LI, 99)
 					end
 				end
 			end
		end
	},
	["npc_remove"] = {
		Cat = "npc",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end
		end
	},
	["npc_sethp"] = {
		Cat = "npc",
		Prop = {
			["health"] = 100
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:SetHealth(prop["health"])
 			end
		end
	},
	["npc_movetopos"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0)
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:SetLastPosition(prop["pos"])
 				OPS_NPCS[uid]:SetSchedule(SCHED_FORCED_GO_RUN)
 			end
		end
	},
	["npc_movetotrack"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0)
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}
 			OPS_TRACKS = OPS_TRACKS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				local npc = OPS_NPCS[uid]

 				if OPS_TRACKS[uid] and IsValid(OPS_TRACKS[uid]) then
 					OPS_TRACKS[uid]:Remove()
 				end

 				OPS_TRACKS[uid] = ents.Create("path_track")
 				OPS_TRACKS[uid]:SetName(uid.."Track5555")
 				OPS_TRACKS[uid]:SetPos(prop["pos"])

 				npc:Fire("flytospecifictrackviapath", uid.."Track5555")
 			end
		end
	},
	["dropship_spawn"] = {
		Cat = "npc",
		Prop = {
			["start_pos"] = Vector(0, 0, 0),
			["start_ang"] = Vector(0, 0, 0),
			["second_pos"] = Vector(0, 0, 0),
			["land_pos"] = Vector(0, 0, 0),
			["god"] = true,
			["soldier_smg"] = 3,
			["soldier_ar2"] = 2,
			["soldier_shotgun"] = 1,
			["soldier_elite"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			local secondPos = prop["second_pos"]

 			if secondPos.x == 0 and secondPos.y == 0 and secondPos.z == 0 then
 				secondPos = nil
 			end

 			OPS_NPCS[uid] = MakeDropship(uid, prop["start_pos"], Angle(prop["start_ang"].x, prop["start_ang"].y, prop["start_ang"].z), secondPos, prop["land_pos"], prop["god"], prop["soldier_smg"], prop["soldier_ar2"], prop["soldier_shotgun"], prop["soldier_elite"])
		end
	},
	["dropship_remove"] = {
		Cat = "npc",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			if DROPSHIP_TROOPS[uid] then
 				for v,k in pairs(DROPSHIP_TROOPS[uid]) do
 					if IsValid(k) then
 						k:Remove()
 					end
 				end

 				DROPSHIP_TROOPS[uid] = nil
 			end
		end
	},
	["headcrabcanister"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(-20.139978, 28.500559, 0),
			["headcrabtype"] = 0,
			["count"] = 4,
			["speed"] = 3000,
			["time"] = 5,
			["damage"] = 50,
			["radius"] = 750,
			["duration"] = 30,
			["smoke"] = 0
 		},
 		NeedUID = true,
 		Clientside = false,
 		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			OPS_NPCS[uid] = MakeHeadcrabCanister(
 				"models/props_combine/headcrabcannister01b.mdl",
 				prop["pos"],
 				Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z),
 				nil,
 				nil,
 				nil,
 				nil,
 				prop["headcrabtype"],
 				prop["count"],
 				prop["speed"],
 				prop["time"],
 				nil,
 				prop["damage"],
 				prop["radius"],
 				prop["duration"],
 				nil,
 				prop["smoke"]
 			)

 			OPS_NPCS[uid]:Fire("FireCanister")
 		end
	},
	["citycodeset"] = {
		Cat = "server",
		Prop = {
			["code"] = 1
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			impulse.Dispatch.SetCityCode(prop["code"])
			impulse.Dispatch.SetupCityCode(prop["code"])
		end
	},
	["playscene"] = {
		Cat = "scene",
		Prop = {
			["scene"] = ""
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
		end
	}
}