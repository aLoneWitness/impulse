impulse.ops.NewAction("goto", function(player,args,foundtable)
    local TO_GOTO = foundtable[1] or return 
    
    if player:GetMoveType() == MOVETYPE_NOCLIP then
    	player:SetPos( TO_GOTO:GetPos() + TO_GOTO:GetForward() * 50 )
    	return
    end
    if player:InVehicle() then
    	player:ExitVehicle()
    end
    if !player:Alive() then
    	--ply:ChatAdd("You must be alive to goto!" )
    	return
    end
    
    local pos = {}
    for i = 1, 360 do table.insert( pos, TO_GOTO:GetPos() + Vector( math.sin( i ) * 50, math.cos( i ) * 50, 37 ) ) end
    table.insert( pos, TO_GOTO:GetPos() + Vector( 0, 0, 112 ) )
    
    for k,v in pairs( pos ) do
    	local trace = {}
    	trace.start = v
    	trace.endpos = v 
    	trace.mins = Vector( -25, -25, -37 )
    	trace.maxs = Vector( 25, 25, 37 )
    	local hull = util.TraceHull( trace )
    
    	if !hull.Hit then
    		player:SetPos( v - Vector( 0, 0, 37 ) )
    		player:SetLocalVelocity( Vector( 0, 0, 0 ) )
    		player:SetEyeAngles( ( TO_GOTO:GetShootPos() - player:GetShootPos() ):Angle() )
    		return
    	end
    end
end)