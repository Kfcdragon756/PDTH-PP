local module = ... or DorHUD:module("PDTH++")
local PlayerDamage = module:hook_class("PlayerDamage")
--overhaul thick skin and protector

function PlayerDamage:_max_armor()
	return (self._ARMOR_INIT + managers.player:body_armor_value()) + managers.player:synced_crew_bonus_upgrade_value("protector", 0) + managers.player:thick_skin_value() * 0.3
end

--[[module:post_hook(PlayerDamage, "_regenerated", function(self)
	self._down_time = tweak_data.player.damage.DOWNED_TIME * managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 1)
end, false)]]

function PlayerDamage:_check_bleed_out()
	if self._health == 0 then
		self._bleed_out = true
		managers.player:set_player_state("bleed_out")
		self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
		self._bleed_out_health = tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 1)
		self._hurt_value = 0.2
		self:_drop_blood_sample()
		self:on_downed()
	elseif not self._said_hurt and 0.2 > self._health / self:_max_health() then
		self._said_hurt = true
		PlayerStandard.say_line(self, "g80x_plu")
	end
end

function PlayerDamage:down_time()
	return self._down_time * managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 1)
end

--[[function PlayerDamage:revive(helped_self)
	local arrested = self:arrested()
	managers.player:set_player_state("standard")
	self._unit:sound():play("critical_state_heart_stop")
	if not helped_self then
		PlayerStandard.say_line(self, "s05x_sin")
	end
	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	if not arrested then
		if true ~= helped_self then
			managers.challenges:count_up("revived")
		end
		local multiplier = managers.player:synced_crew_bonus_upgrade_value("more_blood_to_bleed", 1)
		self._down_time = math.max(tweak_data.player.damage.DOWNED_TIME_MIN, (self._down_time - tweak_data.player.damage.DOWNED_TIME_DEC * multiplier))
		self._health = math.round(tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * self:_max_health())
		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end
	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self._health,
		total = self:_max_health()
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()
end]]

-- less shaker.
function PlayerDamage:play_whizby(position)
	self._unit:sound():play_whizby({position = position})
	
	self._unit:camera():play_shaker("whizby", 0.1)
	
	managers.rumble:play("bullet_whizby")
end
 
 
function PlayerDamage:damage_bullet(attack_data)
	local damage_info = {
		result = {type = "hurt", variant = "bullet"},
		attacker_unit = attack_data.attacker_unit
	}
	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end
 
		self:_call_listeners(damage_info)
		return
	elseif self._invulnerable then
		self:_call_listeners(damage_info)
		return
	elseif self:incapacitated() then
		return
	elseif PlayerDamage:_look_for_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)
		return
	end
 
	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end
 
	self._unit:sound():play("player_hit")
	
	self._unit:camera():play_shaker("player_bullet_damage", 0.65)	
	
	managers.rumble:play("damage_bullet")
	self:_hit_direction(attack_data.col_ray)
	if self._bleed_out then
		self:_bleed_out_damage(attack_data)
		return
	end
 
	local health_subtracted = self:_calc_armor_damage(attack_data)
	
	-- ADDED:
	if self._armor <= 0 then
		self._unit:camera():play_shaker("player_bullet_damage", 0)
	end
 
	
	health_subtracted = health_subtracted or self:_calc_health_damage(attack_data)	
	self._next_allowed_dmg_t = TimerManager:game():time() + self._dmg_interval
	self._last_received_dmg = health_subtracted
	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out then
		managers.challenges:set_flag("bullet_to_bleed_out")
	end
 
	self:_call_listeners(damage_info)
end

function PlayerDamage:_damage_screen()
	if managers.player._equipment.specials.thick_skin then
		self._regenerate_timer = tweak_data.player.damage.REGENERATE_TIME + 0.5
	else
		self._regenerate_timer = tweak_data.player.damage.REGENERATE_TIME
	end
	self._hurt_value = 1 - math.clamp(0.8 - math.pow(self._armor / self:_max_armor(), 2), 0, 1)
	managers.environment_controller:set_hurt_value(self._hurt_value)
end
