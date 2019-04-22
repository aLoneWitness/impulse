net.Receive("opsReportMessage", function()
	local reportId = net.ReadUInt(16)
	local msgId = net.ReadUInt(4)

	if msgId == 1 then
		LocalPlayer():Notify("Report submitted for review. Thank you for doing your part in keeping the community clean. Report ID: #"..reportId..".")
        LocalPlayer():Notify("If you have any further requests or info for us, just send another report.")
    elseif msgId == 2 then
    	LocalPlayer():Notify("Your report has been updated. Thank you for keeping us informed. Report ID: #"..reportId..".")
    elseif msgId == 3 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been claimed for review by a game moderator ("..claimer:SteamName()..").")
    	end
    elseif msgId == 4 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been closed by a game moderator ("..claimer:SteamName().."). We hope we have managed to resolve your issue.")
    	end
	end
end)

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

net.Receive("opsNewReport", function()
	local sender = net.ReadEntity()
	local reportId = net.ReadUInt(16)
	local message = net.ReadString()

	if not IsValid(sender) then return end
	if impulse.GetSetting("admin_onduty") == false then return end

	chat.AddText(newReportCol, "[NEW REPORT] [#"..reportId.."] ", sender:SteamName(), " (", sender:Name(), "): ", message)
    surface.PlaySound("buttons/blip1.wav")

    impulse.Ops.Reports[reportId] = {sender, message}
end)

net.Receive("opsReportUpdate", function()
	local sender = net.ReadEntity()
	local reportId = net.ReadUInt(16)
	local message = net.ReadString()

	if not IsValid(sender) then return end
	if impulse.GetSetting("admin_onduty") == false then return end

	if impulse.Ops.Reports[reportId] and impulse.Ops.Reports[reportId][3] and impulse.Ops.Reports[reportId][3] == LocalPlayer() then
		chat.AddText(claimedReportCol, "[REPORT UPDATE] [#"..reportId.."] ", sender:SteamName(), " (", sender:Name(), "): ", message)
        surface.PlaySound("buttons/blip1.wav")
    else
    	chat.AddText(newReportCol, "[REPORT UPDATE] [#"..reportId.."] ", sender:SteamName(), " (", sender:Name(), "): ", message)
        surface.PlaySound("buttons/blip1.wav")
	end

	if impulse.Ops.Reports[reportId] then
		impulse.Ops.Reports[reportId][2] = impulse.Ops.Reports[reportId][2].." + "..message
	end
end)

net.Receive("opsReportClaimed", function()
	local claimer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(claimer) then return end
	if impulse.GetSetting("admin_onduty") == false then return end

	if LocalPlayer() == claimer then
		chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:SteamName())
	else
		chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:SteamName())
	end

	if impulse.Ops.Reports[reportId] then
		impulse.Ops.Reports[reportId][3] = claimer
	end
end)

net.Receive("opsReportClosed", function()
	local closer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(closer) then return end
	if impulse.GetSetting("admin_onduty") == false then return end

	chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] closed by "..closer:SteamName())
	impulse.Ops.Reports[reportId] = nil
end)