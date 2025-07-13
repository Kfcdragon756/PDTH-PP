local module = ... or D:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:hook(WeaponTweakData, "_init_notimeforsearch_data", function(self)
	self.m4.NR_CLIPS_MAX = 7
	self.r870_shotgun.NR_CLIPS_MAX = 8
	self.ak47.NR_CLIPS_MAX = 4
	self.hk21.NR_CLIPS_MAX = 4
	self.m14.NR_CLIPS_MAX = 9
	self.mp5.NR_CLIPS_MAX = 7
	self.mac11.NR_CLIPS_MAX = 5
	self.mossberg.NR_CLIPS_MAX = 13
	self.beretta92.NR_CLIPS_MAX = 8
	self.c45.NR_CLIPS_MAX = 10
	self.glock.NR_CLIPS_MAX = 4
	self.raging_bull.NR_CLIPS_MAX = 8
end)
--so much ammo