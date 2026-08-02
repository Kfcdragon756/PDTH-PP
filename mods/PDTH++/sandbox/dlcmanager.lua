--[[
PDTH++ 客户端协议标记注入。
复用原版加入请求必带的空格分隔 DLC 字符串追加 `pdthpp_protocol_N`，
因此即使其他模组替换了 ClientNetworkSession 的加入函数，只要仍调用 dlcs_string()，
PDTH++ 标记就会随请求发送。协议号只在网络格式真正不兼容时递增。
]]

local module = ... or D:module("PDTH++")
local GenericDLCManager = module:hook_class("GenericDLCManager")

-- PDTH++ multiplayer compatibility protocol.
-- Increase this only when network-facing PDTH++ behaviour becomes incompatible.
local PDTHPP_NETWORK_PROTOCOL = module:version()
local PDTHPP_PROTOCOL_TOKEN = "pdthpp_protocol_" .. tostring(PDTHPP_NETWORK_PROTOCOL)

-- 防止同一加入流程被多次处理时重复追加协议标记。
local function contains_token(value, wanted)
	for token in string.gmatch(value or "", "%S+") do
		if token == wanted then
			return true
		end
	end

	return false
end

-- The vanilla join request already sends a space-separated DLC string.
-- Append a PDTH++ protocol token there so this works with the original client
-- session as well as other mods which replace ClientNetworkSession:request_join_host.
-- 保留全部原版 DLC 标记，只在末尾追加 PDTH++ 协议标记。
module:hook(GenericDLCManager, "dlcs_string", function(self)
	local dlcs = module:call_orig(GenericDLCManager, "dlcs_string", self) or ""
	if contains_token(dlcs, PDTHPP_PROTOCOL_TOKEN) then
		return dlcs
	end

	if dlcs == "" then
		return PDTHPP_PROTOCOL_TOKEN
	end

	return dlcs .. " " .. PDTHPP_PROTOCOL_TOKEN
end, true)
