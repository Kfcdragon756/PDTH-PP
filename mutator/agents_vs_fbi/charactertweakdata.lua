local module = ... or DorHUD:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:post_hook(CharacterTweakData, "_set_easy", function(self)
	self.tank.damage.visor_health = 10
end, false)

module:post_hook(CharacterTweakData, "_set_normal", function(self)
	self.tank.damage.visor_health = 15
end, false)

module:post_hook(CharacterTweakData, "_set_hard", function(self)
	self.tank.damage.visor_health = 20
end, false)

module:post_hook(CharacterTweakData, "_set_overkill", function(self)
	self.tank.damage.visor_health = 30
end, false)

module:post_hook(CharacterTweakData, "_set_overkill_145", function(self)
	self.tank.damage.visor_health = 35
end, false)