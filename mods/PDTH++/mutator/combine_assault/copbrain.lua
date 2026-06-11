local module = ... or D:module("PDTH++")
local CopBrain = module:hook_class("CopBrain")

local FORCED_ACCESS = "swat"
local SOFT_STUCK_TIME = 7
local HARD_STUCK_TIME = 13
local SAMPLE_INTERVAL = 1
local MIN_MOVE_DIS_SQ = 45 * 45
local RECOVER_COOLDOWN = 10

local function _is_murky_unit(unit)
	return alive(unit) and unit:base() and unit:base()._tweak_table == "murky"
end

local function _is_murky_brain(brain)
	return brain and _is_murky_unit(brain._unit)
end

local function _murky_memory(brain)
	brain._pdthpp_combine_murky_unstuck = brain._pdthpp_combine_murky_unstuck or {}
	return brain._pdthpp_combine_murky_unstuck
end

local function _force_access(data)
	if data and data.char_tweak then
		data.char_tweak.access = FORCED_ACCESS
	end
	if tweak_data and tweak_data.character and tweak_data.character.murky then
		tweak_data.character.murky.access = FORCED_ACCESS
	end
end

local function _with_forced_murky_access(brain, func, ...)
	if not _is_murky_brain(brain) then
		return func(brain, ...)
	end

	local data = brain._logic_data
	local old_access = data and data.char_tweak and data.char_tweak.access
	_force_access(data)
	local ok, a, b, c, d = pcall(func, brain, ...)
	if data and data.char_tweak then
		data.char_tweak.access = old_access or FORCED_ACCESS
	end
	if not ok then
		error(a)
	end
	return a, b, c, d
end

local old_search_for_path_to_unit = CopBrain.search_for_path_to_unit
function CopBrain:search_for_path_to_unit(...)
	return _with_forced_murky_access(self, old_search_for_path_to_unit, ...)
end

local old_search_for_path = CopBrain.search_for_path
function CopBrain:search_for_path(...)
	return _with_forced_murky_access(self, old_search_for_path, ...)
end

local old_search_for_path_from_pos = CopBrain.search_for_path_from_pos
function CopBrain:search_for_path_from_pos(...)
	return _with_forced_murky_access(self, old_search_for_path_from_pos, ...)
end

local old_search_for_path_to_cover = CopBrain.search_for_path_to_cover
function CopBrain:search_for_path_to_cover(...)
	return _with_forced_murky_access(self, old_search_for_path_to_cover, ...)
end

local old_search_for_coarse_path = CopBrain.search_for_coarse_path
function CopBrain:search_for_coarse_path(...)
	return _with_forced_murky_access(self, old_search_for_coarse_path, ...)
end

local old_add_pathing_result = CopBrain._add_pathing_result
function CopBrain:_add_pathing_result(search_id, path)
	old_add_pathing_result(self, search_id, path)

	if not _is_murky_brain(self) then
		return
	end

	local mem = _murky_memory(self)
	if path and path ~= "failed" then
		mem.path_fail_count = 0
	else
		mem.path_fail_count = (mem.path_fail_count or 0) + 1
		if mem.path_fail_count >= 2 then
			mem.force_soft_recover = true
			mem.last_fail_search_id = search_id
		end
	end
end

local function _clear_pathing(data)
	local unit = data.unit
	local brain = unit and unit:brain()
	if brain and brain.cancel_all_pathing_searches then
		brain:cancel_all_pathing_searches()
	end

	if data.active_searches then
		for search_id, _ in pairs(data.active_searches) do
			data.active_searches[search_id] = nil
		end
	end
	data.pathing_results = nil

	local my_data = data.internal_data
	if not my_data then
		return
	end

	my_data.processing_advance_path = nil
	my_data.processing_coarse_path = nil
	my_data.processing_cover_path = nil
	my_data.advance_path_search_id = nil
	my_data.coarse_path_search_id = nil
	my_data.cover_path_search_id = nil
	my_data.flank_path_search_id = nil
	my_data.expected_pos_path_search_id = nil
	my_data.advance_path = nil
	my_data.coarse_path = nil
	my_data.cover_path = nil
	my_data.flank_path = nil
	my_data.expected_pos_path = nil
	my_data.coarse_search_failed = nil
	my_data.wants_stop_old_walk_action = true
end

local function _random_pos_in_seg(seg_id, avoid_pos)
	if not seg_id then
		return nil
	end

	local fallback
	for i = 1, 16 do
		local pos = managers.navigation:find_random_position_in_segment(seg_id)
		if pos then
			fallback = fallback or pos
			if not avoid_pos or mvector3.distance_sq(pos, avoid_pos) > 500 * 500 then
				if CopLogicTravel and CopLogicTravel._get_pos_on_wall then
					return CopLogicTravel._get_pos_on_wall(pos)
				end
				return pos
			end
		end
	end

	if fallback and CopLogicTravel and CopLogicTravel._get_pos_on_wall then
		return CopLogicTravel._get_pos_on_wall(fallback)
	end
	return fallback
end

