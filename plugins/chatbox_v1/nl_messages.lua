netstream.Hook("msg", function(client, text)
		if ((client.NextChat or 0) < CurTime() and text:find("%S")) then
			if hook.Run("PlayerSay", client, text) then
				client:Say(text, false)
			end
			client.NextChat = CurTime() + math.max(#text / 250, 0.4)
		end
end)

netstream.Hook("msgRedact", function(client, id)
	if not client:IsAdmin() then return end
	for v,k in pairs(player.GetAll()) do
		netstream.Start(k, "redactMsg", id)
	end
end)