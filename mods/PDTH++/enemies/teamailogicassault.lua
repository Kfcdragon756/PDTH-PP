local module = ... or D:module("PDTH++")
local TeamAILogicAssault = module:hook_class("TeamAILogicAssault")

module:hook("TeamAILogicAssault", "_update_cover", function(self, data)
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
end)