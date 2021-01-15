impulse.Ops.ST = impulse.Ops.ST or {}

util.AddNetworkString("impulseOpsSTOpenTool")
util.AddNetworkString("impulseOpsSTDoRefund")
util.AddNetworkString("impulseOpsSTGetRefund")

function impulse.Ops.ST.Open(ply)
	net.Start("impulseOpsSTOpenTool")
	net.Send(ply)
end

net.Receive("impulseOpsSTDoRefund", function(len, ply)
	if true then
		return -- WIP
	end
	
	if not ply:IsSuperAdmin() then
		if ply:GetUserGroup() != "communitymanager" then
			return
		end
	end

	local s64 = net.ReadString()
	local len = net.ReadUInt(32)
	local items = pon.decode(net.ReadData(len))
	local steamid = util.SteamIDTo64(s64)

    local query = mysql:Select("impulse_players")
    query:Select("id")
    query:Where("steamid", steamid)
    query:Callback(function(result)
        if not IsValid(ply) then
            return
        end

        if not type(result) == "table" or #result == 0 then
            return ply:Notify("This Steam account has not joined the server yet or the SteamID is invalid.")
        end

        local impulseID = result[1].id

        for v,k in pairs(items) do
        	if not impulse.Inventory.ItemsRef[v] then
        		continue
        	end

        	impulse.Inventory.DBAddItem(impulseID, v)
        end

        if not impulse.Inventory.ItemsRef[item] then
            return ply:Notify("Item: "..item.." does not exist.")
        end

        if target and IsValid(target) then
            target:GiveInventoryItem(item)
            return ply:Notify("You have given "..target:Nick().." a "..item..".")
        end

        local impulseID = result[1].id


        impulse.Inventory.DBAddItem(impulseID, item, 2)
        ply:Notify("Offline player ("..steamid..") has been given a "..item..".")
    end)

    query:Execute()
end)