local module = ... or D:module("PDTH++")
local PlayerTased = module:hook_class("PlayerTased")

function PlayerTased:_update_check_actions(t, dt)
	local input = self:_get_input()
	if t > self._next_shock then
		self._next_shock = t + 0.25 + math.rand(1)
		self._unit:camera():play_shaker("player_taser_shock", 1, 10)
		self._camera_unit:base():start_shooting()
		self._recoil_t = t + 0.5
		self._camera_unit:base():recoil_kick(-1.75, 5)
		input.btn_primary_attack_state = true
		input.btn_primary_attack_press = true
		self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))
		self._taser_value = math.max(self._taser_value - 0.25, 0)
		self._unit:sound():play("tasered_shock")
		self._unit:camera():play_redirect(self._ids_tased_boost)
		managers.rumble:play("electric_shock")
	elseif self._recoil_t then
		input.btn_primary_attack_state = true
		if t > self._recoil_t then
			self._recoil_t = nil
			self._camera_unit:base():stop_shooting()
		end
	end
	self._taser_value = math.step(self._taser_value, 0.8, dt / 4)
	managers.environment_controller:set_taser_value(self._taser_value)
	self._shooting = self:_check_action_primary_attack(t, input)
	if self._shooting then
		self._camera_unit:base():recoil_kick(0, 8)
	end
	if self._unequip_weapon_expire_t and t >= self._unequip_weapon_expire_t then
		self._unequip_weapon_expire_t = nil
		self:_start_action_equip_weapon(t)
	end
	if self._equip_weapon_expire_t and t >= self._equip_weapon_expire_t then
		self._equip_weapon_expire_t = nil
	end
	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end
	self:_update_foley(t, input)
	local new_action
	if not new_action then
	end
	self:_check_action_interact(t, input)
	local new_action
	new_action = new_action or self:_check_set_upgrade(t, input)
end