local module = DorHUDMod:new("PDTH++", { abbr = "PDTH++",
	author = "kfcdragon756",
	bundled = "standard", 
	categories = "Gameplay-changing", 
	version = "v1.35", 
	description = {
	chinese = "收获日：掠夺的游戏体验不够丰富，而这个大修就是尽可能在有限的内容里添加尽可能多的丰富度。",
	english = "The gameplay variety is still not enough, and this overhaul is just trying to add as much variety as possible in limited contents.",
	spanish = "La variedad del gameplay vanilla no es suficiente, este mod overhaul inteta añadir la mayor variedad posible con el poco contenido que ofrece el juego.",
	german = "Die Gameplayvielfalt ist immer noch nicht genug und diese Überarbeitung versucht, noch mehr Vielfalt im beschränkten Format einzubringen.",
	},
	dependencies = {
		"[nwpab]",
		"[static_recoil]",
		"[bwr]",
		"[Alleviations Weapon Rework]",
		"[1° A.W.U. Rebalance]",
		"[yet_another_weapon_rebalance]",
		"[ovk_193]",
		"[hitmarkers]",
		"[Realistic Rof]",
		"[shotgun pellets customization]",
		"[wtfbm]",
		"[M308_can_zoom]",
	},
	includes = { 
	{ "mod_localization", { type = "localization" } },
	{ "mod_options", { type = "menu_options" } },
	},
})

--sandbox
module:hook_post_require("lib/managers/achievmentmanager.", "sandbox/achievmentmanager")
module:hook_post_require("lib/network/matchmaking/networkaccountsteam", "sandbox/NetworkAccountSTEAM")
module:hook_post_require("lib/network/matchmaking/networkmatchmakingsteam", "sandbox/NetworkMatchMakingSTEAM")
module:hook_post_require("lib/managers/savefilemanager", "sandbox/savefile")
--player weapon & NPC base weapon stats.
module:hook_post_require("lib/tweak_data/playertweakdata", "weapon_stuff/playertweakdata")
module:hook_post_require("lib/tweak_data/weapontweakdata", "weapon_stuff/weapontweakdata")
module:hook_post_require("lib/units/weapons/raycastweaponbase", "weapon_stuff/shieldpiercing")
module:hook_post_require("lib/units/weapons/shotgun/shotgunbase", "weapon_stuff/shotgunbase")
module:hook_post_require("lib/managers/gameplaycentralmanager", "weapon_stuff/shieldpiercing")
module:hook_post_require("lib/units/cameras/fpcameraplayerbase", "weapon_stuff/FPCameraPlayerBase")
module:hook_post_require("lib/units/beings/player/states/playerstandard", "weapon_stuff/playerstandard")
module:hook_post_require("lib/units/beings/player/states/playertased", "weapon_stuff/playertased")
module:hook_post_require("lib/units/weapons/raycastweaponbase", "weapon_stuff/fire_sound_fix")
module:hook_post_require("lib/units/weapons/raycastweaponbase", "weapon_stuff/raycastweaponbase")
module:register_post_override("lib/units/weapons/grenades/m79grenadebase", "weapon_stuff/m79grenadebase")
module:hook_post_require("lib/managers/menumanager", "weapon_stuff/menumanager")
--enemies
module:hook_post_require("lib/tweak_data/charactertweakdata", "enemies/charactertweakdata")
module:hook_post_require("core/lib/units/coreunitdamage", "enemies/coreunitdamage")
module:hook_post_require("lib/units/enemies/cop/copdamage", "enemies/copdamage")
module:hook_post_require("lib/units/enemies/cop/copbase", "enemies/copbase")
module:hook_post_require("lib/units/civilians/logics/civilianlogicescort", "enemies/civilianlogicescort")
--difficulty
module:hook_post_require("lib/tweak_data/groupaitweakdata", "difficulties/groupaitweakdata")
module:hook_post_require("lib/tweak_data/charactertweakdata", "difficulties/charactertweakdata")
module:hook_post_require("lib/tweak_data/playertweakdata", "difficulties/playertweakdata")
--deployables
module:hook_post_require("lib/units/weapons/raycastweaponbase", "deployables/pickupdeployables")
module:hook_post_require("lib/tweak_data/equipmentstweakdata", "deployables/equipmentstweakdata")
module:hook_post_require("lib/units/pickups/ammoclip", "deployables/pickupdeployables")
module:hook_post_require("lib/managers/playermanager", "deployables/pickupdeployables")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "deployables/pickupdeployables")
--module:hook_post_require("lib/units/equipment/sentry_gun/sentrygunbase", "deployables/sentrygunbase") unused but will be still here for future development.
module:hook_post_require("lib/units/weapons/trip_mine/tripminebase", "deployables/tripminebase")
--tweakdata
module:hook_post_require("lib/tweak_data/upgradestweakdata","tweakdata/upgradestweakdata")
--equipments & crew bonuses and less shake on hit.
module:hook_post_require("lib/units/beings/player/playerdamage", "equipment_overhaul/playerdamage")
module:hook_post_require("lib/units/beings/player/playermovement", "equipment_overhaul/playermovement")

