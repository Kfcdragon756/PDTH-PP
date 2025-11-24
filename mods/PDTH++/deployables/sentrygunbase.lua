local module = ... or D:module("PDTH++")
local SentryGunBase = module:hook_class("SentryGunBase")

module:post_hook(SentryGunBase, "setup", function(self)
	self._interact_ext = self._unit:interaction()
	if self._interact_ext then
		self._interact_ext:set_active(true)
		return
	end
	local interaction = SentryGunInteractionExt:new(self._unit)
	if interaction then
		interaction:set_tweak_data("temp_interact_box")
		interaction:set_active(true)
	end
end)

module:hook("OnNetworkDataRecv", "OnNetworkDataRecv_Destroy_sentry", { "ModEvent", }, function(peer, data_type, data)
    if data.module == module:id() and data.event == "Destroy_sentry" then
		data.unit.base():destroy_sentry()
	end
end)

module:hook(SentryGunBase, "destroy_sentry", function(self)
	self._unit:sound_source():post_event("turret_spin_stop")
	self._unit:set_slot(0)	
end, false)