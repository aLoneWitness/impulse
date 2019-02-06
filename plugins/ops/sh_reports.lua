impulse.Ops = impulse.Ops or {}
impulse.Ops.Reports = impulse.Ops.Reports or {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

if SERVER then
    file.CreateDir("impulse/ops")
    file.CreateDir("impulse/ops/reports")
end

local reportCommand = {
    description = "Sends (or updates) a report to the game moderators.",
    requiresArg = true,
    onRun = function(ply, arg, rawText)
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
                    reportId = reportId or table.insert(impulse.Ops.Reports, {ply, rawText, nil, os.time()})

                    k:AddChatText(newReportCol, "[NEW REPORT] [#"..reportId.."] ", ply:SteamName(), " (", ply:Name(), "):", rawText)
                    k:SurfacePlaySound("buttons/blip1.wav")
                end
            end
            if reportId then
                ply:Notify("Report submitted for review. Thank you for doing your part in keeping the community clean. Report ID: #"..reportId..".")
                return
            else
                ply:Notify("Unfortunatley, no game moderators are currently availble to review your report. Please goto impulse-community.com and submit a ban request.")
            end
        else
            local reportClaimant = impulse.Ops.Reports[reportId][3]

            if reportClaimant and IsValid(reportClaimant) then
                reportClaimant:AddChatText(claimedReportCol, "[REPORT UPDATE] [#"..reportId.."] ", ply:SteamName(), " (", ply:Name(), "):", rawText)
                reportClaimant:SurfacePlaySound("buttons/blip1.wav")
            else
                for v,k in pairs(player.GetAll()) do
                    if k:IsAdmin() then
                        k:AddChatText(newReportCol, "[REPORT UPDATE] [#"..reportId.."] ", ply:SteamName(), " (", ply:Name(), "):", rawText)
                        k:SurfacePlaySound("buttons/blip1.wav")
                    end
                end
            end

            impulse.Ops.Reports[reportId][2] = impulse.Ops.Reports[reportId][2].." +"..rawText

            ply:Notify("Your report has been updated. Thank you for keeping us informed. Report ID: #"..reportId..".")
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
            local reportStartTime = targetReport[4]

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

            impulse.Ops.Reports[reportId] = {reporter, reportMessage, ply, reportStartTime, os.time()}

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
            if reportClaimant then
                local fileName = "impulse/ops/reports/"..ply:SteamID64().."_"..os.date("%H-%M-%S_%d-%m-%Y", os.time())..".txt"
                local fileContent = "reporter: "..reporter:SteamID().."\r\nmod: "..reportClaimant:SteamID().."\r\nmessage: "..reportMessage.."\r\nreport open time: "..os.date("%H-%M-%S", targetReport[4]).."\r\nreport claim time: "..os.date("%H-%M-%S", targetReport[5]).."\r\nreport close time: "..os.date("%H-%M-%S", os.time())
                file.Write(fileName, fileContent)
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

impulse.RegisterChatCommand("/report", reportCommand)