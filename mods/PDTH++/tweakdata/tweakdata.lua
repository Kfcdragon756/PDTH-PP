local module = ... or D:module("PDTH++")
local TweakData = module:hook_class("TweakData")

module:post_hook(TweakData, "init", function(self)
	self.interaction.sentry_gun = {}
	self.interaction.sentry_gun.icon = "interaction_sentrygun"
	self.interaction.sentry_gun.text_id = "debug_interact_sentry_gun"
	self.interaction.sentry_gun.contour = "deployable"
	self.interaction.sentry_gun.timer = 5.5
	self.interaction.sentry_gun.blocked_hint = "not_sentry_gun_or_low_ammo"
end, false)