impulse.DefineSetting("admin_onduty", {name="Moderator on duty (DO NOT LEAVE UNTICKED FOR A LONG TIME)", category="ops", type="tickbox", default=true})
impulse.DefineSetting("admin_reportalpha", {name="Report menu fade alpha", category="ops", type="slider", default=130, minValue=0, maxValue=255})
impulse.DefineSetting("admin_esp", {name="ESP enabled (SA only)", category="ops", type="tickbox", default=false})

if impulse.GetSetting("admin_onduty") == false then
	chat.AddText("MOVE THIS TO THE MENU LOLOLOL")
end