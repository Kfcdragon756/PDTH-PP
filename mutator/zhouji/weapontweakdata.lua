local module = ... or D:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:pre_hook(WeaponTweakData, "_init_zhouji_data", function(self)
	for _, weapon_id in pairs(self.weapon_list) do
		self[weapon_id].damage_melee = 15
		self[weapon_id].damage_melee_effect_mul = 10
		self[weapon_id].NR_CLIPS_MAX = 1
		self[weapon_id].AMMO_PICKUP = {self[weapon_id].AMMO_PICKUP[1] * 0.5, self[weapon_id].AMMO_PICKUP[2] * 0.5}
	end
end)