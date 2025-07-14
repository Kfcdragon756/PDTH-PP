local module = ... or D:module("PDTH++")

local EquipmentsTweakData = module:hook_class("EquipmentsTweakData")
module:post_hook(EquipmentsTweakData, "init", function(self)
	self.trip_mine.quantity = 10

	self.ammo_bag.quantity = 2
	self.doctor_bag.quantity = 2
	self.sentry_gun.quantity = 3

	-- self.trip_mine.pickup_function_name = "pickup_trip_mine"
	-- self.sentry_gun.pickup_function_name = "pickup_sentry_gun"

	self.specials.cable_tie.quantity = 5
end)
