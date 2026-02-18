local module = ... or D:module("PDTH++")
local PlayerManager = module:hook_class("PlayerManager")

module:hook(PlayerManager, "aquire_default_upgrades", function(self)
	for _, item in pairs({
		"beretta92",
		"c45",
		"raging_bull",
		"m4",
		"hk21",
		"r870_shotgun",
		"m14",
		"mac11",
		"mossberg",
		"mp5",
		"cable_tie",
		"thick_skin",
		"extra_start_out_ammo",
		"extra_cable_tie",
		"ammo_bag",
		"doctor_bag",
		"trip_mine",
		"welcome_to_the_gang",
		"aggressor",
		"protector",
		"sharpshooters",
		"more_blood_to_bleed",
		"speed_reloaders",
		"mr_nice_guy",
	}) do
		managers.upgrades:aquire_default(item)
	end

	if managers.dlc:has_dlc1() then
		for _, item in pairs({ "ak47", "glock", "m79", "sentry_gun", "toolset", "more_ammo" }) do
			managers.upgrades:aquire_default(item)
		end
	end

	for i = 1, PlayerManager.WEAPON_SLOTS do
		if not managers.player:weapon_in_slot(i) then
			self._global.kit.weapon_slots[i] = managers.player:availible_weapons(i)[1]
		end
	end

	for i = 1, 3 do
		if not managers.player:equipment_in_slot(i) then
			self._global.kit.equipment_slots[i] = managers.player:availible_equipment(i)[1]
		end
	end
end)
