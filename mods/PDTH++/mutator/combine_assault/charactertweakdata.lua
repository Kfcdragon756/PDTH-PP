local module = ... or D:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:post_hook(CharacterTweakData, "_init_murky", function(self, presets)
	-- Combine Assault uses Murkies outside Slaughterhouse. Give them the same
	-- navigation permission family as SWAT so generic maps do not reject their links.
	if self.murky then
		self.murky.access = "swat"
	end
end, false)
