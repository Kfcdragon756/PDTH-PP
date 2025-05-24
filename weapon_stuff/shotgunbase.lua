local module = ... or D:module("PDTH++")
local ShotgunBase = module:hook_class("ShotgunBase")
--Now we got per-pellet damage shotguns. For this sake, I think customize pellet each shot is important for rebalancing 2 shotguns in this game.
--So each shotgun will feel unique, and it will be good for playing experience.

module:hook(ShotgunBase, "reload_speed_multiplier", function(self)
	local multiplier = tweak_data.weapon[self._name_id].reload_speed
	multiplier = multiplier * managers.player:synced_crew_bonus_upgrade_value("speed_reloaders", 1)
	return multiplier
end)

function ShotgunBase:_fire_raycast(user_unit, from_pos, direction)
	local result = {}
	local hit_enemies = {}
	local hit_something, col_rays
	if self._alert_events then
		col_rays = {}
	end
	local damage = self._damage
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
	local weight = 0.1
	local enemy_died = false
	local function hit_enemy(col_ray)
		if InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage) then
			local enemy_key = col_ray.unit:key()
			if not hit_enemies[enemy_key] --or col_ray.unit:character_damage():is_head(col_ray.body) then
			then
				hit_enemies[enemy_key] = col_ray
			end
		end
	end
	local x = tweak_data.weapon[self._name_id].pellet_amount
	for i = 1, x do
		local spread_direction = direction:spread(self:_get_spread(user_unit))
		local ray_to = mvector3.copy(spread_direction)
		mvector3.multiply(ray_to, self._range)
		mvector3.add(ray_to, from_pos)
		local col_ray = World:raycast("ray", from_pos, ray_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		if col_rays then
			if col_ray then
				table.insert(col_rays, col_ray)
			else
				table.insert(col_rays, {position = ray_to, ray = spread_direction})
			end
		end
		if self._autoaim and autoaim then
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
				hit_enemy(col_ray)
				autoaim = false
			else
				autoaim = false
				local autohit = self:check_autoaim(from_pos, direction, self._range)
				if autohit then
					local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)
					if autohit_chance > math.random() then
						self._autohit_current = (self._autohit_current + weight) / (1 + weight)
						hit_something = true
						hit_enemy(autohit)
					else
						self._autohit_current = self._autohit_current / (1 + weight)
					end
				elseif col_ray then
					hit_something = true
					hit_enemy(col_ray)
				end
			end
		elseif col_ray then
			hit_something = true
			hit_enemy(col_ray)
		end
	end
	for _, col_ray in pairs(hit_enemies) do
		local dist = mvector3.distance(col_ray.unit:position(), user_unit:position())
		local damage = (1 - math.min(1, math.max(0, dist - self._damage_near) / self._damage_far)) * self._damage
		InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
	end
	result.hit_enemy = next(hit_enemies) and true or false
	result.rays = #col_rays > 0 and col_rays
	managers.statistics:shot_fired({
		hit = result.hit_enemy,
		weapon_unit = self._unit
	})
	return result
end