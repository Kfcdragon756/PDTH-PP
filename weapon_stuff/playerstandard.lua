local module = ... or D:module("PDTH++")
local PlayerStandard = module:hook_class("PlayerStandard")

module:hook(PlayerStandard, "_get_walk_speed_multiplier", function(self)
	local multiplier = 1

	if alive(self._equipped_unit) then
		local weapon_shooting = self._equipped_unit:base():_is_shooting()
		local weapon_tdata = self._equipped_unit:base():weapon_tweak_data()
		if weapon_tdata.movement_speed_multiplier then
			multiplier = multiplier * weapon_tdata.movement_speed_multiplier
			if weapon_tdata.lower_speed_on_shooting and weapon_shooting then 
				multiplier = multiplier * weapon_tdata.movement_speed_multiplier * 0.7
			end
		end
	end
	
	if managers.player._equipment.specials.thick_skin then
		multiplier = multiplier * 0.85
	end
	--detects if player has thick skin.
	return multiplier
end)

module:hook(PlayerStandard, "_get_run_speed_multiplier", function(self)
	local multiplier = 1

	if alive(self._equipped_unit) then
		local weapon_shooting = self._equipped_unit:base():_is_shooting()
		local weapon_tdata = self._equipped_unit:base():weapon_tweak_data()
		if weapon_tdata.movement_speed_multiplier then
			multiplier = multiplier * weapon_tdata.movement_speed_multiplier
			if weapon_tdata.lower_speed_on_shooting and weapon_shooting then 
				multiplier = multiplier * weapon_tdata.movement_speed_multiplier * 0.7
			end
		end
	end
	
	if managers.player._equipment.specials.thick_skin then
		multiplier = multiplier * 0.9
	end
--this detects if player has thick skin.
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
	local head_stance = self._ducking and tweak_data.player.stances.default.crouched.head
		or tweak_data.player.stances.default.standard.head
	local weapon_id
	if not unequipped then
		weapon_id = self._equipped_unit:base():get_name_id()
	end
	local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default
	local misc_attribs = self._in_steelsight and stances.steelsight
		or self._ducking and stances.crouched
		or stances.standard
	local duration_multiplier = 1
	if self._in_steelsight and weapon_id then
		duration_multiplier = 1 / (tablex.get(tweak_data, "weapon", weapon_id, "ads_speed") or 1)
	end

	local new_fov = self._in_steelsight and stances.steelsight.zoom_fov and managers.user:get_setting("fov_zoom")
		or managers.user:get_setting("fov_standard")
	if m308_fov_zoom == true and weapon_id == "m14" then
		new_fov = self._in_steelsight and stances.steelsight.zoom_fov and D:conf("m308_fov_zoom_set")
		or managers.user:get_setting("fov_standard")
	end
	self._camera_unit:base():clbk_stance_entered(
		misc_attribs.shoulders,
		head_stance,
		misc_attribs.vel_overshot,
		new_fov,
		misc_attribs.shakers,
		duration_multiplier
	)
	managers.menu:set_mouse_sensitivity(self._in_steelsight and stances.steelsight.zoom_fov)
end

--parts of script from B Dawg's Full Game overhaul.