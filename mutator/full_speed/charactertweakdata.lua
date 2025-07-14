local module = ... or D:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:hook(CharacterTweakData, "_multiply_gang_speeds", function(self, walk_mul, run_mul)
	self.russian.SPEED_WALK = self.sniper.SPEED_RUN * walk_mul
	self.german.SPEED_WALK = self.gangster.SPEED_RUN * walk_mul
	self.spanish.SPEED_WALK = self.dealer.SPEED_RUN * walk_mul
	self.american.SPEED_WALK = self.tank.SPEED_RUN * walk_mul
	self.russian.SPEED_RUN = self.murky.SPEED_RUN * run_mul
	self.german.SPEED_RUN = self.spooc.SPEED_RUN * run_mul
	self.spanish.SPEED_RUN = self.shield.SPEED_RUN * run_mul
	self.american.SPEED_RUN = self.taser.SPEED_RUN * run_mul
end, false)

module:post_hook(CharacterTweakData, "_set_easy", function(self)
	self:_multiply_all_speeds(3, 3)
	self:_multiply_gang_speeds(3, 3)
end, false)

module:post_hook(CharacterTweakData, "_set_normal", function(self)
	self:_multiply_all_speeds(3, 3)
	self:_multiply_gang_speeds(3, 3)
end, false)

module:post_hook(CharacterTweakData, "_set_hard", function(self)
	self:_multiply_all_speeds(3, 3)
	self:_multiply_gang_speeds(3, 3)
end, false)

module:post_hook(CharacterTweakData, "_set_overkill", function(self)
	self:_multiply_all_speeds(3, 3)
	self:_multiply_gang_speeds(3, 3)
end, false)

module:post_hook(CharacterTweakData, "_set_overkill_145", function(self)
	self:_multiply_all_speeds(3, 3)
	self:_multiply_gang_speeds(3, 3)
end, false)