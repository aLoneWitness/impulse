local color_white = Color(245,245,245)

net.Receive('plogs.Console', function()
	local id 	= net.ReadString()
	local str 	= net.ReadString()

	local log = plogs.types[id]
	if log then
		MsgC(log.Color, '[' .. id .. ' | ' .. os.date('%I:%M:%S', os.time()) ..  ']', color_white, str .. '\n')
	end
end)