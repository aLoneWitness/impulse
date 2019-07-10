function meta:MakeAFK()
	self.AFKState = true

	local playercount = #player.GetAll()
	local maxcount = game.MaxPlayers()
	local limit = impulse.Config.AFKKickRatio * maxcount

	if playercount >= limit and not self:IsDonator() then
		self:Kick("You have been kicked for inactivity on a busy server. See you again soon!")
		return
	end

	self:Notify("As a result of inactivity, you have been marked as AFK. You may be demoted from your current team.")

	if not self:IsAdmin() and self:Team() != impulse.Config.DefaultTeam then
		self:SetTeam(impulse.Config.DefaultTeam, true)
	end
end

function meta:UnMakeAFK()
	self.AFKState = false
	self:Notify("You have returned from being AFK.")
end

function meta:IsAFK()
	return self.AFKState or false
end