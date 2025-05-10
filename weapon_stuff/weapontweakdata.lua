local module = ... or DorHUD:module("PDTH++")
local WeaponTweakData = module:hook_class("WeaponTweakData")
local damage_melee_low = 2.5
local damage_melee_medium = 5
local damage_melee_high = 7
local damage_melee_effect_multiplier_low = 2
local damage_melee_effect_multiplier_medium = 6
local damage_melee_effect_multiplier_high = 15

module:pre_hook(WeaponTweakData, "init", function(self)
	self.weapon_list = { "beretta92", "c45", "raging_bull", "glock", "r870_shotgun", "m4", "m14", "hk21", "ak47", "mossberg", "mp5", "mac11", "m79" }
	--maybe useful for future mutator development.
end)

module:hook(WeaponTweakData, "_init_data_shield_piercing", function(self)
-- shield piercing 穿盾
    self.m14.can_shoot_through_shield = true
end)

module:hook(WeaponTweakData, "_init_data_reinbeck", function(self)
-- primary shotgun overhaul 大喷大修
	self.r870_shotgun.damage_melee = damage_melee_medium
	self.r870_shotgun.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
    self.r870_shotgun.CLIP_AMMO_MAX = 7
	self.r870_shotgun.DAMAGE = 2
	self.r870_shotgun.AMMO_PICKUP = { 0.3, 1.2 }
	self.r870_shotgun.EXTRA_PICKUP = { 0.1, 0.5 }
	self.r870_shotgun.single.fire_rate = 1
	self.r870_shotgun.firerate_multiplier = 1.5
	self.r870_shotgun.damage_near = 700
	self.r870_shotgun.damage_far = 4800
	self.r870_shotgun.spread.standing = 1.5
	self.r870_shotgun.spread.crouching = 1.5
	self.r870_shotgun.spread.steelsight = 0.785
	self.r870_shotgun.spread.moving_standing = 1.5
	self.r870_shotgun.spread.moving_crouching = 1.5
	self.r870_shotgun.pellet_amount = 6
	self.r870_shotgun.NR_CLIPS_MAX = 4
	self.r870_shotgun.hs_mul = 1.15
	self.r870_shotgun.ads_speed = 1
	self.r870_shotgun.reload_speed = 1.15
	self.r870_shotgun.DAMAGE_EFFECT = 5
	self.r870_shotgun.crosshair.standing.offset = 0.15
    self.r870_shotgun.crosshair.standing.moving_offset = 0.15
    self.r870_shotgun.crosshair.standing.kick_offset = 0.4
    self.r870_shotgun.crosshair.crouching.offset = 0.15
    self.r870_shotgun.crosshair.crouching.moving_offset = 0.15
    self.r870_shotgun.crosshair.crouching.kick_offset = 0.3
	self.r870_shotgun.extra_damage = 0.4
end)

module:hook(WeaponTweakData, "_init_data_ak47", function(self)
-- ak overhaul AK大修
	self.ak47.damage_melee = damage_melee_medium
	self.ak47.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
	self.ak47.auto.fire_rate = 0.1
	self.ak47.firerate_multiplier = 1
    self.ak47.DAMAGE = 4.5
	self.ak47.CLIP_AMMO_MAX = 30
    self.ak47.NR_CLIPS_MAX = 4
    self.ak47.AMMO_PICKUP = { 1.1, 3.4 }
	self.ak47.EXTRA_PICKUP = { 0.3, 0.6 }
	self.ak47.spread.standing = 2
	self.ak47.spread.crouching = 1.6
	self.ak47.spread.steelsight = 0.5
	self.ak47.spread.moving_standing = 2.4
	self.ak47.spread.moving_crouching = 1.7
	self.ak47.crosshair.standing.offset = 0.16
	self.ak47.crosshair.standing.moving_offset = 0.26
	self.ak47.crosshair.standing.kick_offset = 0.225
	self.ak47.crosshair.crouching.offset = 0.1
	self.ak47.crosshair.crouching.moving_offset = 0.175
	self.ak47.crosshair.crouching.kick_offset = 0.125
    self.ak47.kick.v.standing = 2
    self.ak47.kick.v.crouching = 1.5
    self.ak47.kick.v.steelsight = 0.8
    self.ak47.kick.h.standing = 2
    self.ak47.kick.h.crouching = 1.5
    self.ak47.kick.h.steelsight = 0.6
	self.ak47.hs_mul = 0.9
	self.ak47.ads_speed = 1
	self.ak47.reload_speed = 1.12
	self.ak47.extra_damage = 0.5
end)

