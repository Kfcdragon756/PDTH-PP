local module = ... or DorHUD:module("PDTH++")
local CharacterTweakData = module:hook_class("CharacterTweakData")

module:hook(50, CharacterTweakData, "_presets", function(self, tweak_data)
	local presets = module:call_orig(CharacterTweakData, "_presets", self, tweak_data)
	presets.weapon.normal.r870.aim_delay = { 0, 0 }
	presets.weapon.good.r870.aim_delay = { 0, 0 }
	presets.weapon.expert.r870.aim_delay = { 0, 0 }
	presets.weapon.gang_member.r870.aim_delay = { 0, 0 }
	
	presets.weapon.normal.glock = deep_clone(presets.weapon.normal.mp5)
	presets.weapon.good.glock = deep_clone(presets.weapon.good.mp5)
	presets.weapon.expert.glock = deep_clone(presets.weapon.expert.mp5)
	
	presets.weapon.normal.ak47 = deep_clone(presets.weapon.normal.m4)
	presets.weapon.good.ak47 = deep_clone(presets.weapon.good.m4)
	presets.weapon.expert.ak47 = deep_clone(presets.weapon.expert.m4)
	
	presets.weapon.normal.bronco = deep_clone(presets.weapon.normal.c45)
	presets.weapon.good.bronco = deep_clone(presets.weapon.good.c45)
	
	presets.weapon.sniper.m14 = deep_clone(presets.weapon.sniper.m4)
	presets.weapon.expert.hk21 = deep_clone(presets.weapon.expert.m4)
	
	presets.weapon.normal.mossberg = deep_clone(presets.weapon.normal.r870)
	presets.weapon.good.mossberg = deep_clone(presets.weapon.good.r870)
	presets.weapon.expert.mossberg = deep_clone(presets.weapon.expert.r870)
	return presets
end, false)