local module = ... or D:module("PDTH++")
local PlayerStandard = module:hook_class("PlayerStandard")

module:hook(PlayerStandard, "_get_walk_speed_multiplier", function(self)
	local multiplier = 1

	if alive(self._equipped_unit) then
		local weapon_base = self._equipped_unit:base()
		local weapon_data = weapon_base:weapon_tweak_data()
		local is_shooting = weapon_base:_is_shooting()
		if weapon_data.movement_speed_multiplier then
			multiplier = multiplier * weapon_data.movement_speed_multiplier
			if is_shooting and weapon_data.movement_penalty_while_shooting then
				multiplier = multiplier * weapon_data.movement_speed_multiplier * 0.7
			end
		end
	end

	if managers.player:has_special_equipment("thick_skin") then
		multiplier = multiplier * 0.85
	end

	return multiplier
end)

module:hook(PlayerStandard, "_get_run_speed_multiplier", function(self)
	local multiplier = 1
	if alive(self._equipped_unit) then
		local weapon_base = self._equipped_unit:base()
		local weapon_data = weapon_base:weapon_tweak_data()
		local is_shooting = weapon_base:_is_shooting()
		if weapon_data.movement_speed_multiplier then
			multiplier = multiplier * weapon_data.movement_speed_multiplier
			-- players can't shoot while running, why are we checking this?
			if is_shooting and weapon_data.movement_penalty_while_shooting then
				multiplier = multiplier * weapon_data.movement_speed_multiplier * 0.7
			end
		end
	end

	if managers.player:has_special_equipment("thick_skin") then
		multiplier = multiplier * 0.9
	end

	return multiplier
end)

module:hook(PlayerStandard, "_get_max_walk_speed", function(self, t)
	local movement_speed = self._tweak_data.movement.speed

	local multiplier = self:_get_walk_speed_multiplier()
	if self._in_steelsight then
		return movement_speed.STEELSIGHT_MAX * multiplier
	end

	if self._ducking then
		return movement_speed.CROUCHING_MAX * multiplier
	end

	if self._in_air then
		return movement_speed.INAIR_MAX * multiplier
	end

	if self._running then
		return movement_speed.RUNNING_MAX * self:_get_run_speed_multiplier()
	end

	return movement_speed.STANDARD_MAX * multiplier
end)

module:pre_hook(PlayerStandard, "_enter", function(self)
	managers.upgrades:setup_current_weapon()
end)

function PlayerStandard:_stance_entered(unequipped)
	-- determine current weapon (if any)
	local weapon_id = nil
	if not unequipped and self._equipped_unit then
		weapon_id = self._equipped_unit:base():get_name_id()
	end

	local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default

	local head_stance
	if self._ducking then
		head_stance = tweak_data.player.stances.default.crouched.head
	else
		head_stance = tweak_data.player.stances.default.standard.head
	end

	local misc_attribs
	if self._in_steelsight and stances.steelsight then
		misc_attribs = stances.steelsight
	elseif self._ducking and stances.crouched then
		misc_attribs = stances.crouched
	else
		misc_attribs = stances.standard
	end

	local duration_multiplier = 1
	if self._in_steelsight and weapon_id then
		local ads_speed = tablex.get(tweak_data, "weapon", weapon_id, "ads_speed") or 1
		duration_multiplier = 1 / ads_speed
	end

	local new_fov
	local standard_fov = managers.user:get_setting("fov_standard")
	local zoom_fov = managers.user:get_setting("fov_zoom")
	if m308_fov_zoom == true and weapon_id == "m14" then
		if self._in_steelsight and stances.steelsight and stances.steelsight.zoom_fov then
			new_fov = zoom_fov and D:conf("m308_fov_zoom_set") or standard_fov
		else
			new_fov = standard_fov
		end
	else
		if self._in_steelsight and stances.steelsight and stances.steelsight.zoom_fov then
			new_fov = zoom_fov or standard_fov
		else
			new_fov = standard_fov
		end
	end

	self._camera_unit:base():clbk_stance_entered(
		misc_attribs.shoulders,
		head_stance,
		misc_attribs.vel_overshot,
		new_fov,
		misc_attribs.shakers,
		duration_multiplier
	)

	local sensitivity_zoom_fov = stances.steelsight and stances.steelsight.zoom_fov
	managers.menu:set_mouse_sensitivity(self._in_steelsight and sensitivity_zoom_fov)