module:hook(WeaponTweakData, "_init_data_m4", function(self)
-- amcar-4 overhaul M4大修
	self.test_raycast_weapon.DAMAGE = 2.4
	self.test_raycast_weapon.damage_melee = damage_melee_medium
	self.test_raycast_weapon.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
    self.test_raycast_weapon.AMMO_PICKUP = { 2.4, 4.6 }
	self.test_raycast_weapon.EXTRA_PICKUP = { 0.3, 0.7 }
	self.test_raycast_weapon.CLIP_AMMO_MAX = 30
	self.test_raycast_weapon.NR_CLIPS_MAX = 4
	self.test_raycast_weapon.auto.fire_rate = 0.088
	self.test_raycast_weapon.firerate_multiplier = 1
    self.test_raycast_weapon.spread.standing = 2.4
    self.test_raycast_weapon.spread.crouching = 1.5
    self.test_raycast_weapon.spread.steelsight = 0.3
	self.test_raycast_weapon.spread.moving_standing = 4
	self.test_raycast_weapon.spread.moving_crouching = 3
	self.test_raycast_weapon.crosshair.standing.offset = 0.2
    self.test_raycast_weapon.crosshair.standing.moving_offset = 0.4222
    self.test_raycast_weapon.crosshair.standing.kick_offset = 0.1333
    self.test_raycast_weapon.crosshair.crouching.offset = 0.15
	self.test_raycast_weapon.crosshair.crouching.moving_offset = 0.3334
	self.test_raycast_weapon.crosshair.crouching.kick_offset = 0.1333
	self.test_raycast_weapon.kick.v.standing = 0.65
	self.test_raycast_weapon.kick.v.crouching = 0.45
	self.test_raycast_weapon.kick.v.steelsight = 0.266
	self.test_raycast_weapon.kick.h.standing = 0.2
	self.test_raycast_weapon.kick.h.crouching = 0.15
	self.test_raycast_weapon.kick.h.steelsight = 0.09
	self.test_raycast_weapon.hs_mul = 1.05
	self.test_raycast_weapon.ads_speed = 1.12
	self.test_raycast_weapon.reload_speed = 0.85
	self.test_raycast_weapon.extra_damage = 0.6
	
	self.m4 = deep_clone(self.test_raycast_weapon)
end)

module:hook(WeaponTweakData, "_init_data_m308", function(self)
-- m308 overhaul m308大修
	self.m14.damage_melee = damage_melee_medium
	self.m14.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
    self.m14.NR_CLIPS_MAX = 6
    self.m14.AMMO_PICKUP = { 0.3, 1.7 }
	self.m14.EXTRA_PICKUP = { 0.1, 0.7 }
	self.m14.DAMAGE = 4
	self.m14.CLIP_AMMO_MAX = 12
	self.m14.spread.steelsight = 0.01
	self.m14.spread.standing = 2
    self.m14.spread.crouching = 2
    self.m14.spread.moving_standing = 3
    self.m14.spread.moving_crouching = 2.5
	self.m14.crosshair.standing.offset = 0.16
	self.m14.crosshair.standing.moving_offset = 0.3
	self.m14.crosshair.standing.kick_offset = 0.6
	self.m14.crosshair.crouching.offset = 0.08
	self.m14.crosshair.crouching.moving_offset = 0.15
	self.m14.crosshair.crouching.kick_offset = 0.4
	self.m14.single.fire_rate = 0.15
	self.m14.firerate_multiplier = 1.25
	self.m14.kick.v.standing = 2.75
	self.m14.kick.v.crouching = 2
	self.m14.kick.v.steelsight = 0.7
	self.m14.kick.h.standing = 0.45
	self.m14.kick.h.crouching = 0.35
	self.m14.kick.h.steelsight = 0.2
	self.m14.hs_mul = 2
	self.m14.ads_speed = 1
	self.m14.reload_speed = 0.95
	self.m14.movement_speed_multiplier = 1
	self.m14.extra_damage = 3
end)

