function meta:MakeAFK()
	self.AFKState = true

	local playercount = #player.GetAll()
	local maxcount = game.MaxPlayers()
	local limit = impulse.Config.AFKKickRatio * maxcount

	if playercount >= limit then
		self:Kick("You have been kicked for inactivity on a busy server. See you again soon!")
		return
	end

	self:Notify("As a result of inactivity, you have been marked as AFK. You may be demoted from your current team.")
	self:SetTeam(impulse.Config.DefaultTeam, true)
end

function meta:UnMakeAFK()
	self.AFKState = false
	self:Notify("You have returned from being AFK.")
end

function meta:IsAFK()
	return self.AFKState or false
end