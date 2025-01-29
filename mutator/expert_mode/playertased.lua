local module = ... or DorHUD:module("PDTH++")
local PlayerTased = module:hook_class("PlayerTased")

module:hook(PlayerTased, "enter", function(self, enter_data)
	PlayerTased.super.enter(self, enter_data)
	self._ids_tased_boost = Idstring("tased_boost")
	self._ids_tased = Idstring("tased")
	self:_start_action_tased(Application:time())
	self._fatal_delayed_clbk = "PlayerTased_fatal_delayed_clbk"
	managers.enemy:add_delayed_clbk(self._fatal_delayed_clbk, callback(self, self, "clbk_exit_to_fatal"), TimerManager:game():time() + tweak_data.player.damage.TASED_TIME)
	self._next_shock = 0.5
	self._taser_value = 1
	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")
	if Network:is_server() then
		self:_register_revive_SO()
	end
	self:_interupt_action_reload()
	self._rumble_electrified = managers.rumble:play("electrified")
end, false)