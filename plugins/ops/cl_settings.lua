impulse.DefineSetting("admin_onduty", {name="Moderator on duty (DO NOT LEAVE UNTICKED FOR A LONG TIME)", category="ops", type="tickbox", default=true})
impulse.DefineSetting("admin_reportalpha", {name="Report menu fade alpha", category="ops", type="slider", default=130, minValue=0, maxValue=255})
impulse.DefineSetting("admin_esp", {name="ESP enabled", category="ops", type="tickbox", default=false})

hook.Add("DisplayMenuMessages", "opsOffDutyWarn", function()
	if impulse.GetSetting("admin_onduty", true) == false and LocalPlayer():IsAdmin() then
		Derma_Message("You are currently off-duty. This is a reminder to ensure you return to duty as soon as possible.\nTo return to duty, goto settings, ops and tick the on duty box.", "ops", "Continue")
	end
end)