impulse.Ops = impulse.Ops or {}
impulse.Ops.Reports = impulse.Ops.Reports or {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

local reportCommand = {
    description = "Sends a report to the game moderators.",
    requiresArg = true,
    onRun = function(ply, arg, rawText)
        if ply.nextReport and ply.nextReport > CurTime() then
            return ply:Notify("Please wait a while before submitting another report.")
        end

        local reportId = nil

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                reportId = reportId or table.insert(impulse.Ops.Reports, {ply, rawText})
                k:AddChatText(newReportCol, "[NEW REPORT] [#"..reportId.."] ", ply:SteamName(), " (", ply:Name(), "):", rawText)
                k:SurfacePlaySound("buttons/blip1.wav")
            end
        end
        if reportId then
            ply:Notify("Report submitted for review. Thank you for doing your part in keeping the community clean. Report ID: #"..reportId..".")
            ply.nextReport = CurTime() + 60
            return
        else
            ply:Notify("Unfortunatley, no game moderators are currently availble to review your report. Please goto impulse-community.com and submit a ban request.")
        end
        ply.nextReport = CurTime() + 2
    end
}

impulse.RegisterChatCommand("/report", reportCommand)

local claimReportCommand = {
    description = "Claims a report for review.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local reportId = tonumber(arg[1])
        local targetReport = impulse.Ops.Reports[reportId]

        if targetReport then
            local reporter = targetReport[1]
            local reportMessage = targetReport[2]
            local reportClaimant = targetReport[3]

            if targetReport[3] and IsValid(targetReport[3]) then
                return ply:AddChatText(newReportCol, "Report #"..reportId.." has already been claimed by "..targetReport[3]:SteamName())
            end

            if not IsValid(reporter) then
                impulse.Ops.Reports[reportId] = nil
                return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Report closed.")
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

            impulse.Ops.Reports[reportId] = {reporter, reportMessage, ply}

            for v,k in pairs(player.GetAll()) do
                if k:IsAdmin() and k == ply then
                    k:AddChatText(claimedReportCol, "[REPORT] [#"..reportId.."] claimed by "..ply:SteamName())
                elseif k:IsAdmin() then
                    k:AddChatText(newReportCol, "[REPORT] [#"..reportId.."] claimed by "..ply:SteamName())
                end
            end

            reporter:Notify("Your report has been claimed for review by a game moderator ("..ply:SteamName()..").")
        else
            ply:AddChatText(claimedReportCol, "Report #"..arg[1].." does not exist.")
        end
    end
}

impulse.RegisterChatCommand("/rc", claimReportCommand)

local closeReportCommand = {
    description = "Closes a report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
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
                impulse.Ops.Reports[reportId] = nil
                return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Report closed.")
            end

            impulse.Ops.Reports[reportId] = nil
            ply:AddChatText(claimedReportCol, "[REPORT] [#"..reportId.."] closed by "..ply:SteamName())
            reporter:Notify("Your report has been closed by a game moderator ("..ply:SteamName().."). We hope we have managed to resolve your issue.")
        else
            ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
        end
    end
}

impulse.RegisterChatCommand("/rcl", closeReportCommand)

local viewReportsCommand = {
    description = "Displays the statuses of all reports in the system.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local claimant

        for id, data in pairs(impulse.Ops.Reports) do
            claimant = "unclaimed"

            if IsValid(data[1]) then
                if data[3] and IsValid(data[3]) then
                    claimant = data[3]:SteamName()
                end
                ply:AddChatText(newReportCol, "["..id.."] reporter: "..data[1]:Name().." | message: "..data[2].." | claimant: "..claimant)
            else
                impulse.Ops.Reports[id] = nil
            end
        end
    end
}

impulse.RegisterChatCommand("/rv", viewReportsCommand)