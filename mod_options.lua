local module = ... or D:module("PDTH++")

--A script in hud module, not really know what it does...
local function _get_item(item_name, node)
	local node_name = "mod_options_" .. module:id()
	if not node then
		node = managers.menu:active_menu().logic:selected_node()
	end
	return node:item(node_name .. "_" .. item_name)
end

--This binding function is for cable tie skill.
module:add_menu_option("tie_yourself", {
	type = "keybind",
	text_id = "tie_yourself_keybind",
	help_id = "tie_yourself_help",
})

module:add_menu_option("change_308_fov_zoom", {
	type = "keybind",
	text_id = "change_308_fov_zoom_keybind",
	help_id = "change_308_fov_zoom_help",
})

module:add_menu_option("m308_fov_zoom_set", {
	type = "number",
	text_id = "m308_fov_zoom_set_keybind",
	help_id = "m308_fov_zoom_set_help",
})

module:add_menu_option("m308_fov_zoom_sens", {
	type = "slider",
	max = 1.7,
	min = 0.1,
	step = 0.001,
	text_id = "m308_fov_zoom_sens",
	help_id = "m308_fov_zoom_sens_help",
})

local next_allowed_tie_t = -100

local cannot_tie = function()
	--You cannot tie yourself if you don't have the skill.
	if not managers.player._equipment.specials.extra_cable_tie then
		return true
	end
	--A little delay on this function, otherwise player may trigger this too quickly so cable ties runs out too quick.
	if TimerManager:game():time() < next_allowed_tie_t then
		return true
	end
	return false
end

module:hook("OnKeyPressed", "tie_yourself", nil, "GAME", function(self)
	--Check if player unit exists. If this check doesn't exist then game will crash.
	if not alive(managers.player:player_unit()) then
		return
	end
	if cannot_tie() then
		return
	end
	--Get your state, so the function will only work while your state is standard or arrested.
	--The function current_state_name() doesn't exist in vanilla game. I made it for convenientcy.
	local state_name = managers.player:player_unit():movement():current_state_name()
	if state_name == "arrested" then
		managers.player:set_player_state("standard")
		return
	end
	--No cable ties means you don't have anything to tie yourself.
	if not managers.player._equipment.specials.cable_tie then
		return
	end
	if state_name ~= "standard" then
		return
	end
	managers.player:remove_special("cable_tie")
	managers.player:player_unit():movement():on_disarmed()
	next_allowed_tie_t = TimerManager:game():time() + 0.5
	--The delay is always 0.5s for sure. I don't actually know how TimerManager works but this definitely does something.
end)

--A global value for other places to use.
m308_fov_zoom = false

module:hook("OnKeyPressed", "change_308_fov_zoom", nil, "GAME", function(self)
	if alive(managers.player:player_unit()) then
		local inv = alive(managers.player:player_unit()) and managers.player:player_unit():inventory()
		local unit = inv and inv:equipped_unit()
		if not unit then
			return
		end
		local name = unit:base()._name_id
		local stances = tweak_data.player.stances[name] or tweak_data.player.stances.default
		if name ~= "m14" then
			return
		end
		--So there's only M308s can change fov zoom.
		local plr_state = managers.player:player_unit():movement():current_state()
		local stance = plr_state._in_steelsight and "steelsight" or plr_state._ducking and "crouched" or "standard"
		if m308_fov_zoom == true then
			m308_fov_zoom = false
			plr_state._camera_unit:base():set_stance_fov_instant(stance)
			managers.menu:set_mouse_sensitivity(plr_state._in_steelsight and stances.steelsight.zoom_fov)
			return
		end
		local fov = D:conf("m308_fov_zoom_set")
		plr_state._camera_unit:base():set_stance_newfov_instant(stance, fov)
		m308_fov_zoom = true
		managers.menu:set_mouse_sensitivity(plr_state._in_steelsight and stances.steelsight.zoom_fov)
	end
end)

module:hook("OnModulePostBuildOptions", "OnModulePostBuildOptions_DefaultFOVsettings", function(node)
	node = node or managers.menu:active_menu().logic:selected_node()

	local m308_fov_zoom_set_item = _get_item("m308_fov_zoom_set", node)
	local m308_fov_zoom_sens_item = _get_item("m308_fov_zoom_sens", node)
	if m308_fov_zoom_set_item then
		local config_key = m308_fov_zoom_set_item._parameters.config_key
		if not D:conf(config_key) then
			m308_fov_zoom_set_item:set_value(math.max(20, managers.user:get_setting("fov_zoom") / 2))
			m308_fov_zoom_set_item:trigger()
		end
	end
	
	if m308_fov_zoom_sens_item then
		local config_key = m308_fov_zoom_sens_item._parameters.config_key
		if not D:conf(config_key) then
			local sens = managers.user:get_setting("enable_camera_zoom_sensitivity") and managers.user:get_setting("camera_zoom_sensitivity") or managers.user:get_setting("camera_sensitivity")
			m308_fov_zoom_sens_item:set_value(math.max(0.3, sens / 2))
			m308_fov_zoom_sens_item:trigger()
		end
	end


	managers.menu:active_menu().logic:refresh_node()
end)