end

--parts of script from B Dawg's Full Game overhaul.

--Added lines from Smart Weapon Switch.

module:hook(PlayerStandard, "_start_action_reload", function(self, t, dt)
	if not self._equipped_unit:base():can_reload() then
		return
	end

	local weapon_base = self._equipped_unit:base()
	weapon_base:tweak_data_anim_stop("fire")

	local speed_multiplier = weapon_base:reload_speed_multiplier()
	local tweak_data = weapon_base:weapon_tweak_data()
	local name_id = weapon_base.name_id

	local is_empty = weapon_base:clip_empty()
	local anim_suffix = is_empty and ("reload_" .. name_id) or ("reload_not_empty_" .. name_id)
	local camera_redirect = Idstring(anim_suffix)
	local reload_anim = is_empty and nil or "reload_not_empty"

	self._unit:camera():play_redirect(camera_redirect, speed_multiplier)

	local base_timer = nil
		if is_empty then
			base_timer = tweak_data.timers.reload_empty or weapon_base:reload_expire_t() or 2.6
		else
			base_timer = tweak_data.timers.reload_not_empty or weapon_base:reload_expire_t() or 2.2
		end

		self._reload_start_t = t
		self._reload_expire_t = t + (base_timer / speed_multiplier)

		weapon_base:start_reload()
		if not weapon_base:tweak_data_anim_play(reload_anim, speed_multiplier) then
			weapon_base:tweak_data_anim_play("reload", speed_multiplier)
		end

		if self._ext_network then
			self._ext_network:send("reload_weapon")
		end
end)

module:hook(PlayerStandard, "get_remaining_reload_time_percentage", function(self, t)
	local start_t = self._reload_start_t
	local expire_t = self._reload_expire_t
	if not expire_t then
		return 0
	end

	local progress
	if start_t and expire_t > start_t then
		progress = math.clamp((t - start_t) / (expire_t - start_t), 0, 1)		
	else
		if expire_t > t then
			progress = math.clamp(1 - ((expire_t - t) / expire_t), 0, 1)
		else
			progress = 1
		end
	end
				
	local remaining = math.clamp(1 - progress, 0, 1)
	return math.floor(remaining * 1000 + 0.5) / 10
end)

local WEAPON_EQUIPPED = "equipped"
local WEAPON_UNEQUIPPED = "unequipped"

module:hook(PlayerStandard, "show_weapon_switch_queue_hint", function(self)
	if not D:conf("sws_show_queue_hints") then
		return
	end

	local hint = "sws_hint_doubletap_to_force_switch"
	local weapon_id = self._equipped_unit:base():get_name_id()
	local is_shotgun = (weapon_id == "r870_shotgun" or weapon_id == "mossberg")
	if D:conf("sws_force_switch_after_loading_shell") and is_shotgun then
		hint = "sws_hint_switching_after_shell_load"
	end

	managers.hud:show_hint({ text = managers.localization:text(hint), time = 3.5 })
end)

module:hook(PlayerStandard, "_should_force_switch", function(self, t, input_index)
	local last_index = self._queued_reload_switch_index
	local last_time = self._queued_reload_switch_t or 0
	local delay = t - last_time

	local min_reload_remaining_pct = D:conf("sws_min_reload_remaining_pct")
	local reload_time_check = self:get_remaining_reload_time_percentage(t) > min_reload_remaining_pct

	return (last_index == input_index and delay < 0.35) or reload_time_check
end)

module:hook(PlayerStandard, "_consume_queued_switch", function(self)
	self._selection_wanted = true
	self._wanted_index = self._queued_reload_switch_index
	self._queued_reload_switch_index = nil
	self._queued_reload_switch_t = nil
end)

