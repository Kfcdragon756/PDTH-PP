local module = ... or D:module("PDTH++")
local UnitNetworkHandler = module:hook_class("UnitNetworkHandler")

module:hook(UnitNetworkHandler, "sync_sentry_destroy", function(unit, sender)
    if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
    unit:base():sync_destroy()
end, false)