module:hook(WeaponTweakData, "_init_data_hk21", function(self)
-- lmg overhaul 机枪大修
	self.hk21.damage_melee = damage_melee_low
	self.hk21.damage_melee_effect_mul = damage_melee_effect_multiplier_high
	self.hk21.auto.fire_rate = 0.092
	self.hk21.firerate_multiplier = 1
    self.hk21.spread.standing = 2
    self.hk21.spread.crouching = 2
    self.hk21.spread.steelsight = 0.8
    self.hk21.spread.moving_standing = 4
    self.hk21.spread.moving_crouching = 3
    self.hk21.kick.v.standing = 1.75
    self.hk21.kick.v.crouching = 1.75
    self.hk21.kick.v.steelsight = 1
    self.hk21.kick.h.standing = 1.5
    self.hk21.kick.h.crouching = 1
    self.hk21.kick.h.steelsight = 0.5
    self.hk21.NR_CLIPS_MAX = 3
	self.hk21.CLIP_AMMO_MAX = 80
    self.hk21.AMMO_PICKUP = {4, 6}
	self.hk21.EXTRA_PICKUP = {1, 1}
	self.hk21.DAMAGE = 3.5
    self.hk21.crosshair.standing.offset = 0.2855
    self.hk21.crosshair.standing.moving_offset = 0.3426
    self.hk21.crosshair.standing.kick_offset = 0.3997
    self.hk21.crosshair.crouching.offset = 0.2284
    self.hk21.crosshair.crouching.moving_offset = 0.2855
    self.hk21.crosshair.crouching.kick_offset = 0.3426
	self.hk21.hs_mul = 1.2
	self.hk21.ads_speed = 1
	self.hk21.movement_speed_multiplier = 0.80 --80% movement speed
	self.hk21.lower_speed_on_shooting = true
	self.hk21.reload_speed = 1.2
	self.hk21.extra_damage = 1.5
	
end)

module:hook(WeaponTweakData, "_init_data_mp5", function(self)
-- mp5 overhaul mp5大修
	self.mp5.damage_melee = damage_melee_medium
	self.mp5.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
    self.mp5.NR_CLIPS_MAX = 3
    self.mp5.DAMAGE = 1.5
    self.mp5.AMMO_PICKUP = {2.2, 5.2}
	self.mp5.EXTRA_PICKUP = {1, 0.6}
	self.mp5.auto.fire_rate = 0.0857
	self.mp5.firerate_multiplier = 1
    self.mp5.spread.standing = 2.5
    self.mp5.spread.crouching = 1.56
    self.mp5.spread.steelsight = 0.3
    self.mp5.spread.moving_standing = 2.572
    self.mp5.spread.moving_crouching = 2.172
    self.mp5.kick.v.standing = 0.25
    self.mp5.kick.v.crouching = 0.22225
    self.mp5.kick.v.steelsight = 0.175
    self.mp5.kick.h.standing = 0.25
    self.mp5.kick.h.crouching = 0.22225
    self.mp5.kick.h.steelsight = 0.1
    self.mp5.crosshair.standing.offset = 0.2544
    self.mp5.crosshair.standing.moving_offset = 0.3488
    self.mp5.crosshair.standing.kick_offset = 0.08
    self.mp5.crosshair.crouching.offset = 0.1138
	self.mp5.crosshair.crouching.moving_offset = 0.3111
	self.mp5.crosshair.crouching.kick_offset = 0.08
	self.mp5.hs_mul = 1.3
	self.mp5.ads_speed = 1.3
	self.mp5.reload_speed = 1.4
end)

