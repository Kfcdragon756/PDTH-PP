local module = ... or D:module("PDTH++")
local PlayerTweakData = module:hook_class("PlayerTweakData")

function PlayerTweakData:_set_easy()
	self.damage.ARMOR_INIT = 8
	self.damage.MIN_DAMAGE_INTERVAL = 0.8
	self.damage.automatic_respawn_time = 60
	self.damage.REVIVE_HEALTH_STEPS = { 1, 0.75, 0.5 }
end

function PlayerTweakData:_set_normal()
	self.damage.ARMOR_INIT = 8
	self.damage.MIN_DAMAGE_INTERVAL = 0.8
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.automatic_respawn_time = 120
	self.damage.REVIVE_HEALTH_STEPS = { 1, 0.75, 0.5 }
end

function PlayerTweakData:_set_hard()
	self.damage.ARMOR_INIT = 7
	self.damage.MIN_DAMAGE_INTERVAL = 0.6
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.REVIVE_HEALTH_STEPS = { 0.75, 0.5 }
end

function PlayerTweakData:_set_overkill()
	self.damage.ARMOR_INIT = 6
	self.damage.MIN_DAMAGE_INTERVAL = 0.5
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.REVIVE_HEALTH_STEPS = { 0.75, 0.5 }
end

function PlayerTweakData:_set_overkill_145()
	self.damage.ARMOR_INIT = 6
	self.damage.MIN_DAMAGE_INTERVAL = 0.45
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 0
	self.damage.REVIVE_HEALTH_STEPS = { 0.5, 0.25 }
end