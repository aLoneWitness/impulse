impulse.Ops = impulse.Ops or {}
impulse.Ops.QuickTools = impulse.Ops.QuickTools or {}

function impulse.Ops.RegisterAction(command, cmdData, qtName, qtIcon, qtDo)
	impulse.RegisterChatCommand(command, cmdData)

	if qtName and qtDo then
		impulse.Ops.QuickTools[qtName] = {name = qtName, icon = qtIcon, onRun = qtDo}
	end
end