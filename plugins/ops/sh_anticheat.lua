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