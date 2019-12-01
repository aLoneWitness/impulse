hook.Add("SwiftAC.LogCheater", "opsSwiftACLog", function(plydata, reason)
	for v,k in pairs(player.GetAll()) do
		if k:IsAdmin() then
			k:AddChatText(Color(255, 0, 0), "[CHEAT DETECTION] "..plydata.Nick.." ("..plydata.SteamID..") detection info: "..reason)
		end
	end
end)