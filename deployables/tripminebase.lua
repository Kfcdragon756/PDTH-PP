local TripMineBase = module:hook_class("TripMineBase")

function TripMineBase:_explode(col_ray)
	if not managers.network:session() then
		return
	end
	local player = managers.player:player_unit()
	if alive(player) then
		player:character_damage():damage_explosion({
			position = self._position,
			range = 500,
			damage = 10
		})
	else
		player = nil
	end
	self._unit:set_extension_update_enabled(Idstring("base"), false)
	self._deactive_timer = 5
	self:_play_sound_and_effects()
	local slotmask = managers.slot:get_mask("bullet_impact_targets")
	local damage_size = tweak_data.weapon.trip_mines.damage_size * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
	local bodies = World:find_bodies("intersect", "cylinder", self._ray_from_pos, self._ray_to_pos, damage_size, slotmask)
	local damage = tweak_data.weapon.trip_mines.damage * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
	local amount = 0
	local characters_hit = {}
	for _, hit_body in ipairs(bodies) do
		local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion
		local apply_dmg = hit_body:extension() and hit_body:extension().damage
		local dir, ray_hit
		if character and not characters_hit[hit_body:unit():key()] then
			local com = hit_body:center_of_mass()
			local ray_from = math.point_on_line(self._ray_from_pos, self._ray_to_pos, com)
			ray_hit = not World:raycast("ray", ray_from, com, "slot_mask", slotmask, "ignore_unit", {
				hit_body:unit()
			}, "report")
			if ray_hit then
				characters_hit[hit_body:unit():key()] = true
			end
		elseif apply_dmg or hit_body:dynamic() then
			ray_hit = true
		end
		if ray_hit then
			dir = hit_body:center_of_mass()
			mvector3.direction(dir, self._ray_from_pos, dir)
			if apply_dmg then
				local normal = dir
				hit_body:extension().damage:damage_explosion(player, normal, hit_body:position(), dir, damage)
				hit_body:extension().damage:damage_damage(player, normal, hit_body:position(), dir, damage)
				if hit_body:unit():id() ~= -1 then
					if player then
						managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, player, normal, hit_body:position(), dir, damage)
					else
						managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, damage)
					end
				end
			end
			if hit_body:unit():in_slot(managers.game_play_central._slotmask_physics_push) then
				hit_body:unit():push(5, dir * 500)
			end
			if character then
				self:_give_explosion_damage(col_ray, hit_body:unit(), damage)
				amount = amount + 1
			end
		end
	end
	if amount >= 2 then
		managers.challenges:count_up("dual_tripmine")
	end
	if amount >= 3 then
		managers.challenges:count_up("tris_tripmine")
	end
	if amount >= 4 then
		managers.challenges:count_up("quad_tripmine")
	end
	if managers.network:session() then
		if player then
			managers.network:session():send_to_peers_synched("sync_trip_mine_explode", self._unit, player, self._ray_from_pos, self._ray_to_pos, damage_size, damage)
		else
			managers.network:session():send_to_peers_synched("sync_trip_mine_explode_no_user", self._unit, self._ray_from_pos, self._ray_to_pos, damage_size, damage)
		end
	end
	if Network:is_server() then
		local alert_event = {
			"bulletfired",
			mvector3.copy(self._position),
			tweak_data.weapon.trip_mines.alert_radius,
			self._unit
		}
		managers.groupai:state():propagate_alert(alert_event)
	end
	self._unit:set_slot(0)
end