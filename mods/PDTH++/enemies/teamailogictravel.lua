local module = ... or D:module("PDTH++")
local TeamAILogicTravel = module:hook_class("TeamAILogicTravel")

module:hook("TeamAILogicTravel", "_determine_destination_occupation", function(self, data, objective)
	local occupation
	if objective.type == "investigate_area" then
		if objective.guard_obj then
			occupation = managers.groupai:state():verify_occupation_in_area(objective) or objective.guard_obj
			occupation.type = "guard"
		else
			occupation = managers.groupai:state():find_occupation_in_area(objective.nav_seg)
		end
	elseif objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		else
			local pos = objective.pos or managers.navigation._nav_segments[objective.nav_seg].pos
			local cover = managers.navigation:find_cover_in_nav_seg_1(objective.nav_seg)
			local cover_entry
			if cover then
				local cover_entry = {cover}
				occupation = {type = "defend", cover = cover_entry}
			else
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = objective.pos,
					radius = objective.radius
				}
			end
		end
	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		local follow_tracker = objective.follow_unit:movement():nav_tracker()
		local follow_pos = follow_tracker:field_position()
		local threat_pos
		local max_dist = managers.groupai:state():get_assault_mode() and 40 or 40
		local dist2 = mvector3.distance_sq(follow_pos, data.m_pos)
		local zdist = math.abs(follow_pos.z - data.m_pos.z)
		if dist2 > max_dist * max_dist * 2 or zdist > 40 then
			threat_pos = follow_pos
		elseif data.internal_data.focus_enemy then
			local threat_tracker = data.internal_data.focus_enemy.unit:movement():nav_tracker()
			threat_pos = threat_tracker:field_position()
		else
			threat_pos = follow_pos - data.m_pos
			mvector3.set_length(threat_pos, 40)
			mvector3.add(threat_pos, follow_pos)
		end
		local cover = managers.navigation:find_cover_near_pos_1(follow_pos, threat_pos, 40, 40, data.internal_data.called)
		if cover then
			local cover_entry = {cover}
			occupation = {type = "defend", cover = cover_entry}
		else
			local max_dist
			if objective.called then
				max_dist = 40
			end
			local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist)
			occupation = {type = "defend", pos = to_pos}
		end
	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {tracker_from = revive_u_tracker, trace = true}
		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end
		local stand_dis
		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 40
		else
			stand_dis = 40
			local mid_pos = mvector3.copy(revive_u_fwd)
			mvector3.multiply(mid_pos, -20)
			mvector3.add(mid_pos, revive_u_pos)
			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end
		local rand_side_mul = math.random() > 0.5 and 1 or -1
		local revive_pos = mvector3.copy(revive_u_right)
		mvector3.multiply(revive_pos, rand_side_mul * stand_dis)
		mvector3.add(revive_pos, revive_u_pos)
		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)
		if ray_res then
			local opposite_pos = mvector3.copy(revive_u_right)
			mvector3.multiply(opposite_pos, -rand_side_mul * stand_dis)
			mvector3.add(opposite_pos, revive_u_pos)
			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)
			if opposite_ray_res then
				if mvector3.distance(ray_params.trace[1], revive_u_pos) > mvector3.distance(revive_pos, revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end
			else
				revive_pos = ray_params.trace[1]
			end
		else
			revive_pos = ray_params.trace[1]
		end
		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math.UP)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	end
	return occupation
end)


