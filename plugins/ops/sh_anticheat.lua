if SERVER then
	util.AddNetworkString("opsUnderInvestigation")
end

hook.Add("SwiftAC.LogCheater", "opsSwiftACLog", function(plydata, reason)
	for v,k in pairs(player.GetAll()) do
		if k:IsAdmin() then
			k:AddChatText(Color(255, 0, 0), "[CHEAT DETECTION] "..plydata.Nick.." ("..plydata.SteamID..") detection info: "..reason)
		end
	end

	local ply = player.GetBySteamID(plydata.SteamID)

	if ply and IsValid(ply) then
		net.Start("opsUnderInvestigation")
		net.Send(ply)
	end
end)

hook.Add("Simplac.PlayerViolation", "opsSimpLACLog", function(ply, ident, violation)
	for v,k in pairs(player.GetAll()) do
		if k:IsAdmin() then
			k:AddChatText(Color(255, 0, 0), "[CHEAT VIOLATION] "..ply:Nick().." ("..ply:SteamID()..") violation info: "..violation)
		end
	end

	net.Start("opsUnderInvestigation")
	net.Send(ply)
end)

hook.Add("iac.CheaterConvicted", "iacCheaterLog", function(steamid, code)
	for v,k in pairs(player.GetAll()) do
		if k:IsAdmin() then
			k:AddChatText(Color(255, 0, 0), "[IAC CONVICTION] "..steamid.." code: "..code)
		end
	end
end)

if iac then
	local iacFlagCommand = {
	    description = "Flags a player for review by an IAC engineer.",
	    requiresArg = true,
	    adminOnly = true,
	    onRun = function(ply, arg, rawText)
	    	if true then
	    		return ply:Notify("This feature has been disabled for now.")
	    	end
	    	
	    	if (ply.iacFlagCool or 0) > CurTime() then
	    		return ply:Notify("Wait a while before doing more of this...")
	  		end
	  		ply.iacFlagCool = CurTime() + 12
	  		
	        local name = arg[1]
			local plyTarget = impulse.FindPlayer(name)

			if plyTarget and plyTarget.impulseData then
				plyTarget:FlagUser()
				ply:Notify("Flagged "..plyTarget:Nick().." for review by an IAC engineer. Please contact your IAC engineer regarding your flag.")
			else
				return ply:Notify("Could not find player: "..tostring(name))
			end
	    end
	}

	impulse.RegisterChatCommand("/iacflag", iacFlagCommand)
end