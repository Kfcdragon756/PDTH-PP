local module = ... or D:module("dozer_visor_sync_fix")
local InstantBulletBase = module:hook_class("InstantBulletBase")

local ids_glass = Idstring("glass")

local function is_tank_visor(col_ray)
	if not col_ray or not alive(col_ray.unit) or not alive(col_ray.body) then
		return false
	end

	local base = col_ray.unit:base()
	return base and base._tweak_table == "tank" and col_ray.body:name() == ids_glass
end

local function channel_will_break(body_damage, channel, incoming_damage)
	local current_damage = body_damage._damage and tonumber(body_damage._damage[channel])
	local endurance = body_damage._endurance and body_damage._endurance[channel]
	local threshold = endurance and endurance._endurance and tonumber(endurance._endurance[channel])

	if current_damage == nil or threshold == nil then
		return false
	end

	return current_damage + incoming_damage >= threshold
end

local function visor_will_break(col_ray, damage)
	local body_ext = col_ray.body:extension()
	local body_damage = body_ext and body_ext.damage
	if not body_damage then
		return false
	end

	-- InstantBulletBase applies one point to the "bullet" endurance channel and
	-- the weapon's actual damage to the generic "damage" channel.
	return channel_will_break(body_damage, "bullet", 1)
		or channel_will_break(body_damage, "damage", tonumber(damage) or 0)
end

local function send_body_damage_early(col_ray, user_unit, damage)
	local session = managers.network and managers.network:session()
	if not session or col_ray.unit:id() == -1 then
		return
	end

	if alive(user_unit) and user_unit:id() ~= -1 then
		session:send_to_peers_synched(
			"sync_body_damage_bullet",
			col_ray.body,
			user_unit,
			col_ray.normal,
			col_ray.position,
			col_ray.direction,
			damage
		)
	else
		session:send_to_peers_synched(
			"sync_body_damage_bullet_no_attacker",
			col_ray.body,
			col_ray.normal,
			col_ray.position,
			col_ray.direction,
			damage
		)
	end
end

module:pre_hook(InstantBulletBase, "on_collision", function(self, col_ray, weapon_unit, user_unit, damage)
	if not is_tank_visor(col_ray) or not visor_will_break(col_ray, damage) then
		return
	end

	-- The original function sends this RPC only after applying local body damage.
	-- On the breaking hit, the glass destruction sequence may already have made
	-- the body invalid by then. Send the same native RPC once while the body is
	-- still valid. The original late send is left intact; after the first event
	-- breaks the remote glass, the duplicate should be ignored or have no next
	-- endurance stage to activate.
	send_body_damage_early(col_ray, user_unit, damage)
	module:log(3, "InstantBulletBase:on_collision", "pre-synced breaking Bulldozer visor hit", col_ray.unit, damage)
end, false)