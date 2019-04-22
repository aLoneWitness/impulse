impulse.DefineSetting("admin_onduty", {name="Moderator on duty (DO NOT LEAVE UNTICKED FOR A LONG TIME)", category="ops", type="tickbox", default=true})
impulse.DefineSetting("admin_contextoptions", {name="Context options enabled", category="ops", type="tickbox", default=false})
impulse.DefineSetting("admin_esp", {name="ESP enabled (SA only)", category="ops", type="tickbox", default=false})

if impulse.GetSetting("admin_onduty") == false then
	chat.AddText("WARNING: You are not on duty! You will not be able to view inbound reports!")
end