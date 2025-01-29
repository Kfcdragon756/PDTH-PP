local CharacterTweakData = module:hook_class("CharacterTweakData")

function CharacterTweakData:_set_easy()
	self:_multiply_all_hp(1.5, 1.55)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 2)
	self:_multiply_weapon_delay(self.presets.weapon.good, 1.25)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 1.15)
	self:_multiply_weapon_delay(self.presets.weapon.fbi, 1.15)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 2)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.5
	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.35
	self.presets.gang_member_damage.HEALTH_INIT = 70
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 100
end

function CharacterTweakData:_set_normal()
	self:_multiply_all_hp(1.5, 1.55)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 2)
	self:_multiply_weapon_delay(self.presets.weapon.good, 1.15)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 1)
	self:_multiply_weapon_delay(self.presets.weapon.fbi, 1)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 2)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.25)
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.5
	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.35
	self.presets.gang_member_damage.HEALTH_INIT = 70
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 100
end

function CharacterTweakData:_set_hard()
	self:_multiply_all_hp(2, 1.55)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 2)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.65)
	self:_multiply_weapon_delay(self.presets.weapon.fbi, 0.65)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 1.56)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.5)
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.3
	self.presets.gang_member_damage.REGENERATE_TIME = 2
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.35
	self.presets.gang_member_damage.HEALTH_INIT = 50
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 100
end

function CharacterTweakData:_set_overkill()
	self:_multiply_all_hp(2, 1.55)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.6)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.5)
	self:_multiply_weapon_delay(self.presets.weapon.fbi, 0.5)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 0.5)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.75)
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.3
	self.presets.gang_member_damage.REGENERATE_TIME = 3
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.35
	self.presets.gang_member_damage.HEALTH_INIT = 50
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 100
end

function CharacterTweakData:_set_overkill_145()
	self:_multiply_all_hp(2, 1.55)
	self:_multiply_all_speeds(1.1, 1.15)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.25)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.2)
	self:_multiply_weapon_delay(self.presets.weapon.fbi, 0.2)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 0.5)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 1.5)
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.3
	self.presets.gang_member_damage.REGENERATE_TIME = 3
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.35
	self.presets.gang_member_damage.HEALTH_INIT = 50
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 100
end