local module = ... or D:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:post_hook(CharacterTweakData, "_init_heavy_swat", function(self, presets)
	self.heavy_swat.dodge = presets.dodge.ninja
	self.heavy_swat.weapon = presets.weapon.fbi
end, false)
