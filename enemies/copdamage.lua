local module = ... or D:module("PDTH++")
local CopDamage = module:hook_class("CopDamage")

module:hook(CopDamage, "damage_bullet", function(self,attack_data)
	if not managers.player:player_unit() then
		module:call_orig(CopDamage, "damage_bullet", self, attack_data)
		return
	end	
	if self._dead or self._invulnerable then
		return
	end
	local result
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage
	if head then
		if attack_data.attacker_unit == managers.player:player_unit() then
		--this will make the headshot mult being more customized.
			if self._char_tweak.headshot_dmg_mul then
				damage = damage * self._char_tweak.headshot_dmg_mul * (attack_data.attacker_unit:inventory():equipped_unit():base():check_hs_mul() + (managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 0) / 4.4))
			else
				damage = self._health * 10
			end
		else
			if self._char_tweak.headshot_dmg_mul then
				damage = damage * self._char_tweak.headshot_dmg_mul
			else
				damage = self._health * 10
			end
		end
	else
	--Make aggressor effect being more various and not affect dozer visor damage and headshot damage. Let sharpshooter go for headshots.
		if attack_data.attacker_unit == managers.player:player_unit() then
			damage = damage + (attack_data.attacker_unit:inventory():equipped_unit():base():chbk_bodyshot_mul() * managers.player:synced_crew_bonus_upgrade_value("aggressor", 0))
		end
	end
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, 100))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	if damage >= self._health then
		if head then
			self:_spawn_head_gadget({
				position = attack_data.col_ray.body:position(),
				rotation = attack_data.col_ray.body:rotation(),
				dir = attack_data.col_ray.ray
			})
		end
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}
		--hitmarker compat.
		local hitmarkers = D:module("hitmarkers")
		if hitmarkers and hitmarkers:enabled() then
			local was_alive = not self._dead
			if was_alive and attack_data.attacker_unit == managers.player:player_unit() then
				managers.hud:confirm_hit(not self._head_body_name or not attack_data.col_ray.body or attack_data.col_ray.body:name() == self._ids_head_body_name, true)
			end
		end
		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		local shot_effect
		--new shotgun mechanic will make it cannot knock back anyone, so I made this to make sure they can still knock someone back.
		if attack_data.attacker_unit == managers.player:player_unit() then
			shot_effect = attack_data.attacker_unit:inventory():equipped_unit():base():check_effect_mul()
		else
			shot_effect = 1
		end
		if shot_effect == 1  then
			shot_effect = damage
		end
		local damage_effect = math.clamp(shot_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		local damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		local result_type = CopDamage.get_damage_type(self._char_tweak.damage.hurt_severity, damage_effect_percent)
		result = {
			type = result_type,
			variant = attack_data.variant
		}
		self._health = self._health - damage
		self._health_ratio = self._health / self._HEALTH_INIT
		local hitmarkers = D:module("hitmarkers")
		--hitmarker compat.
		if hitmarkers and hitmarkers:enabled() then
			local was_alive = not self._dead
			if was_alive and attack_data.attacker_unit == managers.player:player_unit() then
				managers.hud:confirm_hit(not self._head_body_name or not attack_data.col_ray.body or attack_data.col_ray.body:name() == self._ids_head_body_name, self._dead)
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
			variant = attack_data.variant
		}
		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end
		if attack_data.attacker_unit == managers.player:player_unit() then
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
					owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant)
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

--not working as expected so still using module hook.
--[[function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end
	local result
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage
	if head then
		if managers.player:player_unit() and attack_data.attacker_unit == managers.player:player_unit() then
		--this will make the headshot mult being more customized.
			if self._char_tweak.headshot_dmg_mul then
				damage = damage * self._char_tweak.headshot_dmg_mul * (attack_data.attacker_unit:inventory():equipped_unit():base():check_hs_mul() + (managers.player:synced_crew_bonus_upgrade_value("sharpshooters", 0) / 4.4))
			else
				damage = self._health * 10
			end
		else
			if self._char_tweak.headshot_dmg_mul then
				damage = damage * self._char_tweak.headshot_dmg_mul
			else
				damage = self._health * 10
			end
		end
	else
	--Make aggressor effect being more various and not affect dozer visor damage and headshot damage. Let sharpshooter go for headshots.
		if managers.player:player_unit() and attack_data.attacker_unit == managers.player:player_unit() then
			damage = damage + (attack_data.attacker_unit:inventory():equipped_unit():base():chbk_bodyshot_mul() * managers.player:synced_crew_bonus_upgrade_value("aggressor", 0))
		end
	end
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, 100))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	if damage >= self._health then
		if head then
			self:_spawn_head_gadget({
				position = attack_data.col_ray.body:position(),
				rotation = attack_data.col_ray.body:rotation(),
				dir = attack_data.col_ray.ray
			})
		end
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}
		self:die(attack_data.variant)
	else
		attack_data.damage = damage
		local shot_effect = damage
		--new shotgun mechanic will make it cannot knock back anyone, so I made this to make sure they can still knock someone back.
		if managers.player:player_unit() and attack_data.attacker_unit == managers.player:player_unit() then
			shot_effect = attack_data.attacker_unit:inventory():equipped_unit():base():check_effect_mul()
		end
		local damage_effect = math.clamp(shot_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		local damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		local result_type = CopDamage.get_damage_type(self._char_tweak.damage.hurt_severity, damage_effect_percent)
		result = {
			type = result_type,
			variant = attack_data.variant
		}
		self._health = self._health - damage
		self._health_ratio = self._health / self._HEALTH_INIT
	end
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}
		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end
		if attack_data.attacker_unit == managers.player:player_unit() then
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
					owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant)
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
end]]