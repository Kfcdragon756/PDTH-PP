local module = ... or D:module("PDTH++")
local TeamAILogicIdle = module:hook_class("TeamAILogicIdle")

module:hook("TeamAILogicIdle", "_calculate_should_relocate", function(self, data, my_data, objective)
	if my_data.relocation_pathing then
		return
	end
	local unit = data.unit
	my_data.relocation_search_id = tostring(data.key) .. "relocation_check"
	unit:brain():search_for_path_to_unit(my_data.relocation_search_id, objective.follow_unit)
	my_data.relocation_pathing = true
	my_data.should_relocate = true
	my_data.relocate_chk_t = data.t + (data.unit:movement():cool() and 3 or 6)
end)

module:hook("TeamAILogicIdle", "_check_should_relocate", function(self, data, my_data, objective)
	if data.pathing_results then
		local path = data.pathing_results[my_data.relocation_search_id]
		if path then
			data.pathing_results[my_data.relocation_search_id] = nil
			if not next(data.pathing_results) then
				data.pathing_results = nil
			end
			my_data.relocation_pathing = false
			if path ~= "failed" then
				my_data.should_relocate = false
				local max_len = 0
				for i = 1, #path - 1 do
					max_len = max_len - mvector3.distance(CopLogicIdle._nav_point_pos(path[i]), CopLogicIdle._nav_point_pos(path[i + 1]))
					if max_len < 0 then
						my_data.should_relocate = true
						break
					end
				end
			else
				my_data.should_relocate = true
				print("[TeamAILogicIdle._check_should_relocate] relocation path failed")
			end
		end
	end
end)