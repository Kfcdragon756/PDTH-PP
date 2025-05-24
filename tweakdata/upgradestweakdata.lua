local module = ... or D:module("PDTH++")
local UpgradesTweakData = module:hook_class("UpgradesTweakData")

module:hook(UpgradesTweakData, "init_weapon_upgrade_data", function(self)
--GL40
	self.values.m79.damage_multiplier = {1, 1, 1, 1}
	self.values.m79.explosion_range_multiplier = {1, 1}
	self.values.m79.clip_amount_increase = {0, 0}
--LMG
	self.values.hk21.clip_ammo_increase = {0, 0, 0, 0}
	self.values.hk21.damage_multiplier = {1, 1, 1, 1}
	self.values.hk21.recoil_multiplier = {1, 1}
--B9
	self.values.beretta92.clip_ammo_increase = {0, 0}
	self.values.beretta92.spread_multiplier = {1, 1}
	self.values.beretta92.recoil_multiplier = {1, 1, 1, 1}
--CROSSKILL .45 MKII
	self.values.c45.clip_ammo_increase = {0, 0}
	self.values.c45.recoil_multiplier = {1, 1, 1, 1}
	self.values.c45.damage_multiplier = {1, 1, 1, 1}
--BRONCO .44
	self.values.raging_bull.spread_multiplier = {1, 1, 1, 1}
	self.values.raging_bull.damage_multiplier = {1, 1, 1, 1}
--STRYK
	self.values.glock.recoil_multiplier = {1, 1}
	self.values.glock.clip_ammo_increase = {0, 0, 0, 0}
	self.values.glock.damage_multiplier = {1, 1}
--M308
	self.values.m14.clip_ammo_increase = {0, 0}
	self.values.m14.recoil_multiplier = {1, 1, 1, 1}
	self.values.m14.spread_multiplier = {1, 1}
	self.values.m14.damage_multiplier = {1, 1}
--REINBECK
	self.values.r870_shotgun.clip_ammo_increase = {0, 0}
	self.values.r870_shotgun.recoil_multiplier = {1, 1, 1, 1}
	self.values.r870_shotgun.damage_multiplier = {1, 1, 1, 1}
--AK
	self.values.ak47.spread_multiplier = {1, 1}
	self.values.ak47.recoil_multiplier = {1, 1, 1, 1}
	self.values.ak47.damage_multiplier = {1, 1, 1, 1}
	self.values.ak47.clip_ammo_increase = {0, 0}
--COMPACT-5
	self.values.mp5.recoil_multiplier = {1, 1}
	self.values.mp5.spread_multiplier = {1, 1}
--LOCO
	self.values.mossberg.clip_ammo_increase = {0, 0}
	self.values.mossberg.recoil_multiplier = {1, 1}
--MARK11
	self.values.mac11.clip_ammo_increase = {0, 0, 0, 0}
	self.values.mac11.recoil_multiplier = {1, 1, 1, 1}
--AMCAR-4
	self.values.m4.clip_ammo_increase = {0, 0}
	self.values.m4.spread_multiplier = {1, 1, 1, 1}
	self.values.m4.damage_multiplier = {1, 1}
--Deployables
	self.ammo_bag_base = 7.5
	self.values.ammo_bag.ammo_increase = {0, 0, 0}
	self.doctor_bag_base = 3
	self.values.doctor_bag.amount_increase = {0, 0, 0}
	self.values.trip_mine.quantity = {0, 0, 0, 0, 0, 0 }
	self.values.trip_mine.damage_multiplier = {1, 1}
	self.sentry_gun_base_ammo = 150
	self.sentry_gun_base_armor = 10
	self.values.sentry_gun.ammo_increase = {
		50,
		75,
		100,
		150
	}
end, false)

module:hook(UpgradesTweakData, "init_crew_bonus_data", function(self)
	self.values.crew_bonus.protector = {0.9}
	self.values.crew_bonus.more_ammo = {1}
	self.values.crew_bonus.more_blood_to_bleed = {2}
	self.values.crew_bonus.aggressor = {1}
	self.values.crew_bonus.speed_reloaders = {1.15}
end, false)

module:hook(UpgradesTweakData, "init_equipment_data", function(self)
	self.values.player.thick_skin = { 10, 10, 10, 10, 10 }
	self.values.player.body_armor = { 0, 0, 0, 0, 0 }
	self.values.player.extra_ammo_multiplier = { 1, 1, 1, 1, 1 }
	self.values.player.toolset = { 0.55, 0.55, 0.55, 0.55 }
	self.values.extra_cable_tie.quantity = { -2, -2, -2, -2 }
end, false)

module:post_hook(UpgradesTweakData, "init", function(self)
	self:init_weapon_upgrade_data()
	self:init_crew_bonus_data()
	self:init_equipment_data()
end, false)

