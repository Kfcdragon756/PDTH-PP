local module = ... or D:module("PDTH++")
local PlayerTweakData = module:hook_class("PlayerTweakData")

module:post_hook(PlayerTweakData, "init", function(self)
	self.damage.HEALTH_INIT = 30
	self.damage.BLEED_OUT_HEALTH_INIT = 15
	self.stances.glock.steelsight.zoom_fov = false
end)


