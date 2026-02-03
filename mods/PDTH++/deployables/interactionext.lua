local module = ... or D:module("PDTH++")
local UseInteractionExt = module:hook_class("UseInteractionExt")
local SentryGunInteractionExt = module:hook_class("SentryGunInteractionExt", class, UseInteractionExt)
local AmmoBagInteractionExt = module:hook_class("AmmoBagInteractionExt")

function SentryGunInteractionExt:_interact_blocked(player)
    local data, _index = managers.player:equipment_data_by_name("sentry_gun")
    return not data or data.amount >= 1 or not self._unit:base():server_information() == managers.network:session():local_peer():id() 
end

function SentryGunInteractionExt:interact(player)
	SentryGunInteractionExt.super.super.interact(self, player) -- For now I have no clue of what it actually does. // -KF
	if not Network:is_server() then
		DNet:send_to_peers("ModEvent", {
		module = module:id(),
		event = "Destroy_sentry",
		value = 123,
		id = self._unit:base():server_information().owner_peer_id
		}, false, false)
		managers.player:add_selected_equipment(1, 1, 1)
		return true
	end
	self._unit:base():destroy_sentry()
	managers.player:add_selected_equipment(1, 1, 1)
	return true
end

module:hook(AmmoBagInteractionExt, "interact", function(self, player) -- Extra start ammo now provides a instant reload while interacted with an ammo bag.
	if managers.player:has_special_equipment("extra_start_out_ammo") then
		player:inventory():equipped_unit():base():on_reload()
	end
	module:call_orig(AmmoBagInteractionExt, "interact", self, player)
	if managers.player:has_special_equipment("extra_start_out_ammo") then
		player:inventory():equipped_unit():base():_reload_instant()
	end
end, false)
-- Why set up this function like this bullshit? 
-- This is for making sure that your clip ammo amount is always full and you will always gain reload penalty in "littering everywhere" mutator.