--disable some mods that may conflict with this mod.
module:hook("OnModuleRegistered", "load_KO", function()
	D:unregister_module("anticheat")
	D:unregister_module("save_slot_selector")
	D:unregister_module("Auto Fire Sound Fix")
	D:unregister_module("wtfbm")
	D:unregister_module("shotgun pellets customization")
	D:unregister_module("M308_can_zoom")
	--This mod was totally a mistake.
end)
--some mutators will be fun.
module:hook("OnModuleLoading", "load_mutators", function(module)
	--prevents that you load mutator without loading ovk_193, it will crash the game.
	local ovk_193 = D:module("ovk_193")
	if not ovk_193 or (ovk_193 and not ovk_193:enabled()) then
		return
	end
	--unload mutator packages.
	module:hook_post_require("lib/setups/gamesetup", "mutator/gamesetup")

	--this will prevent the mutator conflictions. (some mutators will break another mutator)
	--Okay they will not be that useful at the situation of newest version of overkill 193 enabled, but I still decided to keep them for some reason.
	module:hook_post_require("lib/managers/menumanager", "mutator/menumanager")
	module:hook_post_require("lib/managers/menumanagerdialogs", "mutator/menumanagerdialogs")
	
	local mutator_availability = {}
	
	mutator_availability = { all = true, _conflicts = { "kaboom", "no_time_for_searching" } }
	if MutatorHelper.setup_mutator(module, "zhouji", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/zhouji/weapontweakdata")
		module:hook_post_require("lib/tweak_data/playertweakdata", "mutator/zhouji/playertweakdata")
	end
	
	mutator_availability = { all = true }
	if MutatorHelper.setup_mutator(module, "full_speed", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/charactertweakdata", "mutator/full_speed/charactertweakdata")
		module:hook_post_require("lib/tweak_data/playertweakdata", "mutator/full_speed/playertweakdata")
	end
	
	mutator_availability = { all = true, _conflicts = { "zhouji", "no_time_for_searching" } }
	if MutatorHelper.setup_mutator(module, "kaboom", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/kaboom/weapontweakdata")
	end
	
	mutator_availability = { overkill = {}, overkill_145 = {} }
	if MutatorHelper.setup_mutator(module, "exercised_cops", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/charactertweakdata", "mutator/exercised_cops/charactertweakdata")
		module:hook_post_require("lib/tweak_data/groupaitweakdata", "mutator/exercised_cops/groupaitweakdata")
	end
	
	mutator_availability = { overkill = {}, overkill_145 = {} }
	if MutatorHelper.setup_mutator(module, "combine_assault", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/groupaitweakdata", "mutator/combine_assault/groupaitweakdata")
		module:hook_post_require("lib/setups/gamesetup", "mutator/combine_assault/gamesetup")
	end
	
	mutator_availability = { all = true }
	if MutatorHelper.setup_mutator(module, "expert_mode", mutator_availability, nil, true) then
		module:hook_post_require("lib/units/beings/player/playerdamage", "mutator/expert_mode/playerdamage")
		module:hook_post_require("lib/tweak_data/playertweakdata", "mutator/expert_mode/playertweakdata")
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/expert_mode/weapontweakdata")
		module:hook_post_require("lib/units/weapons/raycastweaponbase", "mutator/expert_mode/raycastweaponbase")
		module:hook_post_require("lib/tweak_data/charactertweakdata", "mutator/expert_mode/charactertweakdata")
		module:hook_post_require("lib/units/enemies/spooc/actions/lower_body/actionspooc", "mutator/expert_mode/actionspooc")
		module:hook_post_require("lib/units/beings/player/states/playertased", "mutator/expert_mode/playertased")
	end
	
	mutator_availability = { all = true, _conflicts = { "zhouji", "kaboom" } }
	if MutatorHelper.setup_mutator(module, "no_time_for_searching", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/no_time_for_searching/weapontweakdata")
		module:hook_post_require("lib/units/enemies/cop/copdamage", "mutator/no_time_for_searching/copdamage")
	end
	
	mutator_availability = { normal = {}, hard = {}, overkill = {}, overkill_145 = {} }
	if MutatorHelper.setup_mutator(module, "better_enemy_lmg", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/better_enemy_lmg/weapontweakdata")
	end

	mutator_availability = { overkill = { levels = { heat_street = true } }, overkill_145 = { levels = { heat_street = true } } }
	if MutatorHelper.setup_mutator(module, "dozers_on_street", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/groupaitweakdata", "mutator/dozers_on_street/groupaitweakdata")
	end
	
	mutator_availability = { all = { levels = { bank = true, heat_street = true, apartment = true, bridge = true, diamond_heist = true, slaughter_house = true, suburbia = true, secret_stash = true } } }
	if MutatorHelper.setup_mutator(module, "stealth_marksman", mutator_availability, nil, true) then
		module:hook_post_require("lib/units/enemies/cop/copbase", "mutator/stealth_marksman/copbase")
	end
	
	mutator_availability = { overkill_193 = false, easy = {}, normal = {}, hard = {}, overkill = {}, overkill_145 = {}, _conflicts = { "zhouji", "no_time_for_searching", "kaboom", "exercised_cops", "combine_assault" } }
	if MutatorHelper.setup_mutator(module, "agents_vs_fbi", mutator_availability, nil, true) then
		module:hook_post_require("lib/tweak_data/groupaitweakdata", "mutator/agents_vs_fbi/groupaitweakdata")
		module:hook_post_require("lib/tweak_data/weapontweakdata", "mutator/agents_vs_fbi/weapontweakdata")
		module:hook_post_require("lib/tweak_data/charactertweakdata", "mutator/agents_vs_fbi/charactertweakdata")
		module:hook_post_require("lib/managers/playermanager", "mutator/agents_vs_fbi/playermanager")
	end
	
end, false)
return module