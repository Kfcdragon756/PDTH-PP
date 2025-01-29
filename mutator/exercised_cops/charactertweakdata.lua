local module = ... or DorHUD:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:post_hook(CharacterTweakData, "_init_heavy_swat", function(self, presets)
	self.heavy_swat.dodge = presets.dodge.ninja
	self.heavy_swat.weapon = presets.weapon.expert
end, false)
