local module = ... or DorHUD:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:post_hook(WeaponTweakData, "_init_data_hk21_npc", function(self)
	self.hk21_npc.auto.fire_rate = 0.092
end)