module:hook(WeaponTweakData, "_init_data_mac11", function(self)
-- mark 11 overhaul mk11大修
	self.mac11.damage_melee = damage_melee_medium
	self.mac11.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
    self.mac11.NR_CLIPS_MAX = 2
	self.mac11.CLIP_AMMO_MAX = 32
    self.mac11.DAMAGE = 3.5
	self.mac11.spread.steelsight = 1.1
    self.mac11.AMMO_PICKUP = { 1.2, 3.6 }
	self.mac11.EXTRA_PICKUP = { 0.2, 0.6 }
    self.mac11.auto.fire_rate = 0.05
	self.mac11.firerate_multiplier = 1
	self.mac11.kick.v.standing = 0.5
	self.mac11.kick.v.crouching = 0.4
	self.mac11.kick.v.steelsight = 0.8
	self.mac11.kick.h.standing = 0.95
	self.mac11.kick.h.crouching = 0.95
	self.mac11.kick.h.steelsight = 0.65
	self.mac11.crosshair.standing.offset = 0.4
	self.mac11.crosshair.standing.moving_offset = 0.6
	self.mac11.crosshair.standing.kick_offset = 0.1
	self.mac11.crosshair.crouching.offset = 0.3
	self.mac11.crosshair.crouching.moving_offset = 0.5
	self.mac11.crosshair.crouching.kick_offset = 0.1
	self.mac11.hs_mul = 0.65
	self.mac11.ads_speed = 1.5
	self.mac11.reload_speed = 1
	self.mac11.extra_damage = 1.5
end)

module:hook(WeaponTweakData, "_init_data_locomotive", function(self)
-- loco overhaul 火车头大修
	self.mossberg.damage_melee = damage_melee_medium
	self.mossberg.damage_melee_effect_mul = damage_melee_effect_multiplier_medium
	self.mossberg.CLIP_AMMO_MAX = 4
    self.mossberg.NR_CLIPS_MAX = 4
    self.mossberg.AMMO_PICKUP = { 0.2, 1.1 }
	self.mossberg.EXTRA_PICKUP = { 0.1, 0.3 }
    self.mossberg.DAMAGE = 1
	self.mossberg.firerate_multiplier = 2
	self.mossberg.kick.v.standing = 5
    self.mossberg.kick.v.crouching = 5
    self.mossberg.kick.v.steelsight = 5
    self.mossberg.kick.h.standing = 5
    self.mossberg.kick.h.crouching = 5
    self.mossberg.kick.h.steelsight = 5
    self.mossberg.single.fire_rate = 0.6
    self.mossberg.damage_near = 450
    self.mossberg.damage_far = 2700
	self.mossberg.spread.standing = 6
	self.mossberg.spread.crouching = 6
	self.mossberg.spread.steelsight = 2
	self.mossberg.spread.moving_standing = 6
	self.mossberg.spread.moving_crouching = 6
	self.mossberg.kick.v.standing = 3
	self.mossberg.kick.v.crouching = 3
	self.mossberg.kick.v.steelsight = 2.655
	self.mossberg.kick.h.standing = 2
	self.mossberg.kick.h.crouching = 1.5
	self.mossberg.kick.h.steelsight = 1
	self.mossberg.crosshair.standing.offset = 0.5
	self.mossberg.crosshair.standing.moving_offset = 0.5
	self.mossberg.crosshair.standing.kick_offset = 0.4
	self.mossberg.crosshair.crouching.offset = 0.5
	self.mossberg.crosshair.crouching.moving_offset = 0.5
	self.mossberg.crosshair.crouching.kick_offset = 0.4
	self.mossberg.crosshair.steelsight.hidden = true
	self.mossberg.crosshair.steelsight.offset = 0.3
	self.mossberg.crosshair.steelsight.moving_offset = 0.6
	self.mossberg.crosshair.steelsight.kick_offset = 0.4
    self.mossberg.pellet_amount = 14
	self.mossberg.hs_mul = 0.7
	self.mossberg.ads_speed = 1.5
	self.mossberg.reload_speed = 1.45
	self.mossberg.movement_speed_multiplier = 1.05 --105% movement speed
	self.mossberg.DAMAGE_EFFECT = 40
end)

