impulse.Ops.ST = impulse.Ops.ST or {}

util.AddNetworkString("impulseOpsSTOpenTool")
util.AddNetworkString("impulseOpsSTDoRefund")
util.AddNetworkString("impulseOpsSTGetRefund")

function impulse.Ops.ST.Open(ply)
	net.Start("impulseOpsSTOpenTool")
	net.Send(ply)
end

net.Receive("impulseOpsSTDoRefund", function(len, ply)
	if not ply:IsSuperAdmin() then
		if ply:GetUserGroup() != "communitymanager" then
			return
		end
	end

	local s64 = net.ReadString()
	local len = net.ReadUInt(32)
	local items = pon.decode(net.ReadData(len))
	local steamid = util.SteamIDFrom64(s64)

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
        local refundData = {}

        for v,k in pairs(items) do
        	if not impulse.Inventory.ItemsRef[v] then
        		continue
        	end

        	refundData[v] = k
        end

        impulse.Data.Write("SupportRefund_"..s64, refundData)

        ply:Notify("Issued support refund for user "..s64..".")
    end)

    query:Execute()
end)

function PLUGIN:PostInventorySetup(ply)
    impulse.Data.Read("SupportRefund_"..ply:SteamID64(), function(refundData)
        if not IsValid(ply) then
            return
        end
        
        for v,k in pairs(refundData) do
            if not impulse.Inventory.ItemsRef[v] then
                continue
            end
            
            for i=1,k do
               ply:GiveInventoryItem(v, INV_STORAGE) -- refund to storage 
            end
        end

        impulse.Data.Remove("SupportRefund_"..ply:SteamID64())

        local data = pon.encode(refundData)

        net.Start("impulseOpsSTGetRefund")
        net.WriteUInt(#data, 32)
        net.WriteData(data, #data)
        net.Send(ply)
    end)
end