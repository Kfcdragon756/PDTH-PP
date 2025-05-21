local module = ... or DorHUD:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:post_hook(CharacterTweakData, "_init_swat", function(self, presets)
	self.swat.HEALTH_INIT = 4.5
	self.swat.headshot_dmg_mul = 1.5
	self.swat.rescue_hostages = false
	self.swat.dodge = presets.dodge.expert
	self.swat.weapon = presets.weapon.swats
end, false)

module:post_hook(CharacterTweakData, "_init_heavy_swat", function(self, presets)
	self.heavy_swat.rescue_hostages = false
	self.heavy_swat.dodge = presets.dodge.normal
	self.heavy_swat.weapon.m4.FALLOFF[1].dmg_mul = 1.2
	self.heavy_swat.weapon.m4.FALLOFF[2].dmg_mul = 1.2
	self.heavy_swat.weapon.m4.FALLOFF[3].dmg_mul = 1.2
	self.heavy_swat.weapon.m4.FALLOFF[4].dmg_mul = 1.2
	--self.heavy_swat.weapon.m4.FALLOFF[5].dmg_mul = 1.2
	self.heavy_swat.weapon.r870.FALLOFF[1].dmg_mul = 1.5
	self.heavy_swat.weapon.r870.FALLOFF[2].dmg_mul = 1.5
	self.heavy_swat.weapon.r870.FALLOFF[3].dmg_mul = 1.5
end, false)

module:post_hook(CharacterTweakData, "_init_murky", function(self,presets)
	self.murky.weapon = presets.weapon.fbi
	self.murky.surrender_easy = false
	self.murky.dodge = presets.dodge.ninja
	self.murky.weapon.ak47.FALLOFF[1].dmg_mul = 1.25
	self.murky.weapon.ak47.FALLOFF[2].dmg_mul = 1.25
	self.murky.weapon.ak47.FALLOFF[3].dmg_mul = 1.25
	self.murky.weapon.ak47.FALLOFF[4].dmg_mul = 1.25
	--self.murky.weapon.ak47.FALLOFF[5].dmg_mul = 1.25
	self.murky.weapon.mp5.FALLOFF[1].dmg_mul = 1.5
	self.murky.weapon.mp5.FALLOFF[2].dmg_mul = 1.5
	self.murky.weapon.mp5.FALLOFF[3].dmg_mul = 1.5
	self.murky.weapon.mp5.FALLOFF[4].dmg_mul = 1.5
	--self.murky.weapon.mp5.FALLOFF[5].dmg_mul = 1.5
	self.murky.weapon.m4.FALLOFF[1].dmg_mul = 1.2
	self.murky.weapon.m4.FALLOFF[2].dmg_mul = 1.2
	self.murky.weapon.m4.FALLOFF[3].dmg_mul = 1.2
	self.murky.weapon.m4.FALLOFF[4].dmg_mul = 1.2
	--self.murky.weapon.m4.FALLOFF[5].dmg_mul = 1.2
	self.murky.weapon.r870.FALLOFF[1].dmg_mul = 1.5
	self.murky.weapon.r870.FALLOFF[2].dmg_mul = 1.5
	self.murky.weapon.r870.FALLOFF[3].dmg_mul = 1.5
end, false)

module:post_hook(CharacterTweakData, "_init_fbi", function(self, presets)
	self.fbi.weapon = presets.weapon.fbi
	self.fbi.HEALTH_INIT = 4
	self.fbi.headshot_dmg_mul = 2.15
	self.fbi.dodge = presets.dodge.expert
	self.fbi.weapon.mossberg.FALLOFF[1].dmg_mul = 1.5
	self.fbi.weapon.mossberg.FALLOFF[2].dmg_mul = 1.5
	self.fbi.weapon.mossberg.FALLOFF[3].dmg_mul = 1.2
end, false)

