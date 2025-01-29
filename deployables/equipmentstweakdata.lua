local EquipmentsTweakData = module:hook_class("EquipmentsTweakData")

module:post_hook(EquipmentsTweakData, "init", function (self)
	self.trip_mine = {
		icon = "equipment_trip_mine",
		use_function_name = "use_trip_mine",
		quantity = 10,
		text_id = "debug_trip_mine",
		description_id = "des_trip_mine",
		pickup_function_name = "pickup_trip_mine"
	}
	self.ammo_bag = {
		icon = "equipment_ammo_bag",
		use_function_name = "use_ammo_bag",
		quantity = 2,
		text_id = "debug_ammo_bag",
		description_id = "des_ammo_bag"
	}
	self.doctor_bag = {
		icon = "equipment_doctor_bag",
		use_function_name = "use_doctor_bag",
		quantity = 2,
		text_id = "debug_doctor_bag",
		description_id = "des_doctor_bag"
	}
	self.sentry_gun = {
		icon = "equipment_sentry",
		use_function_name = "use_sentry_gun",
		quantity = 3,
		text_id = "debug_sentry_gun",
		description_id = "des_sentry_gun"
	}
	self.specials.cable_tie = {
		text_id = "debug_equipment_cable_tie",
		icon = "equipment_cable_ties",
		quantity = 5,
		extra_quantity = {
			equipped_upgrade = "extra_cable_tie",
			category = "extra_cable_tie",
			upgrade = "quantity"
		}
	}
end)