module:hook(PlayerStandard, "_check_action_equip", function(self, t, input)
	if self._switch_after_shell then
		local selection_wanted = self._switch_after_shell
		self._switch_after_shell = nil

		if self._ext_inventory:is_selection_available(selection_wanted) then
			self:_start_action_unequip_weapon(t, { selection_wanted = selection_wanted })
			self._selection_wanted = false
			self._wanted_index = nil
			self._queued_reload_switch_index = nil
			self._queued_reload_switch_t = nil
			return true
		end
	end

	local new_action

	local input_index = input.btn_primary_choice
	local pending_index = self._wanted_index
	local queued_index = self._queued_reload_switch_index
	local is_reloading = not self._reload_exit_expire_t and self:_is_reloading()

	local selection_wanted = input_index or pending_index or queued_index
	if not selection_wanted or not self._ext_inventory:is_selection_available(selection_wanted) then
		return new_action
	end

	local is_equipped = self._ext_inventory:is_equipped(selection_wanted)

	if not is_reloading and queued_index then
		self:_consume_queued_switch()
	end

	if is_reloading and input_index and not is_equipped then
		if self:_should_force_switch(t, input_index) then
			self:_start_action_unequip_weapon(t, { selection_wanted = input_index })
			self._selection_wanted = false
			self._wanted_index = nil
			self._queued_reload_switch_index = nil
			self._queued_reload_switch_t = nil
			new_action = true
			return new_action
		else
			self:show_weapon_switch_queue_hint()
			self._queued_reload_switch_index = input_index
			self._queued_reload_switch_t = t
		end
	end

	local action_forbidden = self:chk_action_forbidden("equip")
		or self._melee_expire_t
		or self._use_item_expire_t
		or self._equip_weapon_expire_t
		or self:_interacting()
		or (is_reloading and not pending_index)

	if not action_forbidden then
		new_action = not is_equipped
		if new_action then
			self:_start_action_unequip_weapon(t, { selection_wanted = selection_wanted })
			self._selection_wanted = false
			self._wanted_index = nil
			self._queued_reload_switch_index = nil
			self._queued_reload_switch_t = nil
		end
	end

	return new_action
end)

module:hook(70, PlayerStandard, "_update_action_reload", function(self, t, dt, input)
	local equipped_unit_base, interupt = self._equipped_unit:base(), false

	if equipped_unit_base:update_reloading(t, dt, self._reload_expire_t - t) then
		managers.hud:set_ammo_amount(equipped_unit_base:ammo_info())

		if D:conf("sws_force_switch_after_loading_shell") and self._queued_reload_switch_index then
			local selection_wanted = self._queued_reload_switch_index
			if self._ext_inventory and self._ext_inventory:is_selection_available(selection_wanted) then
				self._switch_after_shell = selection_wanted
			end
		end

		if self._queue_reload_interupt then
			self._queue_reload_interupt = nil
			interupt = true
		end
	end

	if t >= self._reload_expire_t or interupt then
		self._reload_expire_t = nil
		if equipped_unit_base:reload_exit_expire_t() then
			local speed_multiplier = equipped_unit_base:reload_speed_multiplier()
			if equipped_unit_base:started_reload_empty() then
				self._reload_exit_expire_t = t
					+ equipped_unit_base:reload_exit_expire_t() / speed_multiplier
				self._unit:camera():play_redirect(self.IDS_RELOAD_EXIT, speed_multiplier)
				equipped_unit_base:tweak_data_anim_play("reload_exit", speed_multiplier)
			else
				self._reload_exit_expire_t = t
					+ equipped_unit_base:reload_not_empty_exit_expire_t() / speed_multiplier
				self._unit:camera():play_redirect(self.IDS_RELOAD_NOT_EMPTY_EXIT, speed_multiplier)
			end
		elseif self._equipped_unit then
			if not interupt then
				equipped_unit_base:on_reload()
			end
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(equipped_unit_base:ammo_info())
			if input.btn_steelsight_state then
				self._steelsight_wanted = true
			elseif
				self._run_by_default
				and self._running_wanted ~= false
					and not input.btn_run_state
					and not self:_is_reloading()
			then
				self._running_wanted = true
			end
		end
	end
end, false)

module:hook(PlayerStandard, "_queue_weapon_switch_during_reload", function(self, index)
	self._selection_wanted = true
	self._wanted_index = index
end)

module:hook(PlayerStandard, "_start_action_unequip_weapon", function(self, t, data)
	self._equipped_unit:base():tweak_data_anim_play("unequip")

	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._change_weapon_data = data

	self:_interupt_action_running(t)

	if not self._weapon_state or self._weapon_state == WEAPON_EQUIPPED then
		self._unequip_weapon_expire_t = t + (tweak_data.timers.unequip or 0.5)
		self._weapon_state = WEAPON_UNEQUIPPED
		self._unit:camera():play_redirect(self.IDS_UNEQUIP)
	end

	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
end)

module:post_hook(PlayerStandard, "_start_action_equip_weapon", function(self, t)
	self._weapon_state = WEAPON_EQUIPPED
end)