function TeamAILogicTravel._update_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = TeamAILogicIdle._detect_enemies(data, my_data)
	local enemies = my_data.detected_enemies
	local focus_enemy, focus_type, focus_enemy_key
	local target, threat, target_prio_slot = TeamAILogicAssault._get_priority_enemy(data, enemies)
	if target then
		focus_enemy = target.enemy_data
		focus_type = target.reaction
		focus_enemy_key = target.key
	end

	if focus_enemy then
		focus_enemy.nearly_visible = TeamAILogicIdle._chk_is_enemy_nearly_visible(data, focus_enemy)
		if my_data.focus_enemy and my_data.focus_enemy.unit:key() ~= focus_enemy_key then
			CopLogicAttack._cancel_flanking_attempt(data, my_data)
		end

	end

	my_data.focus_enemy = focus_enemy
	if focus_type then
		local objective = data.objective
		local objective_interrupted, objective_block
		local dont_exit = false
		if data.unit:movement():chk_action_forbidden("walk") then
			dont_exit = true
		elseif objective then
			local interrupt = objective.interrupt_on
			if interrupt == "contact" then
				objective_interrupted = true
			elseif interrupt == "obstructed" then
				if TeamAILogicIdle.is_obstructed(data, data.objective) then
					objective_interrupted = true
				else
					objective_block = true
				end
			elseif objective.type ~= "follow" then
				objective_block = true
			end

			if objective.type == "follow" then
				local max_dist = managers.groupai:state():get_assault_mode() and 800 or 1500
				local dist2 = mvector3.distance_sq(data.objective.follow_unit:movement():m_pos(), data.m_pos)
				local zdist = math.abs(data.objective.follow_unit:movement():m_pos().z - data.m_pos.z)
				if my_data.called or target_prio_slot > 3 and (dist2 > max_dist * max_dist or zdist > 300) or target_prio_slot <= 3 and (dist2 > max_dist * max_dist * 2 or zdist > 600) then
					dont_exit = true
				end

				-- 新增：跟随阶段的额外保护——被叫回或尚未真正跟上时，不要切到 Assault
				if objective.called then
					dont_exit = true
				else
					local fpos = objective.follow_unit:movement():m_pos()
					local d2 = mvector3.distance_sq(fpos, data.m_pos)
					if d2 > 400 * 400 then
						dont_exit = true
					end
				end
			end
		end

		if objective_interrupted and not dont_exit then
			managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective)
			return
		elseif not objective_block then
			-- 限制在跟随阶段切换到 Assault（除非已满足退出条件）
			if focus_type == "assault" and target_prio_slot < 4 and not dont_exit and (not objective or objective.type ~= "follow") then
				my_data.exiting = true
				CopLogicBase._exit(data.unit, "assault")
				return
			elseif focus_type == "assault" then
				TeamAILogicAssault._upd_aim(data, my_data)
				TeamAILogicAssault._chk_change_weapon(data, my_data)
			end
		end
	end

	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
		local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)
		if civ then
			my_data._intimidate_t = data.t
			if not my_data.focus_enemy then
				CopLogicBase._set_attention_on_unit(data, civ)
				local key = "RemoveAttentionOnUnit" .. tostring(data.unit:key())
				CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, data, data.t + 1.5)
			end

		end

	end

	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._update_enemy_detection, data, data.t + delay)
end




--[[module:hook("TeamAILogicTravel", "_update_enemy_detection", function(self, data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = TeamAILogicIdle._detect_enemies(data, my_data)
	local enemies = my_data.detected_enemies
	local focus_enemy, focus_type, focus_enemy_key
	local target, threat, target_prio_slot = TeamAILogicAssault._get_priority_enemy(data, enemies)
	if target then
		focus_enemy = target.enemy_data
		focus_type = target.reaction
		focus_enemy_key = target.key
	end
	if focus_enemy then
		focus_enemy.nearly_visible = TeamAILogicIdle._chk_is_enemy_nearly_visible(data, focus_enemy)
		if my_data.focus_enemy and my_data.focus_enemy.unit:key() ~= focus_enemy_key then
			CopLogicAttack._cancel_flanking_attempt(data, my_data)
		end
	end
	my_data.focus_enemy = focus_enemy
	if focus_type then
		local objective = data.objective
		local objective_interrupted, objective_block
		local dont_exit = false
		if data.unit:movement():chk_action_forbidden("walk") then
			dont_exit = true
		elseif objective then
			local interrupt = objective.interrupt_on
			if interrupt == "contact" then
				objective_interrupted = true
			elseif interrupt == "obstructed" then
				if TeamAILogicIdle.is_obstructed(data, data.objective) then
					objective_interrupted = true
				else
					objective_block = true
				end
			elseif objective.type ~= "follow" then
				objective_block = true
			end
			if objective.type == "follow" then
				local max_dist = managers.groupai:state():get_assault_mode() and 40 or 40
				local dist2 = mvector3.distance_sq(data.objective.follow_unit:movement():m_pos(), data.m_pos)
				local zdist = math.abs(data.objective.follow_unit:movement():m_pos().z - data.m_pos.z)
				if my_data.called or target_prio_slot > 3 and (dist2 > max_dist * max_dist or zdist > 40) or target_prio_slot <= 3 and (dist2 > max_dist * max_dist * 2 or zdist > 40) then
					dont_exit = true
				end
			end
		end
		if objective_interrupted and not dont_exit then
			managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective)
			return
		elseif not objective_block then
			if focus_type == "assault" and target_prio_slot < 4 and not dont_exit then
				my_data.exiting = true
				CopLogicBase._exit(data.unit, "assault")
				return
			elseif focus_type == "assault" then
				TeamAILogicAssault._upd_aim(data, my_data)
				TeamAILogicAssault._chk_change_weapon(data, my_data)
			end
		end
	end
	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
		local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)
		if civ then
			my_data._intimidate_t = data.t
			if not my_data.focus_enemy then
				CopLogicBase._set_attention_on_unit(data, civ)
				local key = "RemoveAttentionOnUnit" .. tostring(data.unit:key())
				CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, data, data.t + 1.5)
			end
		end
	end
	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._update_enemy_detection, data, data.t + delay)
