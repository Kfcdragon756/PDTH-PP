local tmp_vec3 = Vector3()
local module = ... or D:module("PDTH++")
local M79GrenadeBase = module:hook_class("M79GrenadeBase")

module:hook(M79GrenadeBase, "_detect_and_give_dmg", function(self, hit_pos)
	local slotmask = self._collision_slotmask
	local user_unit = self._user
	local dmg = self._damage
	local range = self._range
	local player = managers.player:player_unit()
	if alive(player) then
		player:character_damage():damage_explosion({
			position = hit_pos,
			range = range,
			damage = 15,
		})
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)

	managers.groupai:state():propagate_alert({
		"bulletfired",
		hit_pos,
		10000,
		user_unit,
	})

	local splinters = {
		mvector3.copy(hit_pos),
	}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range),
	}

	local pos = Vector3()
	for _, dir in ipairs(dirs) do
		mvector3.set(pos, dir)
		mvector3.add(pos, hit_pos)

		local splinter_ray = World:raycast("ray", hit_pos, pos, "slot_mask", slotmask)
		pos = (splinter_ray and splinter_ray.position or pos)
			- dir:normalized() * math.min(splinter_ray and splinter_ray.distance or 0, 10)

		local near_splinter = false
		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(pos, s_pos) < 900 then
				near_splinter = true
				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(pos))
		end
	end

	local characters_hit = {}
	local units_to_push = {}
	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		local hit_unit_key = hit_unit:key()
		local apply_dmg = hit_body:extension() and hit_body:extension().damage
		local character = (not characters_hit[hit_unit_key] or apply_dmg)
			and hit_unit:character_damage()
			and hit_unit:character_damage().damage_explosion

		units_to_push[hit_unit_key] = hit_unit

		local dir, len, damage, ray_hit
		if character then
			for _, s_pos in ipairs(splinters) do
				ray_hit = not World:raycast(
					"ray",
					s_pos,
					hit_body:center_of_mass(),
					"slot_mask",
					slotmask,
					"ignore_unit",
					{ hit_unit },
					"report"
				)
				if ray_hit then
					break
				end
			end
		elseif apply_dmg or hit_body:dynamic() then
			ray_hit = true
		end

		if ray_hit then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, hit_pos, dir)
			damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), self._curve_pow)
			damage = math.max(damage, 1)

			if apply_dmg then
				local normal = dir
				hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, damage)
				hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, damage)

				if hit_unit:id() ~= -1 then
					managers.network:session():send_to_peers_synched(
						"sync_body_damage_explosion",
						hit_body,
						user_unit,
						normal,
						hit_body:position(),
						dir,
						damage
					)
				end
			end

			if character and not characters_hit[hit_unit_key] then
				characters_hit[hit_unit_key] = true

				local action_data = {
					variant = "explosion",
					damage = damage,
					attacker_unit = user_unit,
					weapon_unit = self._owner,
					col_ray = self._col_ray or { position = hit_body:position(), ray = dir },
				}

				hit_unit:character_damage():damage_explosion(action_data)
			end
		end
	end

	for _, unit in pairs(units_to_push) do
		if alive(unit) then
			local is_character = unit:character_damage() and unit:character_damage().damage_explosion
			if not is_character or unit:character_damage():dead() then
				if
					is_character
					and unit:movement()._active_actions[1]
					and unit:movement()._active_actions[1]:type() == "hurt"
				then
					unit:movement()._active_actions[1]:force_ragdoll()
				end

				for i_u_body = 0, unit:num_bodies() - 1 do
					local u_body = unit:body(i_u_body)
					if u_body:enabled() and u_body:dynamic() then
						local body_mass = u_body:mass()
						local len = mvector3.direction(tmp_vec3, hit_pos, u_body:center_of_mass())
						local body_vel = u_body:velocity()
						local vel_dot = mvector3.dot(body_vel, tmp_vec3)
						local max_vel = 800
						if vel_dot < max_vel then
							local push_vel = (1 - len / range) * (max_vel - math.max(vel_dot, 0))
							mvector3.multiply(tmp_vec3, push_vel)
							u_body:push(body_mass, tmp_vec3)
						end
					end
				end
			end
		end
	end

	managers.challenges:reset_counter("m79_law_simultaneous_kills")
	managers.challenges:reset_counter("m79_simultaneous_specials")
	managers.statistics:shot_fired({
		hit = next(characters_hit) and true or false,
		weapon_unit = self._owner,
	})
end)
