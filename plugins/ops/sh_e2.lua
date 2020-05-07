if not E2Lib then
	return
end

if SERVER then
	util.AddNetworkString("opsE2Viewer")
	util.AddNetworkString("opsE2ViewerRemove")

	net.Receive("opsE2ViewerRemove", function(len, ply)
		if not ply:IsAdmin() then
			return
		end

		local chip = net.ReadEntity()

		if not IsValid(chip) then
			return
		end

		if chip:GetClass() != "gmod_wire_expression2" then
			return
		end

		chip:Remove()
		ply:Notify("Expression chip removed.")
	end)
end

local e2ViewerCommand = {
    description = "Opens the E2 viewer tool.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        net.Start("opsE2Viewer")
        net.Send(ply)
    end
}

impulse.RegisterChatCommand("/e2viewer", e2ViewerCommand)