end)--]]


function TeamAILogicTravel.update(data)
	if data.objective and data.objective.type == "revive" then
		local focus_enemy = data.internal_data.focus_enemy
		if focus_enemy and focus_enemy.verified and focus_enemy.unit:base() and focus_enemy.unit:base()._tweak_table == "spooc" then  --有没有必要加上泰瑟？
			if mvector3.distance_sq(focus_enemy.m_head_pos, data.unit:movement():m_head_pos()) < 1000000 then
				if data.internal_data.advancing then
					data.unit:brain():action_request({
						body_part = 2,
						type = "idle"
					})
				end
				return
			end
		end
	end

	local unit = data.unit
	local objective = data.objective
	if not objective then
		managers.groupai:state():on_criminal_jobless(unit)
		return
	end

	local my_data = data.internal_data
	local t = data.t
	if my_data.processing_advance_path or my_data.processing_coarse_path then
		TeamAILogicTravel._upd_pathing(data, my_data)
	elseif my_data.advancing then
	elseif my_data.cover_leave_t then
		if not my_data.turning and not unit:movement():chk_action_forbidden("walk") then
			if t > my_data.cover_leave_t then
				my_data.cover_leave_t = nil
			elseif my_data.best_cover then
				local action_taken
				if not unit:movement():attention() then
					action_taken = CopLogicTravel._chk_request_action_turn_to_cover(data, my_data)
				end

				if not action_taken and not my_data.best_cover[4] and not unit:anim_data().crouch and not data.unit:movement():cool() then
					CopLogicAttack._chk_request_action_crouch(data)
				end

			end

		end

	elseif my_data.advance_path then
		if not unit:movement():chk_action_forbidden("walk") then
			local haste, no_strafe
			if objective and objective.haste then
				haste = objective.haste
				no_strafe = data.unit:movement():cool()
			elseif unit:movement():cool() then
				haste = "walk"
				no_strafe = true
			else
				haste = "run"
			end

			-- 原有分支之后，追加一个“跟随纠偏”
			if objective and objective.type == "follow" then
				local fpos = objective.follow_unit:movement():m_pos()
				local dist2 = mvector3.distance_sq(fpos, data.m_pos)
				local zdist = math.abs(fpos.z - data.m_pos.z)
				local FAR_H = managers.groupai:state():get_assault_mode() and 800 or 600
				local FAR_Z = 300
				local need_catchup = (dist2 > FAR_H * FAR_H) or (zdist > FAR_Z)

				if objective.called then
					-- 被口令召回时，更积极追上
					haste = "run"
					no_strafe = false
				elseif need_catchup and not no_strafe then
					dlog("[PDTH++DEV] AI离玩家过远并开始追逐玩家")
					haste = "run"
					no_strafe = false
				end
			end

			CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, haste, objective and objective.rot, no_strafe)
			if my_data.advancing then
				TeamAILogicTravel._check_start_path_ahead(data)
			end

		end

	elseif objective then
		if my_data.coarse_path then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path
			if cur_index == total_nav_points then
				objective.in_place = true
				CopLogicBase._exit(data.unit, "idle", {scan = true})
				return
			else
				local to_pos = TeamAILogicTravel._get_exact_move_pos(data, cur_index)
				my_data.advance_path_search_id = tostring(data.key) .. "advance"
				my_data.processing_advance_path = true
				local prio
				if objective and objective.follow_unit then
					prio = 5
				end

				unit:brain():search_for_path(my_data.advance_path_search_id, to_pos, prio)
			end

		else
			local search_id = tostring(unit:key()) .. "coarse"
			local nav_seg
			if objective.follow_unit then
				if not alive(objective.follow_unit) then
				else
					nav_seg = objective.follow_unit:movement():nav_tracker():nav_segment()
				end

			else
				nav_seg = objective.nav_seg
			end

			if unit:brain():search_for_coarse_path(search_id, nav_seg) then
				my_data.coarse_path_search_id = search_id
				my_data.processing_coarse_path = true
			end

		end

	else
		CopLogicBase._exit(data.unit, "idle", {scan = true})
	end

