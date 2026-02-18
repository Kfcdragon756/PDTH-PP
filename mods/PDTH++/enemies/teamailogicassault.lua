local module = ... or D:module("PDTH++")
local TeamAILogicAssault = module:hook_class("TeamAILogicAssault")

function TeamAILogicAssault._update_cover(data)
	local my_data = data.internal_data
	local cover_release_dis = 0
	local best_cover = my_data.best_cover
	local nearest_cover = my_data.nearest_cover
	local satisfied = true
	local want_cover = my_data.want_cover
	local my_pos = data.m_pos
	data.t = TimerManager:game():time()
	if want_cover then
		local find_new = my_data.focus_enemy and not my_data.moving_to_cover and (my_data.focus_enemy and (not best_cover or my_data.focus_enemy.dmg_t and data.t - my_data.focus_enemy.dmg_t < 4) or my_data.focus_enemy.verified_dis < 500)
		if find_new then
			local enemy_tracker = my_data.focus_enemy.unit:movement():nav_tracker()
			local threat_pos = enemy_tracker:field_position()
			local min_dis, max_dis
			if my_data.attitude == "engage" then
				min_dis = 0
			else
				min_dis = 0
			end
			if not best_cover or not CopLogicAttack._verify_cover(best_cover[1], threat_pos, min_dis, max_dis) then
				local my_vec = my_pos - threat_pos
				local my_vec_len = my_vec:length()
				local max_dis = my_vec_len + 0
				if my_data.attitude == "engage" then
					if my_vec_len > 0 then
						my_vec_len = 0
						mvector3.set_length(my_vec, my_vec_len)
					end
				elseif my_vec_len < 0 then
						my_vec_len = my_vec_len + 0
						mvector3.set_length(my_vec, my_vec_len)
				end
				local my_side_pos = threat_pos + my_vec
				mvector3.set_length(my_vec, max_dis)
				local furthest_side_pos = threat_pos + my_vec
				local min_threat_dis = min_dis + 0
				local cone_angle
				cone_angle = math.lerp(0, 0, math.min(1, my_vec_len / 0))
				local search_nav_seg
				if data.objective and data.objective.type == "defend_area" then
					search_nav_seg = data.objective.nav_seg
				end
				local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, min_threat_dis, search_nav_seg)
				if found_cover then
					local better_cover = {found_cover}
					CopLogicAttack._set_best_cover(data, my_data, better_cover)
					local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)
					if offset_pos then
						better_cover[5] = offset_pos
						better_cover[6] = yaw
					end
				else
					satisfied = false
				end
			end
		end
		local in_cover = my_data.in_cover
		if in_cover and my_data.focus_enemy then
			local threat_pos = my_data.focus_enemy.verified_pos
			in_cover[3], in_cover[4] = CopLogicAttack._chk_covered(data, my_pos, threat_pos, my_data.ai_visibility_slotmask)
		end
	else
		if nearest_cover and cover_release_dis < mvector3.distance(nearest_cover[1][1], my_pos) then
			CopLogicAttack._set_nearest_cover(my_data, nil)
		end
		if best_cover and cover_release_dis < mvector3.distance(best_cover[1][1], my_pos) then
			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	end
	local delay = satisfied and 4 or 1
	CopLogicBase.queue_task(my_data, my_data.cover_update_task_key, TeamAILogicAssault._update_cover, data, TimerManager:game():time() + delay)
end



-- ==调整AI队友的攻击目标优先级，使它们优先攻击特殊单位== ==Adjust bot teammates' attack priority, let them more likely to shoot special units==
TeamAILogicAssault.INTIMIDATE_PROGRESS = {}

local enemy_vec = Vector3()
local shield_slotmask = World:make_slot_mask(8)
local priority_muls = {  --倍数越低优先攻击的权重越高 the lower multiplier is, the prior the target will get hit
	taser = 0.5,
	spooc = 0.5,
	tank = 0.85,  --反正AI打熊也打不死 it takes a while to kill these dozers anyway
	sniper = 0.7
}
function TeamAILogicAssault._get_priority_enemy(data, enemies)
	if managers.groupai:state():whisper_mode() then
		return
	end

	local best_target
	local best_target_priority = math.huge
	local my_head_pos = data.unit:movement():m_head_pos()
	for key, enemy_data in pairs(enemies) do
		mvector3.set(enemy_vec, enemy_data.m_head_pos)
		local distance = mvector3.direction(enemy_vec, my_head_pos, enemy_vec)
		local alert_dt = enemy_data.alert_t and data.t - enemy_data.alert_t or 10000
		local dmg_dt = enemy_data.dmg_t and data.t - enemy_data.dmg_t or 10000
		local mark_dt = enemy_data.mark_t and data.t - enemy_data.mark_t or 10000

		local target_priority = distance
		if TeamAILogicAssault.INTIMIDATE_PROGRESS[key] and data.t - TeamAILogicAssault.INTIMIDATE_PROGRESS[key] < 4 then
			-- 不攻击玩家要抓的敌人 Disallow crew bots to shoot enemies that players trying to capture
			target_priority = -1
		elseif not enemy_data.verified then
			if alert_dt < 5 then
				target_priority = target_priority * 10
			else
				target_priority = -1
			end
		else
			if data.unit:raycast("ray", my_head_pos, enemy_data.m_head_pos, "slot_mask", shield_slotmask, "report") then
				-- 不要浪费子弹打 打不到的盾兵本体 Disallow crew bots to shoot enemies behind shields
				target_priority = -1
			else
				local tweak_table = enemy_data.unit:base()._tweak_table
				if priority_muls[tweak_table] then
					-- 根据上述倍率调整敌人的优先级 Adjust priority_muls
					target_priority = target_priority * priority_muls[tweak_table]
				end

				if mark_dt < 8 or dmg_dt < 2 then
					-- 提高被标记敌人和攻击玩家敌人的优先级 Increase priority of marked enemies and enemies shooting player
					target_priority = target_priority * 0.5
				end

				if data.internal_data.focus_enemy and data.internal_data.focus_enemy.unit:key() == key then
					-- 提高玩家正在攻击的敌人的优先级 Increase priority of enemies players' shooting at
					target_priority = target_priority * 0.75
				end
			end
		end

		if target_priority >= 0 and target_priority < best_target_priority then
			best_target = {
				enemy_data = enemy_data,
				reaction = "assault",
				key = key
			}
			best_target_priority = target_priority
		end
	end

	local best_target_priority_slot = math.ceil(best_target_priority / 300)
	return best_target, best_target, best_target_priority_slot, best_target_priority_slot
end
