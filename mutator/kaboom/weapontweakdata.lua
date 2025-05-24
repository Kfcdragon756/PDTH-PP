local module = ... or D:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:hook(WeaponTweakData, "_init_kaboom_data", function(self)
	for _, weapon_id in pairs( { "m4", "r870_shotgun", "m14", "hk21", "ak47", "mossberg", "mp5", "mac11" } ) do
		self[weapon_id].NR_CLIPS_MAX = 0
		self[weapon_id].cant_pick_ammo = true
	end
	self.m79.cant_pick_ammo = nil
	self.m79.NR_CLIPS_MAX = 10
	self.m79.CLIP_AMMO_MAX = 3
	self.m79.AMMO_PICKUP = {0, 2}
	self.m79.DAMAGE = 15
	self.m79.DAMAGE_CURVE_POW = 0
	self.m79.single.fire_rate = 0.5
	self.m79.reload_speed = 1.3
end)
--weird stuff