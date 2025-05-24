--this path was just for test purpose.
--local path = "L:/SteamLibrary/steamapps/common/PAYDAY The Heist/logs/spread.txt"
local module = ... or D:module("PDTH++")
if RequiredScript == "lib/managers/playermanager" then
	local PlayerManager = module:hook_class("PlayerManager")

	module:hook(PlayerManager, "add_selected_equipment", function(self, equipment_amount, oppotune, amount_limit)
		--equipment_amount 增加的装备数量 int
		--oppotune 拾取几率(1 为满概率) int
		--amount_limit 装备数目上限 int
		--local player = managers.player:player_unit()
		local equipment = self._equipment.selections[self._equipment.selected_index]
		local selfEquipment = self:get_equipment()
		local selfRandom = math.random(oppotune, 1)

		if not selfEquipment or not equipment then
			return
		end

		if equipment.amount < amount_limit and selfRandom == 1 then
			equipment.amount = equipment.amount + equipment_amount
		end

		if equipment.amount > amount_limit then
			equipment.amount = amount_limit
		end

		managers.hud:set_item_amount(self._equipment.selected_index, equipment.amount)
	end)

	module:hook(PlayerManager, "get_equipment", function(self)
		local get_e = nil
		for i, equipments in ipairs(self._equipment.selections) do
			get_e = equipments.equipment
		end
		return tostring(get_e)
	end)

	--module:hook(PlayerManager, "get_weapon", function(self)
	--	local get_w = nil
	--	for _, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
	--		get_w = weapon
	--	end
	--	return tostring(get_w)
	--end)
	--Thanks Vinight for help.
end

if RequiredScript == "lib/units/pickups/ammoclip" then
	local AmmoClip = module:hook_class("AmmoClip")
	module:hook(AmmoClip, "_pickup", function(self, unit)
		if self._picked_up then
			return
		end

		local inventory = unit:inventory()
		if not unit:character_damage():dead() and inventory then
			local picked_up = false
			for _, weapon in pairs(inventory:available_selections()) do
				picked_up = weapon.unit:base():add_ammo() or picked_up
			end
			if picked_up then
				self._picked_up = true
				if Network:is_client() then
					managers.network:session():send_to_host("sync_pickup", self._unit)
				end

				local getEquipment = managers.player:get_equipment()
				if getEquipment == "trip_mine" then
					managers.player:add_selected_equipment(1, -2, 10)
				end

				unit:sound():sync_play("pickup_ammo")
				self:consume()
				return true
			end
		end
		return false
	end)
end

if RequiredScript == "lib/units/weapons/raycastweaponbase" then
	local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")

	module:hook(RaycastWeaponBase, "add_equipments_from_bag", function(self)
		local getEquipment = managers.player:get_equipment()
		if getEquipment == "trip_mine" then
			managers.player:add_selected_equipment(5, 1, 10)
		end

		return true
	end)
end

if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" then
	local AmmoBagBase = module:hook_class("AmmoBagBase")
	module:post_hook(AmmoBagBase, "_take_ammo", function(self, unit)
		local inventory = unit:inventory()
		if inventory then
			for _, weapon in pairs(inventory:available_selections()) do
				weapon.unit:base():add_equipments_from_bag()
				return true
			end
		end
	end)
end
