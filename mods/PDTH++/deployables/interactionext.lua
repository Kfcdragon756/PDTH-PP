local module = ... or D:module("PDTH++")
local UseInteractionExt = module:hook_class("BaseInteractionExt")
local SentryGunInteractionExt = module:hook_class("SentryGunInteractionExt", class, UseInteractionExt)

function SentryGunInteractionExt:_interact_blocked(player)
	return managers.player:get_equipment() ~= "sentry_gun" and ( managers.player:get_equipment_amount() >= 1 ) or ( managers.player:get_equipment_amount() >= 1 )
end

function SentryGunInteractionExt:interact(player)
	--SentryGunInteractionExt.super.super.interact(self, player) --No idea why this causes crashes, and for now I have no clue of what it actually does.
	self._unit:base():destroy_sentry()
	managers.player:add_selected_equipment(1, 1, 1)
	return true
end
