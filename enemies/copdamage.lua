local module = ... or D:module("PDTH++")

local CopDamage = module:hook_class("CopDamage")
module:hook(CopDamage, "damage_bullet", function(self, attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local attacked_by_local_player = attack_data.attacker_unit == managers.player:player_unit()

	local weapon_base
	if attacked_by_local_player then
		local inv_ext = attack_data.attacker_unit:inventory()
		weapon_base = inv_ext and inv_ext:equipped_unit():base()
	end

	local result

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name
		and attack_data.col_ray.body
		and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	local base_hs_mul = self._char_tweak.headshot_dmg_mul
	if head and base_hs_mul then
		if attacked_by_local_player then
			-- Weapons now have different headshot damage multipliers and they are affected by the sharpshooters crew bonus.
			local ss = managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 0)
			damage = damage * base_hs_mul * (weapon_base:headshot_multiplier() + (ss / 4.4))
		else
			damage = damage * base_hs_mul
		end
	elseif head then
		damage = self._health * 10
	else
		-- Aggressor only affects bodyshot damage and its varied per-weapon.
		if attacked_by_local_player then
			local agg = managers.player:synced_crew_bonus_upgrade_value("aggressor", 0)
			damage = damage + (weapon_base:bodyshot_multiplier() * agg)
		end
	end

	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, 100))
	damage = damage_percent * self._HEALTH_INIT_PRECENT

	local was_alive = not self._dead

	if damage >= self._health then
		if head then
			self:_spawn_head_gadget({
				position = attack_data.col_ray.body:position(),
				rotation = attack_data.col_ray.body:rotation(),
				dir = attack_data.col_ray.ray,
			})
		end

		attack_data.damage = self._health
		result = { type = "death", variant = attack_data.variant }

		--hitmarker compat.
		local hitmarkers = D:module("hitmarkers")
		if hitmarkers and hitmarkers:enabled() and attacked_by_local_player then
			if was_alive then
				managers.hud:confirm_hit(head, self._dead)
			end
		end

		self:die(attack_data.variant)
	else
		attack_data.damage = damage

		-- Shotguns cannot stun enemies
		local shot_effect = attacked_by_local_player and weapon_base:check_effect_mul() or 1
		if shot_effect == 1 then
			shot_effect = damage
		end

		local damage_effect = math.clamp(shot_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		local damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		local result_type = CopDamage.get_damage_type(self._char_tweak.damage.hurt_severity, damage_effect_percent)

		result = { type = result_type, variant = attack_data.variant }

		self._health = self._health - damage
		self._health_ratio = self._health / self._HEALTH_INIT

		--hitmarker compat.
		local hitmarkers = D:module("hitmarkers")
		if hitmarkers and hitmarkers:enabled() and attacked_by_local_player then
			if was_alive then
				managers.hud:confirm_hit(head, self._dead)
			end
		end
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
		}

		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end

		if attacked_by_local_player then
			self:_comment_death(attack_data.attacker_unit, self._unit:base()._tweak_table)
			self:_show_death_hint(self._unit:base()._tweak_table)
			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state
			managers.statistics:killed(data)
		elseif attack_data.attacker_unit:in_slot(managers.slot:get_mask("criminals_no_deployables")) then
			self:_AI_comment_death(attack_data.attacker_unit, self._unit:base()._tweak_table)
		elseif attack_data.attacker_unit:base().sentry_gun and Network:is_server() then
			local server_info = attack_data.weapon_unit:base():server_information()

			if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
				local owner_peer = managers.network:session():peer(server_info.owner_peer_id)
				if owner_peer then
					owner_peer:send_queued_sync(
						"sync_player_kill_statistic",
						data.name,
						data.head_shot,
						data.weapon_unit,
						data.variant
					)
				end
			else
				data.attacker_state = managers.player:current_state()
				managers.statistics:killed(data)
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if attacker:id() == -1 then
		attacker = self._unit
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height)
	self:_on_damage_received(attack_data)

	return result
end, true)
