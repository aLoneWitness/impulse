impulse.Ops = impulse.Ops or {}
impulse.Ops.Reports = impulse.Ops.Reports or {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

file.CreateDir("impulse/ops")
file.CreateDir("impulse/ops/reports")

util.AddNetworkString("opsNewReport")
util.AddNetworkString("opsReportMessage")
util.AddNetworkString("opsReportUpdate")
util.AddNetworkString("opsReportClaimed")
util.AddNetworkString("opsReportClosed")


function impulse.Ops.ReportNew(ply, arg, rawText)
	if ply.nextReport and ply.nextReport > CurTime() then
        return 
    end

    local reportId

    local hasActiveReport = false
    for id, data in pairs(impulse.Ops.Reports) do
        if data[1] == ply then
            hasActiveReport = true
            reportId = id
            break
        end
    end

    if hasActiveReport == false then
        reportId = nil

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                reportId = reportId or table.insert(impulse.Ops.Reports, {ply, rawText, nil, CurTime()})

                net.Start("opsNewReport")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end
        if reportId then
            net.Start("opsReportMessage")
            net.WriteUInt(reportId, 16)
            net.WriteUInt(1, 4)
            net.Send(ply)

            opsDiscordLog(":warning: **[NEW REPORT]** [#"..reportId.."] ".. ply:SteamName().. " (".. ply:Name().. ") ("..ply:SteamID().."): ```"..rawText.."```")
            return
        else
            ply:Notify("Unfortunatley, no game moderators are currently availble to review your report. Please goto impulse-community.com and submit a ban request.")
        end
    else
        local reportClaimant = impulse.Ops.Reports[reportId][3]

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportUpdate")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end

        impulse.Ops.Reports[reportId][2] = impulse.Ops.Reports[reportId][2].." + "..rawText
        opsDiscordLog(":speech_left: **[REPORT UPDATE]** [#"..reportId.."] ".. ply:SteamName().. " (".. ply:Name().. ") ("..ply:SteamID().."): ```".. rawText.."```")

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(2, 4)
        net.Send(ply)
    end
    ply.nextReport = CurTime() + 2
end

function impulse.Ops.ReportClaim(ply, arg, rawText)
    local reportId = tonumber(arg[1])
    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]
        local reportStartTime = targetReport[4]

        if targetReport[3] and IsValid(targetReport[3]) then
            return ply:AddChatText(newReportCol, "Report #"..reportId.." has already been claimed by "..targetReport[3]:SteamName())
        end

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        local hasClaimedReport

        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                hasClaimedReport = id
                break
            end
        end

        if hasClaimedReport then
            return ply:AddChatText(newReportCol, "You already have a claimed report in progress. Current report #"..hasClaimedReport)
        end

        impulse.Ops.Reports[reportId] = {reporter, reportMessage, ply, reportStartTime, CurTime()}

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportClaimed")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.Send(k)
            end
        end
        opsDiscordLog(":passport_control: **[REPORT CLAIMED]** [#"..reportId.."] claimed by "..ply:SteamName().." ("..ply:SteamID()..")")

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(3, 4)
        net.WriteEntity(ply)
        net.Send(reporter)
    else
        ply:AddChatText(claimedReportCol, "Report #"..arg[1].." does not exist.")
    end
end

function impulse.Ops.ReportClose(ply, arg, rawText)
   local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report or specify a report ID before closing it.")
    end

    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        if reportClaimant then
        	local query = mysql:Insert("impulse_reports")
			query:Insert("reporter", reporter:SteamID())
			query:Insert("mod", reportClaimant:SteamID())
			query:Insert("message", string.sub(reportMessage, 1, 650))
			query:Insert("start", os.date("%Y-%m-%d %H:%M:%S", os.time()))
			query:Insert("claimwait", targetReport[5] - targetReport[4])
			query:Insert("closewait", CurTime() - targetReport[4])
			query:Execute(true)
        end

        impulse.Ops.Reports[reportId] = nil

        for v,k in pairs(player.GetAll()) do
        	if k:IsAdmin() then
		        net.Start("opsReportClosed")
		        net.WriteEntity(ply)
		        net.WriteUInt(reportId, 16)
		        net.Send(k)
		    end
	    end

        opsDiscordLog(":closed_book: **[REPORT CLOSED]** [#"..reportId.."] closed by "..ply:SteamName().." ("..ply:SteamID()..")")

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(4, 4)
        net.WriteEntity(ply)
        net.Send(reporter)
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end

function impulse.Ops.ReportGoto(ply, arg, rawText)
    local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report to use this command.")
    end

    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end
        
        opsGoto(ply, reporter:GetPos())
        ply:Notify("You have teleported to "..reporter:Nick()..".")
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end