module:hook(WeaponTweakData, "_init_data_gl40", function(self)
-- gl40 overhaul 榴弹大修
	self.m79.firerate_multiplier = 1
	self.m79.damage_melee = damage_melee_low
	self.m79.damage_melee_effect_mul = damage_melee_effect_multiplier_high 
    self.m79.NR_CLIPS_MAX = 2
	self.m79.AMMO_PICKUP = {0, 0}
	self.m79.EXTRA_PICKUP = { 0, 0 }
	self.m79.DAMAGE = 30
	self.m79.timers.reload_not_empty = 4
	self.m79.timers.reload_empty = 4
	self.m79.DAMAGE_CURVE_POW = 0
	self.m79.EXPLOSION_RANGE = 1000
	self.m79.cant_pick_ammo = true
	self.m79.hs_mul = 1
	self.m79.ads_speed = 0.8
	self.m79.reload_speed = 0.89
end)

module:hook(WeaponTweakData, "_init_data_b9s", function(self)
-- b9-s overhaul b9大修
	self.beretta92.firerate_multiplier = 2
	self.beretta92.damage_melee = damage_melee_high
	self.beretta92.damage_melee_effect_mul = damage_melee_effect_multiplier_low
    self.beretta92.NR_CLIPS_MAX = 4
    self.beretta92.AMMO_PICKUP = { 2.5, 4.8 }
	self.beretta92.EXTRA_PICKUP = { 0.4, 1 }
    self.beretta92.DAMAGE = 1.8
	self.beretta92.CLIP_AMMO_MAX = 15
	self.beretta92.single.fire_rate = 0.2
    self.beretta92.spread.standing = 0.9
    self.beretta92.spread.crouching = 0.6
    self.beretta92.spread.steelsight = 0.1
    self.beretta92.spread.moving_standing = 1.25
    self.beretta92.spread.moving_crouching = 1.2
	self.beretta92.kick.v.standing = 0.75
	self.beretta92.kick.v.crouching = 0.75
	self.beretta92.kick.v.steelsight = 0.25
    self.beretta92.crosshair.standing.offset = 0.08
    self.beretta92.crosshair.standing.moving_offset = 0.08
    self.beretta92.crosshair.standing.kick_offset = 0.4
    self.beretta92.crosshair.crouching.offset = 0.05
    self.beretta92.crosshair.crouching.moving_offset = 0.05
    self.beretta92.crosshair.crouching.kick_offset = 0.3
	self.beretta92.hs_mul = 1.2
	self.beretta92.ads_speed = 1.6
	self.beretta92.reload_speed = 1.4
	self.beretta92.extra_damage = 0.7
end)

