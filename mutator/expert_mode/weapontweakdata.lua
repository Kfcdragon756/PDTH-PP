local module = ... or DorHUD:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")

module:pre_hook(WeaponTweakData, "_init_expert_mode_data", function(self)
	self.m79.use_data.selection_index = 4
end)