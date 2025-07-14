local module = ... or DorHUD:module("PDTH++")
local PlayerTweakData = module:hook_class("PlayerTweakData")

module:post_hook(PlayerTweakData, "init", function(self)
	self.movement_state.standard.movement.speed.STANDARD_MAX = 400 * 3
	self.movement_state.standard.movement.speed.RUNNING_MAX = 600 * 3
	self.movement_state.standard.movement.speed.CROUCHING_MAX = 250 * 3
	self.movement_state.standard.movement.speed.STEELSIGHT_MAX = 150 * 3
	self.movement_state.standard.movement.speed.INAIR_MAX = 150 * 3
end, false)

function PlayerTweakData:_set_easy()
	self.damage.ARMOR_INIT = 8
	self.damage.MIN_DAMAGE_INTERVAL = 1
	self.damage.automatic_respawn_time = 60
	self.damage.REVIVE_HEALTH_STEPS = { 1, 0.75, 0.5 }
end

function PlayerTweakData:_set_normal()
	self.damage.ARMOR_INIT = 8
	self.damage.MIN_DAMAGE_INTERVAL = 1
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.automatic_respawn_time = 120
	self.damage.REVIVE_HEALTH_STEPS = { 1, 0.75, 0.5 }
end

function PlayerTweakData:_set_hard()
	self.damage.ARMOR_INIT = 7
	self.damage.MIN_DAMAGE_INTERVAL = 0.8
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.REVIVE_HEALTH_STEPS = { 0.75, 0.5 }
end

function PlayerTweakData:_set_overkill()
	self.damage.ARMOR_INIT = 6
	self.damage.MIN_DAMAGE_INTERVAL = 0.6
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.REVIVE_HEALTH_STEPS = { 0.75, 0.5 }
end

function PlayerTweakData:_set_overkill_145()
	self.damage.ARMOR_INIT = 6
	self.damage.MIN_DAMAGE_INTERVAL = 0.6
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 0
	self.damage.REVIVE_HEALTH_STEPS = { 0.5, 0.25 }
end