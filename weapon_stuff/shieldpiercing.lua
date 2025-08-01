local module = ... or D:module("PDTH++")

if RequiredScript == "lib/managers/gameplaycentralmanager" then
	local GamePlayCentralManager = module:hook_class("GamePlayCentralManager")

	function GamePlayCentralManager:queue_fire_raycast(expire_t, weapon_unit, ...)
		self._queue_fire_raycast = self._queue_fire_raycast or {}
		local data = {
			expire_t = expire_t,
			weapon_unit = weapon_unit,
			data = { ... },
		}
		table.insert(self._queue_fire_raycast, data)
	end

	function GamePlayCentralManager:_flush_queue_fire_raycast()
		local i = 1
		while i <= #self._queue_fire_raycast do
			local ray_data = self._queue_fire_raycast[i]
			if ray_data.expire_t < Application:time() then
				table.remove(self._queue_fire_raycast, i)
				local data = ray_data.data
				local user_unit = data[1]
				if alive(ray_data.weapon_unit) and alive(user_unit) then
					ray_data.weapon_unit:base():_fire_raycast(unpack(data))
				end
			else
				i = i + 1
			end
		end
	end

	module:post_hook(GamePlayCentralManager, "init", function(self)
		self._queue_fire_raycast = {}
	end, false)

	module:post_hook(GamePlayCentralManager, "end_update", function(self)
		self:_flush_queue_fire_raycast()
	end, false)
end

if RequiredScript == "lib/units/weapons/raycastweaponbase" then
	local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")

	module:post_hook(RaycastWeaponBase, "init", function(self)
		self._shoot_through_data = { from = Vector3() }
		self._can_shoot_through_shield = tweak_data.weapon[self._name_id].can_shoot_through_shield
		self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
	end, false)

	module:post_hook(RaycastWeaponBase, "setup", function(self)
		self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16)
	end)

	local mvec_to = Vector3()
	local mvec_spread_direction = Vector3()
	module:hook(RaycastWeaponBase, "_fire_raycast", function(self,user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
		if not self._can_shoot_through_shield or not user_unit:base().is_local_player then
			return module:call_orig(RaycastWeaponBase, "orig_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
		end

		local result = {}
		local hit_unit
		local ray_distance = shoot_through_data and shoot_through_data.ray_distance or self._weapon_range or 20000
		local spread = self:_get_spread(user_unit)
		mvector3.set(mvec_spread_direction, direction)
		if spread then
			mvector3.spread(mvec_spread_direction, spread)
		end

		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)
		local damage = self._damage * (dmg_mul or 1)
		local ray_from_unit = shoot_through_data
				and alive(shoot_through_data.ray_from_unit)
				and shoot_through_data.ray_from_unit
			or nil
		local col_ray = (ray_from_unit or World):raycast(
			"ray",
			from_pos,
			mvec_to,
			"slot_mask",
			self._bullet_slotmask,
			"ignore_unit",
			self._setup.ignore_units
		)

		local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction)
		if self._autoaim then
			local weight = 0.1
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
				hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
			-- elseif col_ray and col_ray.unit:in_slot(managers.slot:get_mask("players")) then
			-- 	self._autohit_current = (self._autohit_current + weight) / (1 + weight)
			-- 	hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
			elseif autoaim then
				local autohit_chance = 1
					- math.clamp(
						(self._autohit_current - self._autohit_data.MIN_RATIO)
							/ (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO),
						0,
						1
					)
				if autohit_chance > math.random() then
					self._autohit_current = (self._autohit_current + weight) / (1 + weight)
					hit_unit = InstantBulletBase:on_collision(autoaim, self._unit, user_unit, damage)
				else
					self._autohit_current = self._autohit_current / (1 + weight)
				end
			elseif col_ray then
				hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
			end

			self._shot_fired_stats_table.hit = hit_unit and true or false
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		elseif col_ray then
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		end

		if col_ray and col_ray.distance > 600 or not col_ray then
			self._obj_fire:m_position(self._trail_effect_table.position)
			mvector3.set(self._trail_effect_table.normal, mvec_spread_direction)
			local trail = World:effect_manager():spawn(self._trail_effect_table)
			if col_ray then
				World:effect_manager()
					:set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
			end
		end

		result.hit_enemy = hit_unit
		if self._alert_events then
			result.rays = { col_ray }
		end

		if not col_ray or col_ray and not col_ray.unit then
			return result
		end

		local kills = nil
		if hit_unit then
			if not self._can_shoot_through_enemy then
				return result
			end
			local killed = hit_unit.type == "death"
			kills = (shoot_through_data and shoot_through_data.kills or 0) + (killed and 1 or 0)
		end

		self._shoot_through_data.kills = kills
		if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
			return result
		end

		local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
		local is_shoot_through, is_shield = nil
		if not hit_unit then
			if col_ray.unit:in_slot(managers.slot:get_mask("world_geometry")) then
				is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))
			else
				is_shield = col_ray.unit:in_slot(8) and alive(col_ray.unit:parent())
			end
		end

		if not hit_unit and not is_shoot_through and not is_shield then
			return result
		end

		self._shoot_through_data.has_passed_shield = has_passed_shield or is_shield
		self._shoot_through_data.ray_from_unit = (hit_unit or is_shield) and col_ray.unit
		self._shoot_through_data.ray_distance = ray_distance - col_ray.distance
		mvector3.set(self._shoot_through_data.from, mvec_spread_direction)
		mvector3.multiply(self._shoot_through_data.from, is_shield and 5 or 40)
		mvector3.add(self._shoot_through_data.from, col_ray.position)
		managers.game_play_central:queue_fire_raycast(
			Application:time() + 0.0125,
			self._unit,
			user_unit,
			self._shoot_through_data.from,
			mvector3.copy(direction),
			dmg_mul,
			shoot_player,
			self._shoot_through_data
		)
		return result
	end)
end