module:hook(WeaponTweakData, "_init_data_c45", function(self)
-- crosskill .45 overhaul C45大修
	self.c45.firerate_multiplier = 1.5
	self.c45.damage_melee = damage_melee_high
	self.c45.damage_melee_effect_mul = damage_melee_effect_multiplier_low
    self.c45.NR_CLIPS_MAX = 4
	self.c45.CLIP_AMMO_MAX = 8
    self.c45.AMMO_PICKUP = { -0.3, 2.4 }
	self.c45.EXTRA_PICKUP = { 0.2, 0.6 }
    self.c45.DAMAGE = 4
	self.c45.single.fire_rate = 0.18
    self.c45.spread.standing = 2.6
    self.c45.spread.crouching = 1.7
    self.c45.spread.steelsight = 0.65
    self.c45.spread.moving_standing = 3
    self.c45.spread.moving_crouching = 2
	self.c45.kick.v.standing = 1.5
	self.c45.kick.v.crouching = 1.5
	self.c45.kick.v.steelsight = 1.25
	self.c45.kick.h.standing = 1
	self.c45.kick.h.crouching = 1
	self.c45.kick.h.steelsight = 0.7
    self.c45.crosshair.standing.offset = 0.23
    self.c45.crosshair.standing.moving_offset = 0.4
    self.c45.crosshair.standing.kick_offset = 0.3
    self.c45.crosshair.crouching.offset = 0.1
    self.c45.crosshair.crouching.moving_offset = 0.2
    self.c45.crosshair.crouching.kick_offset = 0.4
	self.c45.hs_mul = 1.2
	self.c45.ads_speed = 1.42
	self.c45.reload_speed = 1.5
	self.c45.extra_damage = 1
end)

module:hook(WeaponTweakData, "_init_data_bronco", function(self)
-- bronco overhaul 左轮大修
	self.raging_bull.firerate_multiplier = 1.6
	self.raging_bull.damage_melee = damage_melee_high
	self.raging_bull.damage_melee_effect_mul = damage_melee_effect_multiplier_low
    self.raging_bull.NR_CLIPS_MAX = 4
    self.raging_bull.AMMO_PICKUP = { -0.1, 0.9 }
	self.raging_bull.EXTRA_PICKUP = { 0.1, 0.3 }
    self.raging_bull.DAMAGE = 13
	self.raging_bull.extra_damage = 5
    self.raging_bull.single.fire_rate = 0.52
    self.raging_bull.spread.standing = 1.5
    self.raging_bull.spread.crouching = 0.5
    self.raging_bull.spread.steelsight = 0.095
    self.raging_bull.spread.moving_standing = 2
    self.raging_bull.spread.moving_crouching = 1.5
	self.raging_bull.timers.reload_not_empty = 4.375
	self.raging_bull.timers.reload_empty = 5
	self.raging_bull.kick.v.standing = 1
	self.raging_bull.kick.v.crouching = 1
	self.raging_bull.kick.v.steelsight = 3
	self.raging_bull.kick.h.standing = 1
	self.raging_bull.kick.h.crouching = 1
	self.raging_bull.kick.h.steelsight = 2
    self.raging_bull.crosshair.standing.offset = 0.1
    self.raging_bull.crosshair.standing.moving_offset = 0.15
    self.raging_bull.crosshair.standing.kick_offset = 0.1
    self.raging_bull.crosshair.crouching.offset = 0.085
    self.raging_bull.crosshair.crouching.moving_offset = 0.1
    self.raging_bull.crosshair.crouching.kick_offset = 0.1
	self.raging_bull.hs_mul = 0.9
	self.raging_bull.ads_speed = 1.2
	self.raging_bull.reload_speed = 1.3
end)

