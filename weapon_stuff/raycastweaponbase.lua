local module = ... or D:module("PDTH++")
local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")

module:hook(RaycastWeaponBase, "replenish", function(self)
	local ammo_max_multiplier =
		managers.player:equipped_upgrade_value("extra_start_out_ammo", "player", "extra_ammo_multiplier")

	local weapon_tdata = self:weapon_tweak_data()
	self._ammo_max_per_clip = weapon_tdata.CLIP_AMMO_MAX
		+ managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

	self._clip_amount_max = weapon_tdata.NR_CLIPS_MAX
		+ managers.player:upgrade_value(self._name_id, "clip_amount_increase")

	if not self:pickup_disabled() then
		self._clip_amount_max = self._clip_amount_max + ammo_max_multiplier
	end

	self._ammo_max = math.round(self._clip_amount_max * self._ammo_max_per_clip)
	self._ammo_total = self._ammo_max
	self._ammo_remaining_in_clip = self._ammo_max_per_clip
	self._ammo_pickup = weapon_tdata.AMMO_PICKUP
	self._extra_pickup = weapon_tdata.EXTRA_PICKUP or { 0, 0 }
	self._picked_up = 0
	self:update_damage()
end, true)

module:hook(RaycastWeaponBase, "add_ammo", function(self)
	if self:ammo_max() or self:pickup_disabled() then
		return false
	end

	--for new bgh.
	local switch = managers.player:synced_crew_bonus_upgrade_value("more_ammo", 0)
	self._picked_up = self._picked_up + math.max(
		0,
		math.lerp(
				self._ammo_pickup[1] + self._extra_pickup[1] * switch,
				self._ammo_pickup[2] + self._extra_pickup[2] * switch,
				math.random()
		)
	)
	local add_amount = 0
	while ( self._picked_up >= 1 )
		do
		self._picked_up = self._picked_up - 1
		add_amount = add_amount + 1
	end
	--This allows you pickup 1 ammo while you picked up 2 0.5s.
	--[[local add_amount = math.max(
		0,
		math.round(
			math.lerp(
				self._ammo_pickup[1] + self._extra_pickup[1] * switch,
				self._ammo_pickup[2] + self._extra_pickup[2] * switch,
				math.random()
			)
		)
	)]]
	--[[	local add_amount
	if self._ammo_pickup[1] > 1 then
		add_amount = add_amount_o + math.max(math.round(self._ammo_pickup[1] * multiplier),2 * multiplier)
	else
		add_amount = math.max(0, math.round(math.lerp(self._ammo_pickup[1], self._ammo_pickup[2] + 2 * multiplier, math.random())))
	end]]
	self._ammo_total = math.clamp(self._ammo_total + add_amount, 0, self._ammo_max)
	return true
end, true)

module:hook(RaycastWeaponBase, "add_ammo_from_bag", function(self, available)
	if self:ammo_max() then
		return 0
	end

	local gl40_add = 0.75

	local wanted = 1 - self._ammo_total / self._ammo_max
	if self:pickup_disabled() then
		wanted = (self._ammo_max - self._ammo_total) * gl40_add
	end

	local can_have
	if self:pickup_disabled() then
		if available > gl40_add then
			can_have = wanted
		elseif available == gl40_add then
			can_have = gl40_add
		elseif available < gl40_add then
			can_have = 0
		end

		self._ammo_total = math.min(self._ammo_max, self._ammo_total + math.ceil(can_have / gl40_add))
	else
		can_have = math.min(wanted, available)
		self._ammo_total = math.min(self._ammo_max, self._ammo_total + math.ceil(can_have * self._ammo_max))
	end

	--for gl40 taking ammo from bag... this make sure it takes 75% of an ammo bag per shot.
	return can_have
end, true)

module:hook(RaycastWeaponBase, "pickup_disabled", function(self)
	return self:weapon_tweak_data().pickup_disabled
end, true)

module:hook(RaycastWeaponBase, "headshot_multiplier", function(self)
	return self:weapon_tweak_data().headshot_multiplier or 0
end, true)

module:hook(RaycastWeaponBase, "bodyshot_multiplier", function(self)
	return self:weapon_tweak_data().bodyshot_multiplier or 0
end, true)

module:hook(RaycastWeaponBase, "check_effect_mul", function(self)
	return self:weapon_tweak_data().DAMAGE_EFFECT or 1
end, true)

module:hook(RaycastWeaponBase, "damage_multiplier", function()
	return 1
end, true)

module:hook(RaycastWeaponBase, "fire_rate_multiplier", function(self)
	return self:weapon_tweak_data().firerate_multiplier
end, true)

module:hook(RaycastWeaponBase, "reload_speed_multiplier", function(self)
	local multiplier = self:weapon_tweak_data().reload_speed
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
	return multiplier
end, true)

module:hook(RaycastWeaponBase, "_is_shooting", function(self)
	return self._shooting
end, true)
