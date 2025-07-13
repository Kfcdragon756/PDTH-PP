local module = ... or D:module("PDTH++")
local SentryGunBase = module:hook_class("SentryGunBase")

local spawn_interaction = function(position, rotation, text, func, sentrygun_unit)
	local interact_path = "units/world/props/apartment/apartment_key_dummy/apartment_key_dummy"
	--	if not PackageManager:has(Idstring("unit"), Idstring("units/world/props/apartment/apartment_key_dummy/apartment_key_dummy")) then
	--		return
	--	end

	local spawned_unit = safe_spawn_unit(Idstring(interact_path), position, rotation)
	if not alive(spawned_unit) then
		return
	end

	local interaction = spawned_unit.interaction and spawned_unit:interaction()
	if not interaction then
		return
	end

	interaction.old_selected = interaction.old_selected or interaction.selected

	interaction.selected = function(self, ...)
		self:old_selected(...)

		--local icon = self._tweak_data.icon
		local icon = "interaction_sentrygun"
		managers.hud:show_interact({ text = text or "default", icon = icon })
	end

	interaction.old_interact = interaction.old_interact or interaction.interact
	interaction.interact = function(self, ...)
		if type(func) == "function" then
			func(spawned_unit, sentrygun_unit)
		end
	end

	return spawned_unit
end

function func_a(spawned_unit, sentrygun_unit)
	if managers.player._equipment.selections[managers.player._equipment.selected_index].amount >= 2 then
		managers.hud:show_hint({
			text = "步哨机枪携带数目已达到上限。",
			event = nil,
			time = 2.5,
		})
		return
	end
	local getEquipment = managers.player:get_equipment()
	if not getEquipment == "sentry_gun" then
		managers.hud:show_hint({
			text = "装备其他部署物时不能拾起步哨机枪。",
			event = nil,
			time = 2.5,
		})
		return
	end
	managers.player:add_selected_equipment(1, 1, 2)
	sentrygun_unit:sound_source():post_event("turret_spin_stop")
	sentrygun_unit:set_slot(0)
	spawned_unit:set_slot(0)
end

--module:post_hook(SentryGunBase, "spawn", function(pos, rot, ammo_upgrade_lvl, armor_upgrade_lvl)
--	spawn_unit_card = spawn_interaction(pos,rot,'press f to pickup the sentry', func_a)
--end)

function SentryGunBase.spawn(pos, rot, ammo_upgrade_lvl, armor_upgrade_lvl)
	local attached_data = SentryGunBase._attach(pos, rot)
	if not attached_data then
		return
	end
	local unit = World:spawn_unit(Idstring("units/equipment/sentry_gun/sentry_gun"), pos, rot)
	local spawn_unit_card = spawn_interaction(pos, rot, "按[f]拾起哨戒机枪", func_a, unit)
	unit:base():setup(ammo_upgrade_lvl, armor_upgrade_lvl, attached_data)
	unit:brain():set_active(true)
	SentryGunBase.deployed = (SentryGunBase.deployed or 0) + 1
	if SentryGunBase.deployed >= 4 then
		managers.challenges:set_flag("sentry_gun_resources")
	end
	return unit
end
