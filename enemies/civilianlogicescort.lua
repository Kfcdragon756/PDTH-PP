local module = ... or D:module("PDTH++")
local CivilianLogicEscort = module:hook_class("CivilianLogicEscort")

module:hook(CivilianLogicEscort, "too_scared_to_move", function(data)
	local nobody_close = true
	local min_dis_sq = 1000000

	for _, heister_data in pairs(managers.groupai:state():all_criminals()) do
		if min_dis_sq > mvector3.distance_sq(heister_data.m_pos, data.m_pos) then
			nobody_close = false
		end
	end

	if nobody_close then
		return "abandoned"
	end

	nobody_close = true

	min_dis_sq = tweak_data.character[data.unit:base()._tweak_table].escort_scared_dist
	min_dis_sq = min_dis_sq * min_dis_sq

	local my_head_pos = data.unit:movement():m_head_pos()
	for _, enemy_data in pairs(managers.enemy:all_enemies()) do
		local target_head_pos = enemy_data.unit:movement():m_head_pos()
		if
			not enemy_data.unit:anim_data().surrender
			and enemy_data.unit:brain()._current_logic_name ~= "trade"
			and min_dis_sq > mvector3.distance_sq(target_head_pos, my_head_pos)
			and math.abs(target_head_pos.z - my_head_pos.z) < 250
		then
			nobody_close = false
		end
	end

	if not nobody_close then
		return "pigs"
	end

	return false
end)
