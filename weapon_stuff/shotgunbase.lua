local module = ... or D:module("PDTH++")
local ShotgunBase = module:hook_class("ShotgunBase")
--Now we got per-pellet damage shotguns. For this sake, I think customize pellet each shot is important for rebalancing 2 shotguns in this game.
--So each shotgun will feel unique, and it will be good for playing experience.

module:hook(ShotgunBase, "reload_speed_multiplier", function(self)
	local multiplier = tweak_data.weapon[self._name_id].reload_speed
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
	return multiplier
end)

module:hook(ShotgunBase, "_fire_raycast", function(self, user_unit, from_pos, direction)
	local result = {}
	local hit_enemies = {}
	local col_rays = self._alert_events and {} or nil
	local weight = 0.1

	-- compute falloff damage based on distance
	local function compute_damage(col_ray)
		local dist = mvector3.distance(col_ray.unit:position(), user_unit:position())
		return (1 - math.min(1, math.max(0, dist - self._damage_near) / self._damage_far)) * self._damage
	end

	local function record_enemy_hit(col_ray)
		if not col_ray or not col_ray.unit then
			return
		end

		local enemy_key = col_ray.unit:key()
		hit_enemies[enemy_key] = true
	end

	local function try_autohit(autoaim_vec)
		local ratio = (self._autohit_current - self._autohit_data.MIN_RATIO)
			/ (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO)
		local autohit_chance = 1 - math.clamp(ratio, 0, 1)
		if autohit_chance > math.random() then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
			return true
		else
			self._autohit_current = self._autohit_current / (1 + weight)
			return false
		end
	end

	local autoaim_vec, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
	local use_autoaim = self._autoaim and autoaim_vec
	local pellet_count = tweak_data.weapon[self._name_id].pellet_amount

	for i = 1, pellet_count do
		local spread_direction = direction:spread(self:_get_spread(user_unit))
		local ray_to = mvector3.copy(spread_direction)
		mvector3.multiply(ray_to, self._range)
		mvector3.add(ray_to, from_pos)

		local col_ray = World:raycast(
			"ray",
			from_pos,
			ray_to,
			"slot_mask",
			self._bullet_slotmask,
			"ignore_unit",
			self._setup.ignore_units
		)
		if col_rays then
			if col_ray then
				table.insert(col_rays, col_ray)
			else
				table.insert(col_rays, { position = ray_to, ray = spread_direction })
			end
		end

		if use_autoaim then
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
				local damage = compute_damage(col_ray)
				if InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage) then
					record_enemy_hit(col_ray)
				end

				autoaim_vec = nil
				use_autoaim = false
			else
				if autoaim_vec then
					if try_autohit(autoaim_vec) then
						local damage = compute_damage(autoaim_vec)
						if InstantBulletBase:on_collision(autoaim_vec, self._unit, user_unit, damage) then
							record_enemy_hit(autoaim_vec)
						end
					end

					autoaim_vec = nil
					use_autoaim = false
				elseif col_ray then
					local damage = compute_damage(col_ray)
					if InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage) then
						record_enemy_hit(col_ray)
					end
				end
			end
		elseif col_ray then
			local damage = compute_damage(col_ray)
			if InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage) then
				record_enemy_hit(col_ray)
			end
		end
	end

	result.hit_enemy = next(hit_enemies) and true or false
	if self._alert_events then
		result.rays = #col_rays > 0 and col_rays or nil
	end

	managers.statistics:shot_fired({ hit = result.hit_enemy, weapon_unit = self._unit })

	return result
end)
