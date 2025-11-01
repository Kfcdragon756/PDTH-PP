local module = ... or D:module("PDTH++")
local MenuManager = module:hook_class("MenuManager")
module:hook(MenuManager, "set_mouse_sensitivity", function(self, zoomed)
	local base_sens = managers.user:get_setting("camera_sensitivity")
	local zoom_enabled = managers.user:get_setting("enable_camera_zoom_sensitivity")
	local zoom_sens = managers.user:get_setting("camera_zoom_sensitivity")

	local sens = zoomed and zoom_enabled and zoom_sens or base_sens

	if m308_fov_zoom then
		local player_unit = managers.player:player_unit()

		if alive(player_unit) then
			local inv = player_unit:inventory()
			local unit = inv and inv:equipped_unit()
			if unit and unit:base()._name_id == "m14" then
				-- override sensitivity for m14 with the special zoom value when zoomed
				sens = zoomed and zoom_enabled and D:conf("m308_fov_zoom_sens") or base_sens
			end
		end
	end

	self._controller:get_setup():get_connection("look"):set_multiplier(sens * self._look_multiplier)
	managers.controller:rebind_connections()
end)
