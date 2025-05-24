local module = ... or D:module("PDTH++")
local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")



module:hook(RaycastWeaponBase, "replenish", function(self)
	local ammo_max_multiplier = managers.player:equipped_upgrade_value("extra_start_out_ammo", "player", "extra_ammo_multiplier")
	self._ammo_max_per_clip = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")
	--GOD HATE YOU GL40
	if not self:cant_pick_ammo() then
		self._clip_amount_max = tweak_data.weapon[self._name_id].NR_CLIPS_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") + ammo_max_multiplier
	else
		self._clip_amount_max = tweak_data.weapon[self._name_id].NR_CLIPS_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase")
	end
	self._ammo_max = math.round(self._clip_amount_max * self._ammo_max_per_clip)
	self._ammo_total = self._ammo_max
	self._ammo_remaining_in_clip = self._ammo_max_per_clip
	self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
	self._extra_pickup = tweak_data.weapon[self._name_id].EXTRA_PICKUP or {0,0}
	self:update_damage()
end, true)


module:hook(RaycastWeaponBase, "add_ammo", function(self)
	if self:ammo_max() then
		return false
	end	
	if self:cant_pick_ammo() then
		return false
	end
	--for new bgh.
	local switch = managers.player:synced_crew_bonus_upgrade_value("more_ammo", 0)
	local add_amount = math.max(0, math.round(math.lerp(self._ammo_pickup[1] + self._extra_pickup[1] * switch, self._ammo_pickup[2] + self._extra_pickup[2] * switch, math.random())))
--[[	local add_amount
	if self._ammo_pickup[1] > 1 then
		add_amount = add_amount_o + math.max(math.round(self._ammo_pickup[1] * multiplier),2 * multiplier)
	else
		add_amount = math.max(0, math.round(math.lerp(self._ammo_pickup[1], self._ammo_pickup[2] + 2 * multiplier, math.random())))
	end]]
	self._ammo_total = math.clamp(self._ammo_total + add_amount, 0, self._ammo_max)
	return true
end, true)

module:hook(RaycastWeaponBase, "add_ammo_from_bag", function(self,availible)
	local gl40_add = 0.75
	if self:ammo_max() then
		return 0
	end
	local wanted
	if self:cant_pick_ammo() then
		wanted = (self._ammo_max - self._ammo_total) * gl40_add
	else
		wanted = 1 - self._ammo_total / self._ammo_max
	end
	local can_have 
	if self:cant_pick_ammo() then
		if availible > gl40_add then
			can_have = wanted
		elseif availible == gl40_add then
			can_have = gl40_add
		elseif availible < gl40_add then
			can_have = 0
		end
		self._ammo_total = math.min(self._ammo_max, self._ammo_total + math.ceil(can_have / gl40_add))
	else
		can_have = math.min(wanted, availible)
		self._ammo_total = math.min(self._ammo_max, self._ammo_total + math.ceil(can_have * self._ammo_max))
	end
	--for gl40 taking ammo from bag... this make sure it takes 75% of an ammo bag per shot.
	return can_have
end, true)

module:hook(RaycastWeaponBase, "cant_pick_ammo", function(self)
	return tweak_data.weapon[self._name_id].cant_pick_ammo
end, true)

module:hook(RaycastWeaponBase, "check_hs_mul", function(self)
	return tweak_data.weapon[self._name_id].hs_mul
end, true)

module:hook(RaycastWeaponBase, "check_effect_mul", function(self)
	if tweak_data.weapon[self._name_id].DAMAGE_EFFECT then
		return tweak_data.weapon[self._name_id].DAMAGE_EFFECT
	else
		return 1
	end
end, true)

module:hook(RaycastWeaponBase, "damage_multiplier", function()
	local multiplier = 1
	return multiplier
end, true)

module:hook(RaycastWeaponBase, "fire_rate_multiplier", function(self)
	return tweak_data.weapon[self._name_id].firerate_multiplier
end,true)

module:hook(RaycastWeaponBase,"reload_speed_multiplier", function(self)
	local multiplier = tweak_data.weapon[self._name_id].reload_speed
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
	return multiplier
end,true)

module:hook(RaycastWeaponBase, "chbk_bodyshot_mul", function(self)
	local multiplier
	if tweak_data.weapon[self._name_id].extra_damage then
		multiplier = tweak_data.weapon[self._name_id].extra_damage
	else
		multiplier = 0
	end
	return multiplier
end,true)

module:hook(RaycastWeaponBase, "_is_shooting", function(self)
	return self._shooting
end,true)

