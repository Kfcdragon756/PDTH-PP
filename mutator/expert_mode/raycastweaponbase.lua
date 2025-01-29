local module = ... or DorHUD:module("PDTH++")
local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")

module:hook(RaycastWeaponBase, "on_reload", function(self)
	if self._setup.expend_ammo then
		if self._ammo_remaining_in_clip > 0 then
			self._ammo_total = self._ammo_total - self._ammo_remaining_in_clip
		end
		self._ammo_remaining_in_clip = math.min(self._ammo_total, self._ammo_max_per_clip)
		return
	end
	self._ammo_remaining_in_clip = self._ammo_max_per_clip
	self._ammo_total = self._ammo_max_per_clip
end)
-- From FGO.

module:hook(RaycastWeaponBase,"reload_speed_multiplier", function(self)
	local multiplier = 1.1 * tweak_data.weapon[self._name_id].reload_speed
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
	return multiplier
end,true)