local module = ... or D:module("PDTH++")

local next_allowed_tie_t = -100
local cannot_tie = function()
	-- You cannot tie yourself if you don't have the skill.
	if not managers.player:has_special_equipment("extra_cable_tie") then
		return true
	end

	-- Check for active cooldown to prevent spam
	if TimerManager:game():time() < next_allowed_tie_t then
		return true
	end

	return false
end

module:hook("OnKeyPressed", "tie_yourself", nil, "GAME", function()
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	if cannot_tie() then
		return
	end

	local state_name = player_unit:movement():current_state_name()
	if state_name == "arrested" then
		managers.player:set_player_state("standard")
		return
	end

	if state_name ~= "standard" then
		return
	end

	local cable_tie_data = managers.player:has_special_equipment("cable_tie")
	if (tablex.get(cable_tie_data, "amount") or 0) <= 0 then
		return
	end

	managers.player:remove_special("cable_tie")
	player_unit:movement():on_disarmed()

	next_allowed_tie_t = TimerManager:game():time() + 0.5
end)

-- global toggle for other code to read
m308_fov_zoom = false

module:hook("OnKeyPressed", "change_308_fov_zoom", nil, "GAME", function(self)
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	local inv = player_unit:inventory()
	local equipped = inv and inv:equipped_unit()
	if not equipped then
		return
	end

	local name = equipped:base()._name_id
	if name ~= "m14" then
		return
	end

	-- play dryfire sound
	local weapon_data = tweak_data.weapon[name]
	if equipped:base()._sound_fire and weapon_data and weapon_data.sounds and weapon_data.sounds.dryfire then
		equipped:base()._sound_fire:post_event(weapon_data.sounds.dryfire)
	end

	local plr_state = player_unit:movement():current_state()
	if not plr_state then
		return
	end

	local in_steelsight = plr_state._in_steelsight
	local ducking = plr_state._ducking
	local stance_key = in_steelsight and "steelsight" or ducking and "crouched" or "standard"

	local stances = tweak_data.player.stances[name] or tweak_data.player.stances.default
	local zoom_fov = stances.steelsight and stances.steelsight.zoom_fov

	-- determine target FOV and toggle state
	local target_fov
	if m308_fov_zoom then
		m308_fov_zoom = false
		target_fov = managers.user:get_setting("fov_zoom")
	else
		m308_fov_zoom = true
		target_fov = D:conf("m308_fov_zoom_set")
	end

	-- apply FOV change instantly and update mouse sensitivity based on steelsight zoom_fov if in steelsight
	if plr_state._camera_unit and plr_state._camera_unit:base() and target_fov then
		plr_state._camera_unit:base():set_stance_newfov_instant(stance_key, target_fov)
	end

	if in_steelsight then
		managers.menu:set_mouse_sensitivity(zoom_fov)
	end
end)
