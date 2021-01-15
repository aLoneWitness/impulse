impulse.Ops.ST = impulse.Ops.ST or {}

util.AddNetworkString("impulseOpsSTOpenTool")
util.AddNetworkString("impulseOpsSTDoRefund")
util.AddNetworkString("impulseOpsSTDoOOCEnabled")
util.AddNetworkString("impulseOpsSTDoTeamLimit")
util.AddNetworkString("impulseOpsSTGetRefund")
util.AddNetworkString("impulseOpsSTOOCEnabled")
util.AddNetworkString("impulseOpsSTDoTeamLimit")
util.AddNetworkString("impulseOpsSTSendIACCase")
util.AddNetworkString("impulseOpsSTGetIACCase")

function impulse.Ops.ST.Open(ply)
	net.Start("impulseOpsSTOpenTool")
	net.Send(ply)
end