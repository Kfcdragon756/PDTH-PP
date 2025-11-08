-- 将玩家要抓的敌人存入一个表中，以实现teamailogicassault文件中让AI不要攻击玩家试图抓的敌人的功能
local on_intimidated = CopLogicIdle.on_intimidated
function CopLogicIdle.on_intimidated(data, ...)
	local gstate = managers.groupai:state()
	if gstate:police_hostage_count() < 4 and not gstate:get_assault_mode() and not gstate._special_unit_types[data.unit:base()._tweak_table] then
		TeamAILogicAssault.INTIMIDATE_PROGRESS[data.unit:key()] = data.t
	end

	return on_intimidated(data, ...)
end
