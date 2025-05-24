--unused
local module = ... or D:module("PDTH++")
local SentryGunMovement = module:hook_class("SentryGunMovement")

module:hook(SentryGunMovement, "stop_sound_on_pickup", function(self,sentrygun_unit)
	
	self._sound_source = sentrygun_unit:sound_source()
	self._sound_source:post_event("turret_spin_stop")
	self._motor_sound:stop()
	self._motor_sound = false
end)