module:hook(WeaponTweakData, "_init_data_stryk", function(self)
--stryk overhaul 自动手枪大修
	self.glock.firerate_multiplier = 1
	self.glock.damage_melee = damage_melee_high
	self.glock.damage_melee_effect_mul = damage_melee_effect_multiplier_low
    self.glock.NR_CLIPS_MAX = 2
	self.glock.CLIP_AMMO_MAX = 33
	self.glock.AMMO_PICKUP = { 2.3, 3.8 }
	self.glock.EXTRA_PICKUP = { 0.2, 0.6 }
    self.glock.DAMAGE = 2
	self.glock.auto.fire_rate = 0.05
    self.glock.spread.standing = 3.5
    self.glock.spread.crouching = 2.5 
    self.glock.spread.steelsight = 1.1
    self.glock.spread.moving_standing = 4
    self.glock.spread.moving_crouching = 2.8 
	self.glock.kick.v.standing = 1
	self.glock.kick.v.crouching = 0.9
	self.glock.kick.v.steelsight = 0.8
	self.glock.kick.h.standing = 1.1
	self.glock.kick.h.crouching = 0.8
	self.glock.kick.h.steelsight = 0.708
    self.glock.crosshair.standing.offset = 0.3
    self.glock.crosshair.standing.moving_offset = 0.5
    self.glock.crosshair.standing.kick_offset = 0.2
    self.glock.crosshair.crouching.offset = 0.2
    self.glock.crosshair.crouching.moving_offset = 0.24
    self.glock.crosshair.crouching.kick_offset = 0.1
	self.glock.hs_mul = 0.9
	self.glock.ads_speed = 1.42
	self.glock.reload_speed = 1.3
	self.glock.extra_damage = 0.5
end)

module:post_hook(WeaponTweakData, "_init_data_glock_18_npc", function(self)
	self.glock_18_npc.usage = "mp5"
	self.glock_18_npc.auto.fire_rate = 0.066
	self.glock_18_npc.DAMAGE = 1
end)

module:post_hook(WeaponTweakData, "_init_data_raging_bull_npc", function(self)
	self.raging_bull_npc.DAMAGE = 3
end)

module:post_hook(WeaponTweakData, "_init_data_c45_npc", function(self)
    self.c45_npc.DAMAGE = 1.7
end)

module:post_hook(WeaponTweakData, "_init_data_hk21_npc", function(self)
    self.hk21_npc.DAMAGE = 2
	self.hk21_npc.auto.fire_rate = 0.3
end)

module:post_hook(WeaponTweakData, "_init_data_beretta92_npc", function(self)
    self.beretta92_npc.DAMAGE = 1.2
end)

module:post_hook(WeaponTweakData, "_init_data_sentry_gun_npc", function(self)
	self.sentry_gun.DAMAGE = 1.7
	self.sentry_gun.SPREAD = 1
end)

module:post_hook(WeaponTweakData, "_init_data_ak47_npc", function(self)
	self.ak47_npc.DAMAGE = 2
end)

module:post_hook(WeaponTweakData, "_init_data_mp5_npc", function(self)
	self.mp5_npc.DAMAGE = 1.2
end)

module:post_hook(WeaponTweakData, "_init_data_shield_pistol_npc", function(self)
    self.shield_pistol_npc.DAMAGE = 1.2
end)

--creates some functions does nothing, for mutator purposes.
module:hook(WeaponTweakData, "_init_lowammo_data", function(self)
end)

module:hook(WeaponTweakData, "_init_expert_mode_data", function(self)
end)

module:hook(WeaponTweakData, "_init_zhouji_data", function(self)
end)

module:hook(WeaponTweakData, "_init_kaboom_data", function(self)
end)

module:hook(WeaponTweakData, "_init_notimeforsearch_data", function(self)
end)

module:hook(WeaponTweakData, "_init_agents_vs_fbi_data", function(self)
end)

module:post_hook(WeaponTweakData, "_init_data_player_weapons", function(self)
    self:_init_data_shield_piercing()
	self:_init_data_b9s()
	self:_init_data_c45()
	self:_init_data_bronco()
	self:_init_data_stryk()
	self:_init_data_m4()
	self:_init_data_hk21()
	self:_init_data_m308()
	self:_init_data_reinbeck()
	self:_init_data_ak47()
	self:_init_data_mac11()
	self:_init_data_locomotive()
	self:_init_data_mp5()
	self:_init_data_gl40()
	
	self:_init_lowammo_data()
	self:_init_expert_mode_data()
	self:_init_zhouji_data()
	self:_init_kaboom_data()
	self:_init_notimeforsearch_data()
	self:_init_agents_vs_fbi_data()
	
	self.trip_mines.damage = 40
end, false)
