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
			local sens = managers.user:get_setting("enable_camera_zoom_sensitivity")
					and managers.user:get_setting("camera_zoom_sensitivity")
				or managers.user:get_setting("camera_sensitivity")
			m308_fov_zoom_sens_item:set_value(math.max(0.3, sens / 2))
			m308_fov_zoom_sens_item:trigger()
		end
	end

	managers.menu:active_menu().logic:refresh_node()
end)