end


function TeamAILogicTravel._get_exact_move_pos(data, cur_index)
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos
	local coarse_path = my_data.coarse_path
	local cur_index = my_data.coarse_path_index
	local total_nav_points = #coarse_path
	local reservation, wants_reservation
	if cur_index >= total_nav_points - 1 then
		local new_occupation = TeamAILogicTravel._determine_destination_occupation(data, objective)
		if new_occupation then
			if new_occupation.type == "guard" then
				local guard_door = new_occupation.door
				local guard_pos = CopLogicTravel._get_pos_accross_door(guard_door, objective.nav_seg)
				if guard_pos then
					reservation = CopLogicTravel._reserve_pos_along_vec(guard_door.center, guard_pos)
					if reservation then
						local guard_object = {
							type = "door",
							door = guard_door,
							from_seg = new_occupation.from_seg
						}
						objective.guard_obj = guard_object
						to_pos = reservation.pos
					end

				end

			elseif new_occupation.type == "defend" then
				if new_occupation.cover then
					to_pos = new_occupation.cover[1][1]
					local new_cover = new_occupation.cover
					managers.navigation:reserve_cover(new_cover[1], data.pos_rsrv_id)
					my_data.moving_to_cover = new_cover
				elseif new_occupation.pos then
					to_pos = new_occupation.pos
				end

				wants_reservation = true
			elseif new_occupation.type == "act" then
				to_pos = new_occupation.pos
				wants_reservation = true
			elseif new_occupation.type == "revive" then
				to_pos = new_occupation.pos
				objective.rot = new_occupation.rot
				wants_reservation = true
			end

		end

		if not to_pos then
			to_pos = managers.navigation:find_random_position_in_segment(objective.nav_seg)
			to_pos = CopLogicTravel._get_pos_on_wall(to_pos)
			wants_reservation = true
		end

	else
		local end_pos = coarse_path[cur_index + 1][2]
		local my_pos = data.m_pos
		local walk_dir = end_pos - my_pos
		local walk_dis = mvector3.normalize(walk_dir)

		-- 新增：跟随玩家、且暂未专注敌人时，不中途拐去掩体
		if objective and objective.type == "follow" and not my_data.focus_enemy and not managers.groupai:state():get_assault_mode() then
			to_pos = end_pos
			my_data.moving_to_cover = nil
		else
  			-- 原逻辑，但把范围收紧，避免大幅偏航
    		local cover_range = math.min(500, math.max(0, walk_dis - 200))
  			local cover = managers.navigation:find_cover_near_pos_1(
  				end_pos, end_pos + walk_dir * 600, cover_range, cover_range
  			)
			if cover then
    			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)
    			my_data.moving_to_cover = {cover}
    			to_pos = cover[1]
			else
    			to_pos = end_pos
    			my_data.moving_to_cover = nil
  			end
		end

	end

	if not reservation and wants_reservation then
		reservation = {
			position = mvector3.copy(to_pos),
			radius = 60,
			filter = data.pos_rsrv_id
		}
		managers.navigation:add_pos_reservation(reservation)
	end

	if my_data.rsrv_pos.path then
		managers.navigation:unreserve_pos(my_data.rsrv_pos.path)
	end

	my_data.rsrv_pos.path = reservation
	return to_pos
end


