local managerCommand = {
    description = "Opens the support tool.",
    leadAdminOnly = true,
    onRun = function(ply)
    	if ply:GetUserGroup() == "communitymanager" or ply:IsSuperAdmin() then
    		impulse.Ops.ST.Open(ply)
    	end
    end
}

impulse.RegisterChatCommand("/supporttool", managerCommand)

if CLIENT then
	net.Receive("impulseOpsSTOpenTool", function()
		vgui.Create("impulseStaffManager")
	end)
end