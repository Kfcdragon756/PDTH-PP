local module = ... or D:module("PDTH++")
local UseInteractionExt = module:hook_class("UseInteractionExt")
local SentryGunInteractionExt = module:hook_class("SentryGunInteractionExt", class, UseInteractionExt)

function SentryGunInteractionExt:_interact_blocked(player)
	return not managers.player:get_equipment() == "sentry_gun" or ( managers.player:get_equipment_amount() >= 1 )
end

function SentryGunInteractionExt:interact(player)
	SentryGunInteractionExt.super.super.interact(self, player) -- For now I have no clue of what it actually does. // -KF
	self._unit:base():destroy_sentry()
	managers.player:add_selected_equipment(1, 1, 1)
	return true
end
