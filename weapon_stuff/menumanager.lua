function MenuManager:set_mouse_sensitivity(zoomed)
	if SystemInfo:platform() == Idstring("PS3") then
		return
	end
	local sens = zoomed and managers.user:get_setting("enable_camera_zoom_sensitivity") and managers.user:get_setting("camera_zoom_sensitivity") or managers.user:get_setting("camera_sensitivity")
	if m308_fov_zoom then
		local inv = alive(managers.player:player_unit()) and managers.player:player_unit():inventory()
		local unit = inv and inv:equipped_unit()
		if not unit then
			self._controller:get_setup():get_connection("look"):set_multiplier(sens * self._look_multiplier)
			managers.controller:rebind_connections()
			return
		end
		local name = unit:base()._name_id
		if name ~= "m14" then
			self._controller:get_setup():get_connection("look"):set_multiplier(sens * self._look_multiplier)
			managers.controller:rebind_connections()
			return
		end
		sens = zoomed and managers.user:get_setting("enable_camera_zoom_sensitivity") and D:conf("m308_fov_zoom_sens") or managers.user:get_setting("camera_sensitivity")
	end
	self._controller:get_setup():get_connection("look"):set_multiplier(sens * self._look_multiplier)
	managers.controller:rebind_connections()
end