local function _closest_criminal_seg(data)
	local gstate = managers.groupai and managers.groupai:state()
	if not gstate or not gstate.all_char_criminals then
		return nil, nil
	end

	local best_seg, best_pos, best_dis
	for _, c_data in pairs(gstate:all_char_criminals()) do
		local c_unit = c_data.unit
		if alive(c_unit) and c_unit:movement() and not c_data.status then
			local c_pos = c_unit:movement():m_pos()
			local dis = data.m_pos and mvector3.distance_sq(c_pos, data.m_pos) or 0
			if not best_dis or dis < best_dis then
				best_dis = dis
				best_pos = c_pos
				if c_unit:movement():nav_tracker() then
					best_seg = c_unit:movement():nav_tracker():nav_segment()
				end
			end
		end
	end

	return best_seg, best_pos
end

local function _find_recovery_pos(data)
	local objective = data.objective
	local pos

	if objective and objective.nav_seg then
		pos = _random_pos_in_seg(objective.nav_seg)
		if pos then
			return pos
		end
	end

	local seg, avoid_pos = _closest_criminal_seg(data)
	pos = _random_pos_in_seg(seg, avoid_pos)
	if pos then
		return pos
	end

	local tracker = data.unit:movement():nav_tracker()
	if tracker then
		return _random_pos_in_seg(tracker:nav_segment())
	end
end

local function _soft_recover(data, mem, reason)
	if not data.objective then
		return false
	end

	_force_access(data)
	_clear_pathing(data)
	mem.path_fail_count = 0
	mem.force_soft_recover = nil
	mem.soft_recovered_t = data.t
	print("[PDTH++] Combine Assault Murky soft recover", data.unit:key(), reason or "unknown")
	managers.groupai:state():on_objective_failed(data.unit, data.objective)
	return true
end

local function _hard_recover(data, mem, reason)
	local unit = data.unit
	local movement = unit:movement()
	local pos = _find_recovery_pos(data)
	if not pos then
		return false
	end

	_force_access(data)
	_clear_pathing(data)

	if not movement:chk_action_forbidden("walk") then
		movement:action_request({ type = "idle", body_part = 1 })
	end

	movement:set_position(pos)
	if data.m_pos then
		mvector3.set(data.m_pos, pos)
	end

	mem.path_fail_count = 0
	mem.force_soft_recover = nil
	mem.last_pos = mvector3.copy(pos)
	mem.stuck_since = nil
	mem.hard_recovered_t = data.t
	mem.next_recover_t = data.t + RECOVER_COOLDOWN
	print("[PDTH++] Combine Assault Murky hard recover", unit:key(), reason or "unknown")

	if data.objective then
		managers.groupai:state():on_objective_failed(unit, data.objective)
	else
		unit:brain():set_objective({ type = "free", attitude = "engage", stance = "hos" })
	end
	return true
end

local function _update_murky_watchdog(data, logic_name)
	local unit = data and data.unit
	if Network:is_client() or not _is_murky_unit(unit) then
		return
	end
	if unit:character_damage() and unit:character_damage().dead and unit:character_damage():dead() then
		return
	end

	data.t = data.t or TimerManager:game():time()
	_force_access(data)

	local brain = unit:brain()
	local mem = _murky_memory(brain)
	if mem.next_recover_t and data.t < mem.next_recover_t then
		return
	end

	if mem.force_soft_recover then
		if _soft_recover(data, mem, "path_failed") then
			return
		end
	end

	-- Do not treat a deliberate shooting stance as stuck. The watchdog is aimed at
	-- travel/objective units that are supposed to be moving but make no progress.
	local objective = data.objective
	local should_watch_motion = data.name == "travel" or (objective and objective.type and objective.type ~= "free")
	if not should_watch_motion then
		return
	end
	if unit:movement():chk_action_forbidden("walk") then
		mem.stuck_since = nil
		mem.last_pos = data.m_pos and mvector3.copy(data.m_pos) or nil
		mem.last_sample_t = data.t
		return
	end

	local cur_pos = unit:movement():m_pos()
	if not cur_pos then
		return
	end

	if not mem.last_pos then
		mem.last_pos = mvector3.copy(cur_pos)
		mem.last_sample_t = data.t
		return
	end

	if mem.last_sample_t and data.t - mem.last_sample_t < SAMPLE_INTERVAL then
		return
	end

	local moved_sq = mvector3.distance_sq(cur_pos, mem.last_pos)
	mem.last_pos = mvector3.copy(cur_pos)
	mem.last_sample_t = data.t

	if moved_sq > MIN_MOVE_DIS_SQ then
		mem.stuck_since = nil
		return
	end

	mem.stuck_since = mem.stuck_since or data.t
	local stuck_time = data.t - mem.stuck_since
	if stuck_time > HARD_STUCK_TIME then
		_hard_recover(data, mem, logic_name .. "_stuck")
	elseif stuck_time > SOFT_STUCK_TIME then
		_soft_recover(data, mem, logic_name .. "_stuck")
		mem.next_recover_t = data.t + 2
	end
end

local function _wrap_queued_update(logic_class, logic_name)
	if not logic_class or not logic_class.queued_update or logic_class._pdthpp_combine_murky_watchdog_wrapped then
		return
	end

	logic_class._pdthpp_combine_murky_watchdog_wrapped = true
	local old_queued_update = logic_class.queued_update
	logic_class.queued_update = function(data, ...)
		local result = old_queued_update(data, ...)
		if data and data.internal_data then
			_update_murky_watchdog(data, logic_name)
		end
		return result
	end
end

_wrap_queued_update(CopLogicTravel, "travel")
_wrap_queued_update(CopLogicAttack, "attack")
