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

module:post_hook(SentryGunBase, "set_server_information", function(self)
	--self._interact_ext = self._unit:interaction()
	if self._interact_ext then
		self._interact_ext:_set_contour("standard_color", 1)
	end
end)

module:hook(SentryGunBase, "destroy_sentry", function(self)
	unit:sound():play("pickup_ammo")
	if not Network:is_server() then	
		managers.network:session():send_to_peers_synched("sync_sentry_destroy", self._unit)
	end
	self._unit:sound_source():post_event("turret_spin_stop")
	--self._unit:brain():set_active(false)
	self._unit:damage():destroy(self._unit)
	self._unit:movement():set_active(false)
	self._unit:base():on_death()
	--managers.groupai:state():on_criminal_neutralized(self._unit)
	if self._interact_ext then
		self._interact_ext:set_active(false)
	end
	self._unit:base():remove()
	World:delete_unit(self._unit)
	--self._unit:set_slot(0)	
end, false)

module:hook(SentryGunBase, "sync_destroy", function(self)
	self._unit:sound_source():post_event("turret_spin_stop")
	--self._unit:brain():set_active(false)
	self._unit:damage():destroy(self._unit)
	self._unit:movement():set_active(false)
	self._unit:base():on_death()
	--managers.groupai:state():on_criminal_neutralized(self._unit)
	if self._interact_ext then
		self._interact_ext:set_active(false)
	end
	self._unit:base():remove()
	World:delete_unit(self._unit)
	--self._unit:set_slot(0)	
end, false)