local module = ... or DorHUD:module("PDTH++")
local MenuCallbackHandler = module:hook_class("MenuCallbackHandler")
local imcompatible = {
	["zhouji"] = { "kaboom", "no_time_for_searching", "reelism_mode" },
	["no_time_for_searching"] = { "zhouji", "kaboom" },
	["kaboom"] = { "zhouji", "no_time_for_searching", "reelism_mode" },
}

local function check_mutator_conflictions()
	local active = function(m_id)
		return D.mutators:is_active(m_id, true)
	end
	for id, c_ids in pairs(imcompatible) do
		if active(id) then
			for _, c_id in pairs(c_ids) do
				if active(c_id) then
					return true
				end
			end
		end
	end
	return false
end

module:hook(MenuCallbackHandler, "lobby_start_the_game", function(self, ...)
	if check_mutator_conflictions() then
		managers.menu:show_mutaotor_conflictions()
		return
	end
	module:call_orig(MenuCallbackHandler, "lobby_start_the_game", self, ...)
end)
--Special thanks to Dorentuz` for tecnical support.
--Should be useless now due to Dorentuz` already made mutator confliction definitions, but this will still be there, just in case.