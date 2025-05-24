local module = ... or D:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:pre_hook(WeaponTweakData, "_init_agents_vs_fbi_data", function(self)
	for _, weapon_id in pairs({"r870_shotgun", "m4", "m14", "hk21", "ak47", "mossberg", "mp5", "mac11", "m79"}) do
		self[weapon_id].use_data.selection_index = 4
	end
	for _, weapon_id in pairs({"beretta92", "c45", "raging_bull"}) do
		self[weapon_id].NR_CLIPS_MAX = 3
	end
	self.beretta92.AMMO_PICKUP = {4, 7}
	self.c45.AMMO_PICKUP = {2, 5}
	self.raging_bull.AMMO_PICKUP = {1, 3}
	self.glock.AMMO_PICKUP = {4, 9}
end)