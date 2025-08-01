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