function TeamAILogicTravel._determine_destination_occupation(data, objective)
	local occupation
	if objective.type == "investigate_area" then
		if objective.guard_obj then
			occupation = managers.groupai:state():verify_occupation_in_area(objective) or objective.guard_obj
			occupation.type = "guard"
		else
			occupation = managers.groupai:state():find_occupation_in_area(objective.nav_seg)
		end

	elseif objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		else
			local pos = objective.pos or managers.navigation._nav_segments[objective.nav_seg].pos
			local cover = managers.navigation:find_cover_in_nav_seg_1(objective.nav_seg)
			local cover_entry
			if cover then
				local cover_entry = {cover}
				occupation = {type = "defend", cover = cover_entry}
			else
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = objective.pos,
					radius = objective.radius
				}
			end

		end

	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		dlog("[PDTH++DEV] AI的行动目标是follow")
		local follow_tracker = objective.follow_unit:movement():nav_tracker()
		local follow_pos = follow_tracker:field_position()
		local threat_pos
		local max_dist = managers.groupai:state():get_assault_mode() and 500 or 1500
		local dist2 = mvector3.distance_sq(follow_pos, data.m_pos)
		local zdist = math.abs(follow_pos.z - data.m_pos.z)
		if dist2 > max_dist * max_dist * 2 or zdist > 600 then
			threat_pos = follow_pos
		elseif data.internal_data.focus_enemy then
			local threat_tracker = data.internal_data.focus_enemy.unit:movement():nav_tracker()
			threat_pos = threat_tracker:field_position()
		else
			threat_pos = follow_pos - data.m_pos
			mvector3.set_length(threat_pos, 300)
			mvector3.add(threat_pos, follow_pos)
		end

		local near_r, near_r2
		if objective.called then
			near_r, near_r2 = 450, 180
		elseif managers.groupai:state():get_assault_mode() then
			near_r, near_r2 = 600, 250
		else
			near_r, near_r2 = 500, 200
		end
		local cover = managers.navigation:find_cover_near_pos_1(follow_pos, threat_pos, near_r, near_r2, data.internal_data.called)

		-- 新增：二次过滤，确保不离玩家太远
		local function _too_far_from_follow(cov)
			if not cov then return true end
			local cpos = cov[1]
			return mvector3.distance_sq(cpos, follow_pos) > (near_r + 50) * (near_r + 50)
		end

		if cover and not _too_far_from_follow(cover) then
			local cover_entry = {cover}
			occupation = {type = "defend", cover = cover_entry}
		else
			local max_dist = objective.called and 450 or 600
			local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist)
			occupation = {type = "defend", pos = to_pos}
		end

	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {tracker_from = revive_u_tracker, trace = true}
		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end

		local stand_dis
		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 120
		else
			stand_dis = 90
			local mid_pos = mvector3.copy(revive_u_fwd)
			mvector3.multiply(mid_pos, -20)
			mvector3.add(mid_pos, revive_u_pos)
			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end

		local rand_side_mul = math.random() > 0.5 and 1 or -1
		local revive_pos = mvector3.copy(revive_u_right)
		mvector3.multiply(revive_pos, rand_side_mul * stand_dis)
		mvector3.add(revive_pos, revive_u_pos)
		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)
		if ray_res then
			local opposite_pos = mvector3.copy(revive_u_right)
			mvector3.multiply(opposite_pos, -rand_side_mul * stand_dis)
			mvector3.add(opposite_pos, revive_u_pos)
			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)
			if opposite_ray_res then
				if mvector3.distance(ray_params.trace[1], revive_u_pos) > mvector3.distance(revive_pos, revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end

			else
				revive_pos = ray_params.trace[1]
			end

		else
			revive_pos = ray_params.trace[1]
		end

		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math.UP)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	end

	return occupation
end




--[[有clk在附近的时候先不要直接救人
local update = TeamAILogicTravel.update
function TeamAILogicTravel.update(data, ...)
	if data.objective and data.objective.type == "revive" then
		local focus_enemy = data.internal_data.focus_enemy
		if focus_enemy and focus_enemy.verified and focus_enemy.unit:base() and focus_enemy.unit:base()._tweak_table == "spooc" then  --有没有必要加上泰瑟？
			if mvector3.distance_sq(focus_enemy.m_head_pos, data.unit:movement():m_head_pos()) < 1000000 then
				if data.internal_data.advancing then
					data.unit:brain():action_request({
						body_part = 2,
						type = "idle"
					})
				end
				return
			end
		end
	end

	return update(data, ...)
end--]]
