impulse.Ops = impulse.Ops or {}
impulse.Ops.Reports = impulse.Ops.Reports or {}
impulse.Ops.Log = impulse.Ops.Log or {}

function impulse.Ops.NewLog(msg, isMe)
	table.insert(impulse.Ops.Log, {
		message = msg,
		isMe = isMe or false,
		time = CurTime()
	})

	if not isMe then
		OPS_LASTMSG_CLOSE = false
	end
end

local uniqueReportKey = 0
net.Receive("opsReportMessage", function()
	local reportId = net.ReadUInt(16)
	local msgId = net.ReadUInt(4)

	if msgId == 1 then
		LocalPlayer():Notify("Report submitted for review. Thank you for doing your part in keeping the community clean. Report ID: #"..reportId..".")
        LocalPlayer():Notify("If you have any further requests or info for us, just send another report by pressing F3.")

        impulse.Ops.NewLog({Color(50, 205, 50), "(#"..reportId..") Report submitted", color_white, " message: "..(impulse_reportMessage or "")}, true)
        impulse.Ops.CurReport = reportId
        uniqueReportKey = uniqueReportKey + 1

        local urkCopy = uniqueReportKey + 0
        timer.Simple(360, function()
        	if impulse.Ops.CurReport and urkCopy == uniqueReportKey and not impulse.Ops.CurReportClaimed then
        		LocalPlayer():Notify("Apologies for the delay in processing your report. We will resolve your report as soon as possible.")
        		impulse.Ops.NewLog({"(#"..reportId..") Apologies for the delay in processing your report. We will resolve your report as soon as possible"}, false)

        		if impulse_userReportMenu and IsValid(impulse_userReportMenu) then
					impulse_userReportMenu:SetupUI()
				end
        	end
        end)

        timer.Simple(1, function()
        	if impulse.Ops.CurReport then
        		impulse.Ops.DaleRead(impulse_reportMessage or "")
        	end
        end)
    elseif msgId == 2 then
    	LocalPlayer():Notify("Your report has been updated. Thank you for keeping us informed. Report ID: #"..reportId..".")
    	impulse.Ops.NewLog({"(#"..reportId..") Report updated: "..impulse_reportMessage or ""}, true)

        timer.Simple(1, function()
        	if impulse.Ops.CurReport then
        		impulse.Ops.DaleRead(impulse_reportMessage or "")
        	end
        end)
    elseif msgId == 3 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been claimed for review by a game moderator ("..claimer:SteamName()..").")
    		impulse.Ops.NewLog({Color(255, 140, 0), "(#"..reportId..") Report claimed for review by a game moderator ("..claimer:SteamName()..") and currently under review"}, false)
    	end

    	impulse.Ops.CurReportClaimed = true
    elseif msgId == 4 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been closed by a game moderator ("..claimer:SteamName().."). We hope we have managed to resolve your issue.")
    		impulse.Ops.NewLog({Color(240, 0, 0), "(#"..reportId..") Report closed by a game moderator ("..claimer:SteamName()..")"}, false)
    	else
    		impulse.Ops.NewLog({Color(240, 0, 0), "(#"..reportId..") Report closed by a game moderator"}, false)
    	end

    	impulse.Ops.CurReport = nil
    	impulse.Ops.CurReportClaimed = nil
	end

	if impulse_userReportMenu and IsValid(impulse_userReportMenu) then
		impulse_userReportMenu:SetupUI()
	end
end)

net.Receive("opsReportAdminMessage", function()
	local claimer = net.ReadEntity()
	local msg = net.ReadString()

	if IsValid(claimer) and impulse.Ops.CurReport then
		LocalPlayer():Notify("A game moderator has replied to your report. Press F3 to view it.")
		impulse.Ops.NewLog({"(#"..impulse.Ops.CurReport..") ", "Game moderator reply", " ("..claimer:SteamName().."): ", color_white, msg}, false)

		if impulse_userReportMenu and IsValid(impulse_userReportMenu) then
			impulse_userReportMenu:SetupUI()
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

	if impulse.GetSetting("admin_onduty") then
		chat.AddText(newReportCol, "[NEW REPORT] [#"..reportId.."] ", sender:SteamName(), " (", sender:Name(), "): ", message)
	    surface.PlaySound("buttons/blip1.wav")
	end

    impulse.Ops.Reports[reportId] = {sender, message}

    if impulse_reportMenu and IsValid(impulse_reportMenu) then
    	impulse_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportUpdate", function()
	local sender = net.ReadEntity()
	local reportId = net.ReadUInt(16)
	local message = net.ReadString()

	if not IsValid(sender) then return end

	if impulse.GetSetting("admin_onduty") then
		if impulse.Ops.Reports[reportId] and impulse.Ops.Reports[reportId][3] and impulse.Ops.Reports[reportId][3] == LocalPlayer() then
			chat.AddText(claimedReportCol, "[REPORT UPDATE] [#"..reportId.."] ", sender:SteamName(), " (", sender:Name(), "): ", message)
	        surface.PlaySound("buttons/blip1.wav")
		end
	end

	if impulse.Ops.Reports and impulse.Ops.Reports[reportId] then
		impulse.Ops.Reports[reportId][2] = impulse.Ops.Reports[reportId][2].." + "..message
	end
end)

net.Receive("opsReportClaimed", function()
	local claimer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(claimer) then return end

	if impulse.GetSetting("admin_onduty") then
		if LocalPlayer() == claimer then
			chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:SteamName())
		else
			chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:SteamName())
		end
	end

	if impulse.Ops.Reports and impulse.Ops.Reports[reportId] then
		impulse.Ops.Reports[reportId][3] = claimer
	end

    if impulse_reportMenu and IsValid(impulse_reportMenu) then
    	impulse_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportClosed", function()
	local closer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(closer) or closer == Entity(0) then
		if impulse.Ops.Reports and impulse.Ops.Reports[reportId] and (not impulse.Ops.Reports[reportId][3] or not IsValid(impulse.Ops.Reports[reportId][3])) then
			chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] closed by Dale")
		end
	else
		if impulse.GetSetting("admin_onduty") then
			if impulse.Ops.Reports and impulse.Ops.Reports[reportId] and (not impulse.Ops.Reports[reportId][3] or not IsValid(impulse.Ops.Reports[reportId][3])) then
				chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] closed by "..closer:SteamName())
			elseif LocalPlayer() and LocalPlayer() == closer then
				chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] closed by "..closer:SteamName())
			end
		end
	end

	impulse.Ops.Reports[reportId] = nil

    if impulse_reportMenu and IsValid(impulse_reportMenu) then
    	impulse_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportDaleReplied", function()
	local reportId = net.ReadUInt(8)

	if impulse.Ops.Reports and impulse.Ops.Reports[reportId] then
		impulse.Ops.Reports[reportId][4] = true
	end

    if impulse_reportMenu and IsValid(impulse_reportMenu) then
    	impulse_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportSync", function()
	impulse.Ops.Reports = net.ReadTable() or {}
end)