module:post_hook(CharacterTweakData, "_init_tank", function(self, presets)
	self.tank.headshot_dmg_mul = 80
	self.tank.HEALTH_INIT = 750
	self.tank.weapon.r870.FALLOFF[1].dmg_mul = 6
	self.tank.weapon.r870.FALLOFF[2].dmg_mul = 5
	self.tank.weapon.r870.FALLOFF[3].dmg_mul = 4
	self.tank.weapon.mossberg.FALLOFF[1].dmg_mul = 5
	self.tank.weapon.mossberg.FALLOFF[2].dmg_mul = 3
	self.tank.weapon.mossberg.FALLOFF[3].dmg_mul = 2
	self.tank.weapon_voice = "1" -- But what does this actually do? Idk.
end, false)

module:post_hook(CharacterTweakData, "_init_cop", function(self,presets)
	self.cop.dodge = presets.dodge.good
end, false)

module:post_hook(CharacterTweakData, "_init_spanish", function(self, presets)
	self.spanish.SPEED_WALK = 220
	self.spanish.SPEED_RUN = 420
end, false)

module:post_hook(CharacterTweakData, "_init_german", function(self, presets)
	self.german.SPEED_WALK = 220
	self.german.SPEED_RUN = 420
end, false)

module:post_hook(CharacterTweakData, "_init_russian", function(self, presets)
	self.russian.SPEED_WALK = 220
	self.russian.SPEED_RUN = 420
end, false)

module:post_hook(CharacterTweakData, "_init_american", function(self, presets)
	self.american.SPEED_WALK = 220
	self.american.SPEED_RUN = 420
end, false)

module:hook(50, CharacterTweakData, "_presets", function(self, tweak_data)
	local presets = module:call_orig(CharacterTweakData, "_presets", self, tweak_data)
	
	

	presets.weapon.normal.r870.aim_delay = { 0.4, 0.3 }
	presets.weapon.good.r870.aim_delay = { 0.3, 0.3 }
	presets.weapon.expert.r870.aim_delay = { 0.2, 0.2 }
	presets.weapon.gang_member.r870.aim_delay = { 0.2, 0.2 }


	presets.weapon.normal.glock = deep_clone(presets.weapon.normal.mp5)
	presets.weapon.good.glock = deep_clone(presets.weapon.good.mp5)
	presets.weapon.expert.glock = deep_clone(presets.weapon.expert.mp5)

	presets.weapon.normal.ak47 = deep_clone(presets.weapon.normal.m4)
	presets.weapon.good.ak47 = deep_clone(presets.weapon.good.m4)
	presets.weapon.expert.ak47 = deep_clone(presets.weapon.expert.m4)

	presets.weapon.normal.bronco = deep_clone(presets.weapon.normal.c45)
	presets.weapon.good.bronco = deep_clone(presets.weapon.good.c45)
	
	presets.weapon.expert.hk21 = deep_clone(presets.weapon.expert.m4)
	presets.weapon.sniper.m14 = deep_clone(presets.weapon.sniper.m4)

	presets.weapon.normal.mossberg = deep_clone(presets.weapon.normal.r870)
	presets.weapon.good.mossberg = deep_clone(presets.weapon.good.r870)
	presets.weapon.expert.mossberg = deep_clone(presets.weapon.expert.r870)
	
	presets.weapon.fbi = deep_clone(presets.weapon.expert)
	presets.weapon.swats = deep_clone(presets.weapon.good)
	
	return presets
end, false)

module:post_hook(CharacterTweakData, "_create_table_structure", function(self)
	for id, data in pairs({
		glock = { folder = "glock_npc", unit = "glock_18_npc" },
		bronco = { folder = "raging_bull_npc", unit = "raging_bull_npc" },
		mossberg = { folder = "mossberg_npc", unit = "mossberg_npc" },
		ak47 = { folder = "ak47_npc", unit = "ak47_npc" },
		hk21 = { folder = "hk21_npc", unit = "hk21_npc" },
		m14 = { folder = "m14_npc", unit = "m14_npc" },
	}) do
		table.insert(self.weap_ids, id)
		table.insert(self.weap_unit_names, Idstring(string.format("units/weapons/%s/%s", data.folder, data.unit)))
	end
end, false)

