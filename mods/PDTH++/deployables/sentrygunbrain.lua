--[[
步哨 AI 选敌、投降目标保护与特殊遮挡状态机。

核心原则：
- 正在投降、已经投降和交易状态的敌人不会进入/保留在目标表中；
- 非突击阶段对普通敌人的呼喊保留 4 秒保护，避免玩家准备喊降时被步哨抢杀；
- “能否选为关注目标”和“当前是否允许开火”分离：盾牌或医疗/弹药包挡住时可继续跟踪，暂时停火；
- 已经实际开火的目标若被盾牌或医疗/弹药包挡住，最多保持瞄准 1.5 秒，之后优先转火，
  并在 5 秒内避免重新抢占其他可射击目标；场上无其他目标时仍可作为兜底关注；
- 同一目标从特殊遮挡中重新露出后，需要短暂连续稳定无遮挡才恢复射击，防止特殊敌人
  动画或遮挡边缘造成逐帧停火/开火抖动和自动射击循环音爆音。
- 所有计时均使用游戏时间戳，不创建延迟回调，退出关卡或销毁时直接清理状态。
]]

local module = ... or D:module("PDTH++")
local SentryGunBrain = module:hook_class("SentryGunBrain")

-- Sentry target-selection adjustments:
-- 1. Never target surrendered/trade enemies.
-- 2. Respect the existing 4-second intimidation reservation, but only outside assaults
--    and only for ordinary (non-special) enemies.
-- 3. Do not waste ammunition whenever a Shield, ammo bag or doctor bag blocks the sentry's ray
--    to its selected target, even when that selected target is not a Shield unit.
-- 4. Once the sentry has actually opened fire on a target, keep tracking that target for
--    up to 1.5 seconds if a supported obstruction moves into the firing line. If the ray stays blocked,
--    prefer another target and avoid reselecting the blocked target for 5 seconds unless
--    no other target is available.

local INTIMIDATE_RESERVATION_TIME = 4
local OBSTRUCTION_BLOCK_HOLD_TIME = 1.5
local OBSTRUCTION_RESELECT_COOLDOWN = 5
-- 同一目标刚从特殊遮挡中露出时，要求射线连续稳定一小段时间再恢复开火。
-- 这不是额外的选敌延迟，而是用于抑制盾牌/部署包边缘和敌人动画造成的
-- “挡住→露出→挡住”逐帧抖动，避免自动射击循环音被高频停止和重启。
local OBSTRUCTION_CLEAR_RESUME_TIME = 0.15

local shield_slotmask = World:make_slot_mask(8)
local AMMO_BAG_UNIT = Idstring("units/equipment/ammo_bag/ammo_bag")
local DOCTOR_BAG_UNIT = Idstring("units/equipment/doctor_bag/doctor_bag")
local bullet_slotmask
local tmp_vec1 = Vector3()
local tmp_obstruction_target_pos = Vector3()
local tmp_fire_target_pos = Vector3()
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local math_max = math.max

local function is_alive_unit(unit)
	return unit and alive(unit)
end

-- 识别需要进入特殊停火/保持关注状态机的遮挡单位。
-- 只包含盾牌、医疗包和弹药袋；普通墙体仍按原版视线/可达失败处理。
local function is_sentry_obstruction(unit)
	if not is_alive_unit(unit) then
		return false
	end

	local unit_name = unit:name()
	return unit:in_slot(shield_slotmask)
		or unit_name == AMMO_BAG_UNIT
		or unit_name == DOCTOR_BAG_UNIT
end

-- 只停止自动射击并同步禁火，不清除 attention；特殊遮挡物短暂挡住时炮口仍可继续跟踪目标。
function SentryGunBrain:_pdthpp_stop_firing()
	if not self._firing then
		return
	end

	self._unit:weapon():stop_autofire()
	self._firing = false

	if Network:is_server() and self._unit:id() ~= -1 then
		self._unit:network():send("cop_forbid_fire")
	end
end

-- 清理当前1.5秒观察状态；仅在停用/销毁等完整重置场景清除5秒冷却表。
function SentryGunBrain:_pdthpp_clear_obstruction_tracking(clear_cooldowns)
	self._pdthpp_obstruction_engaged_key = nil
	self._pdthpp_obstruction_blocked_key = nil
	self._pdthpp_obstruction_blocked_t = nil
	self._pdthpp_obstruction_resume_key = nil
	self._pdthpp_obstruction_clear_t = nil

	if clear_cooldowns then
		self._pdthpp_obstruction_avoid_until = nil
	end
end

-- 将“原始遮挡结果”转换成稳定的开火许可。
-- 一旦同一目标被盾牌、医疗包或弹药袋挡住，立即停火；遮挡消失后必须连续
-- 保持无遮挡 OBSTRUCTION_CLEAR_RESUME_TIME 秒才允许重新启动自动射击。
-- 若期间再次被挡，稳定计时会重新开始。切换到另一个目标时不继承这段等待。
function SentryGunBrain:_pdthpp_obstruction_blocks_fire(t, focus_enemy, raw_blocked)
	if not focus_enemy then
		self._pdthpp_obstruction_resume_key = nil
		self._pdthpp_obstruction_clear_t = nil
		return false
	end

	local focus_key = focus_enemy.key
	if raw_blocked then
		self._pdthpp_obstruction_resume_key = focus_key
		self._pdthpp_obstruction_clear_t = nil
		return true
	end

	if self._pdthpp_obstruction_resume_key ~= focus_key then
		self._pdthpp_obstruction_resume_key = nil
		self._pdthpp_obstruction_clear_t = nil
		return false
	end

	if not self._pdthpp_obstruction_clear_t then
		self._pdthpp_obstruction_clear_t = t
		return true
	end

	if t - self._pdthpp_obstruction_clear_t < OBSTRUCTION_CLEAR_RESUME_TIME then
		return true
	end

	self._pdthpp_obstruction_resume_key = nil
	self._pdthpp_obstruction_clear_t = nil
	return false
end

function SentryGunBrain:_pdthpp_enemy_logic_name(enemy_unit)
	if not is_alive_unit(enemy_unit) then
		return nil
	end

	local brain = enemy_unit:brain()
	return brain and brain._current_logic_name
end

function SentryGunBrain:_pdthpp_is_special_enemy(enemy_unit)
	if not is_alive_unit(enemy_unit) then
		return false
	end

	local base = enemy_unit:base()
	local tweak_table = base and base._tweak_table
	local group_state = managers.groupai and managers.groupai:state()
	local special_types = group_state and group_state._special_unit_types

	return tweak_table and special_types and special_types[tweak_table] and true or false
end

-- 统一判断“绝不能射击”的投降/人质目标，并处理4秒呼喊预留窗口。
-- 特殊敌人和警方突击期间不使用短暂预留，避免标记键误触导致步哨停火。
function SentryGunBrain:_pdthpp_is_surrender_target(enemy_unit, t)
	if not is_alive_unit(enemy_unit) then
		return true
	end

	local logic_name = self:_pdthpp_enemy_logic_name(enemy_unit)
	if logic_name == "intimidated" or logic_name == "trade" then
		return true
	end

	-- Animation-state fallback. The logic-name check above is the primary source of truth,
	-- but these flags cover short state/action transitions around tying and trading.
	local anim_data = enemy_unit:anim_data()
	if anim_data and (anim_data.hands_up or anim_data.hands_back or anim_data.hands_tied or anim_data.tied) then
		return true
	end

	local progress = TeamAILogicAssault and TeamAILogicAssault.INTIMIDATE_PROGRESS
	local reserve_t = progress and progress[enemy_unit:key()]
	if not reserve_t then
		return false
	end

	if t - reserve_t >= INTIMIDATE_RESERVATION_TIME then
		-- Prevent the shared table from accumulating obsolete unit keys.
		progress[enemy_unit:key()] = nil
		return false
	end

	local group_state = managers.groupai and managers.groupai:state()
	if not group_state or group_state:get_assault_mode() then
		return false
	end

	-- Marking and intimidation use the same player input. During an assault, or against
	-- special enemies, the short reservation must never suppress sentry fire.
	return not self:_pdthpp_is_special_enemy(enemy_unit)
end

-- 委托 Movement 解析真实瞄准点，确保炮口转向、特殊遮挡判断和开火角度使用同一点。
-- 第三个返回值表示没有可射击部位，且至少一条允许路径被盾牌、医疗包或弹药袋挡住，
-- 用于决定候选跳过、停火保持和转火。第四返回值表示真实步哨弹道能否首先命中目标，
-- 用于把“仍有跟踪回退点”与“当前确实可射击”分开。
function SentryGunBrain:_pdthpp_target_position(enemy_data, out_pos)
    local enemy_unit = enemy_data and enemy_data.unit
    if not is_alive_unit(enemy_unit) then
        return false, false, false, false
    end

    -- SentryGunMovement owns the target-point policy so physical rotation, supported
    -- obstruction handling and the fire-angle test all use the same body point. The third return
    -- value means no permitted point is shootable and at least one failed path hit a supported obstruction.
    if self._ext_movement and self._ext_movement._pdthpp_target_position then
        return self._ext_movement:_pdthpp_target_position(enemy_unit, out_pos)
    end

    local char_damage = enemy_unit:character_damage()
    if char_damage and char_damage.shoot_pos_mid then
        char_damage:shoot_pos_mid(out_pos)
    else
        mvector3.set(out_pos, enemy_data.m_com)
    end

    return true, false, false, true
end

-- 统一“当前目标是否仍可保持/候选是否可重新选入”的资格判断。
--
-- 原来的失控链是：
--   躯干中心的 AI 可见性超过 0.1 秒未验证
--   → _chk_focus_enemy_valid() 清空 attention 并停止循环音
--   → 同一次 update 的 _choose_focus_enemy() 又从尚未满 3 秒的侦测表选回同一单位
--   → start_autofire() 每帧重新启动循环音。
--
-- 多部位功能允许“躯干中心不可见、但肩/脊柱/骨盆等真实弹道可命中”，因此不能简单
-- 丢弃所有 unverified 敌人。这里把短暂可见性宽限、真实可射击结果和特殊遮挡保持
-- 合并为唯一判定，让验证与选敌两处采用完全相同的规则。
function SentryGunBrain:_pdthpp_focus_eligibility(enemy_data, t)
	if not enemy_data then
		return false, false, false
	end

	local recently_verified = enemy_data.verified
		or enemy_data.verified_t
			and t - enemy_data.verified_t <= tweak_data.weapon.sentry_gun.LOST_SIGHT_VERIFICATION

	local _, _, obstruction_blocked, shootable = self:_pdthpp_target_position(
		enemy_data,
		tmp_obstruction_target_pos
	)

	local eligible = recently_verified or shootable or obstruction_blocked
	return eligible and true or false, obstruction_blocked and true or false, shootable and true or false
end

-- 检查完整射击路径，而不只检查“目标自己是否为盾兵”。
-- 盾牌、医疗包或弹药袋只要位于炮口与目标部位之间，就应触发相同的
-- 候选跳过、停火保持和优先转火逻辑。
function SentryGunBrain:_pdthpp_obstruction_blocks_target(enemy_data)
	local enemy_unit = enemy_data and enemy_data.unit
	if not is_alive_unit(enemy_unit) then
		return false
	end

	-- This deliberately checks the complete path to every permitted target point rather
	-- than only checking whether the target itself is a Shield. An unrelated Shield,
	-- ammo bag or doctor bag can stand between the sentry and an ordinary cop, and the
	-- actual bullet mask will hit that obstruction first.
	local valid, _, resolved_obstruction_blocked = self:_pdthpp_target_position(
		enemy_data,
		tmp_obstruction_target_pos
	)
	if not valid then
		return false
	end

	-- The movement resolver performs the expensive multi-part test and caches it.
	-- Fallback uses the actual sentry bullet mask and classifies only the supported
	-- obstruction units; ordinary walls remain a normal unreachable path.
	if resolved_obstruction_blocked ~= nil then
		return resolved_obstruction_blocked
	end

	bullet_slotmask = bullet_slotmask or managers.slot:get_mask("bullet_impact_targets_sentry_gun")
	local col_ray = World:raycast(
		"ray",
		self._eye_object_pos,
		tmp_obstruction_target_pos,
		"slot_mask",
		bullet_slotmask
	)

	return col_ray and is_sentry_obstruction(col_ray.unit) or false
end

-- 从侦测表安全移除单位并注销死亡/销毁监听；若它正是当前目标，同时停火和清除 attention。
function SentryGunBrain:_pdthpp_remove_detected_enemy(enemy_key, enemy_data)
	if enemy_data then
		local enemy_unit = enemy_data.unit
		if is_alive_unit(enemy_unit) then
			local base = enemy_unit:base()
			if base and enemy_data.destroy_clbk_key then
				base:remove_destroy_listener(enemy_data.destroy_clbk_key)
			end

			local char_damage = enemy_unit:character_damage()
			if char_damage and enemy_data.death_clbk_key then
				char_damage:remove_listener(enemy_data.death_clbk_key)
			end
		end
	end

	self._AI_data.detected_enemies[enemy_key] = nil
	if self._ext_movement._pdthpp_forget_target then
		self._ext_movement:_pdthpp_forget_target(enemy_key)
	end

	if self._AI_data.focus_enemy and self._AI_data.focus_enemy.key == enemy_key then
		self._AI_data.focus_enemy = nil
		if self._ext_movement._pdthpp_on_focus_changed then
			self._ext_movement:_pdthpp_on_focus_changed(nil)
		end
		self._ext_movement:set_attention()
		self:_pdthpp_stop_firing()
		self:_pdthpp_clear_obstruction_tracking(false)
	end
end

-- 延续原版逐帧“验证目标→重新选敌→检查开火”的更新链。
-- 额外在这里推动最长1秒的状态同步刷新，不使用可能跨关卡存活的延迟定时器。
function SentryGunBrain:update(unit, t, dt)
	if Network:is_server() then
		self:_chk_enemies_valid(t)
		self:_chk_focus_enemy_valid(t)
		self:_choose_focus_enemy(t)
	end

	self:_check_fire(t)

	-- The status sender normally runs after firing or taking damage. Rechecking
	-- here lets a small pending change flush at the 1-second ceiling without
	-- creating delayed callbacks that could survive a level transition.
	if Network:is_server() and module.pdthpp_send_sentry_status then
		module:pdthpp_send_sentry_status(self._unit, false)
	end
end

function SentryGunBrain:_chk_focus_enemy_valid(t)
	local focus_enemy = self._AI_data.focus_enemy
	if not focus_enemy then
		return
	end

	local surrender_target = self:_pdthpp_is_surrender_target(focus_enemy.unit, t)
	local focus_eligible = not surrender_target
		and self:_pdthpp_focus_eligibility(focus_enemy, t)

	if surrender_target or not focus_eligible then
		self._AI_data.focus_enemy = nil
		if self._ext_movement._pdthpp_on_focus_changed then
			self._ext_movement:_pdthpp_on_focus_changed(nil)
		end
		self._ext_movement:set_attention()
		self:_pdthpp_stop_firing()
		self:_pdthpp_clear_obstruction_tracking(false)
	end
end

function SentryGunBrain:_chk_enemies_valid(t)
	for enemy_key, enemy_data in pairs(self._AI_data.detected_enemies) do
		if self:_pdthpp_is_surrender_target(enemy_data.unit, t) then
			self:_pdthpp_remove_detected_enemy(enemy_key, enemy_data)
		elseif enemy_data.death_verify_t and t > enemy_data.death_verify_t then
			self:_pdthpp_remove_detected_enemy(enemy_key, enemy_data)
		end
	end
end

-- 维护盾牌/医疗包/弹药袋共用的遮挡状态机：仅对已经实际开火过的目标提供1.5秒保持；
-- 超时后写入5秒回避冷却，使其只能在没有其他可用目标时作为兜底。
function SentryGunBrain:_pdthpp_update_obstruction_hold(t, focus_enemy, focus_blocked)
	if not focus_enemy then
		self:_pdthpp_clear_obstruction_tracking(false)
		return false
	end

	local focus_key = focus_enemy.key
	local avoid_until = self._pdthpp_obstruction_avoid_until
		and self._pdthpp_obstruction_avoid_until[focus_key]

	-- While the 5-second reselect cooldown is active, this previously obstruction-blocked
	-- target can remain as a last resort, but it must never receive another 1.5-second
	-- priority hold over a newly available target.
	if focus_blocked and avoid_until and t < avoid_until then
		self._pdthpp_obstruction_blocked_key = nil
		self._pdthpp_obstruction_blocked_t = nil
		return false
	end

	if not focus_blocked then
		if self._pdthpp_obstruction_blocked_key == focus_key then
			self._pdthpp_obstruction_blocked_key = nil
			self._pdthpp_obstruction_blocked_t = nil
		end
		return false
	end

	-- The 1.5-second grace only applies after this sentry actually began firing at this
	-- target. If a supported obstruction already blocks the path before the sentry has opened fire,
	-- the target is skipped immediately whenever another usable target exists.
	if self._pdthpp_obstruction_engaged_key ~= focus_key then
		return false
	end

	if self._pdthpp_obstruction_blocked_key ~= focus_key then
		self._pdthpp_obstruction_blocked_key = focus_key
		self._pdthpp_obstruction_blocked_t = t
		return true
	end

	if t - self._pdthpp_obstruction_blocked_t < OBSTRUCTION_BLOCK_HOLD_TIME then
		return true
	end

	self._pdthpp_obstruction_avoid_until = self._pdthpp_obstruction_avoid_until or {}
	self._pdthpp_obstruction_avoid_until[focus_key] = t + OBSTRUCTION_RESELECT_COOLDOWN
	self._pdthpp_obstruction_engaged_key = nil
	self._pdthpp_obstruction_blocked_key = nil
	self._pdthpp_obstruction_blocked_t = nil

	return false
end

-- 完整选敌流程。候选分为：正常可射击、5秒冷却目标、被特殊遮挡的待机目标；
-- 优先级按此顺序选择，同时保留原版当前可射击目标的粘滞权重，避免无意义抖动。
function SentryGunBrain:_choose_focus_enemy(t)
	local delay = 1
	local enemies = managers.enemy:all_enemies()
	local my_tracker = self._unit:movement():nav_tracker()
	local chk_vis_func = my_tracker and my_tracker.check_visibility
	local my_pos = self._m_head_object_pos

	-- Preserve the original detection/verification pass, while removing surrender targets
	-- before they can enter or remain in the sentry's detected-enemy table.
	for enemy_key, all_enemy_data in pairs(enemies) do
		local enemy_unit = all_enemy_data.unit

		if self:_pdthpp_is_surrender_target(enemy_unit, t) then
			local detected = self._AI_data.detected_enemies[enemy_key]
			if detected then
				self:_pdthpp_remove_detected_enemy(enemy_key, detected)
			end
		elseif self._AI_data.detected_enemies[enemy_key] then
			local enemy_data = self._AI_data.detected_enemies[enemy_key]
			local enemy_pos = enemy_data.m_com
			local visible = not World:raycast(
				"ray",
				my_pos,
				enemy_pos,
				"slot_mask",
				self._visibility_slotmask,
				"ray_type",
				"ai_vision",
				"report"
			)

			enemy_data.verified = visible
			if visible then
				delay = math.min(0.6, delay)
				enemy_data.verified_t = t
				enemy_data.verified_dis = mvector3.distance(enemy_pos, my_pos)
			elseif not enemy_data.verified_t or t - enemy_data.verified_t > 3 then
				self:_pdthpp_remove_detected_enemy(enemy_key, enemy_data)
			end
		elseif chk_vis_func and chk_vis_func(my_tracker, all_enemy_data.tracker) then
			local enemy_pos = enemy_unit:movement():m_head_pos()
			local enemy_dis = mvector3.distance(enemy_pos, my_pos)
			local dis_multiplier = enemy_dis / self._AI_data.detection.dis_max

			if dis_multiplier < 1 then
				delay = math.min(delay, dis_multiplier)
				if not World:raycast(
					"ray",
					my_pos,
					enemy_pos,
					"slot_mask",
					self._visibility_slotmask,
					"ray_type",
					"ai_vision",
					"report"
				) then
					local enemy_data = self:_create_enemy_detection_data(enemy_unit)
					enemy_data.verified_t = t
					enemy_data.verified = true
					self._AI_data.detected_enemies[enemy_key] = enemy_data
				end
			end
		end
	end

	self._pdthpp_obstruction_avoid_until = self._pdthpp_obstruction_avoid_until or {}
	for enemy_key, avoid_until in pairs(self._pdthpp_obstruction_avoid_until) do
		if t >= avoid_until then
			self._pdthpp_obstruction_avoid_until[enemy_key] = nil
		end
	end

	local old_focus = self._AI_data.focus_enemy
	local cam_fwd
	if old_focus then
		cam_fwd = tmp_vec1
		mvec3_dir(cam_fwd, my_pos, old_focus.m_com)
	else
		cam_fwd = self._ext_movement:m_head_fwd()
	end

	local max_dis = 15000
	local function get_weight(enemy_data)
		local dis = mvec3_dir(tmp_vec1, my_pos, enemy_data.m_com)
		local dis_weight = math_max(0, (max_dis - dis) / max_dis)
		local dot_weight = 1 + mvec3_dot(tmp_vec1, cam_fwd)
		return dot_weight * dot_weight * dot_weight * dis_weight
	end

	local old_focus_blocked = false
	if old_focus then
		local _
		_, old_focus_blocked = self:_pdthpp_focus_eligibility(old_focus, t)
	end
	local hold_blocked_focus = self:_pdthpp_update_obstruction_hold(t, old_focus, old_focus_blocked)

	local best_enemy
	local best_weight
	local best_cooldown_enemy
	local best_cooldown_weight
	local best_blocked_enemy
	local best_blocked_weight

	for enemy_key, enemy_data in pairs(self._AI_data.detected_enemies) do
		local surrender_target = self:_pdthpp_is_surrender_target(enemy_data.unit, t)
		local focus_eligible, obstruction_blocked = false, false
		if not enemy_data.death_verify_t and not surrender_target then
			focus_eligible, obstruction_blocked = self:_pdthpp_focus_eligibility(enemy_data, t)
		end

		if not enemy_data.death_verify_t and not surrender_target and focus_eligible then
			local weight = get_weight(enemy_data)
			local is_old_focus = old_focus and old_focus.key == enemy_key
			local on_cooldown = self._pdthpp_obstruction_avoid_until[enemy_key]
				and t < self._pdthpp_obstruction_avoid_until[enemy_key]

			if is_old_focus and not obstruction_blocked and not on_cooldown then
				weight = weight * 4
			end

			if is_old_focus and obstruction_blocked and hold_blocked_focus then
				-- During the 1.5-second hold, keep tracking this target even if another
				-- target exists. _check_fire stops firing while a supported obstruction blocks the ray.
				best_enemy = enemy_data
				best_weight = math.huge
			elseif obstruction_blocked then
				-- Any enemy whose firing line is obstruction-blocked is a fallback attention
				-- target only. This includes ordinary cops behind a Shield, ammo bag or doctor bag.
				-- Keeping attention preserves the chance to fire through a brief opening.
				if is_old_focus then
					weight = weight * 4
				end
				if not best_blocked_weight or best_blocked_weight < weight then
					best_blocked_enemy = enemy_data
					best_blocked_weight = weight
				end
			elseif on_cooldown then
				-- A recently abandoned obstruction-blocked target may still be selected if
				-- absolutely nothing else is available, but it cannot displace another
				-- usable target for 5 seconds.
				if not best_cooldown_weight or best_cooldown_weight < weight then
					best_cooldown_enemy = enemy_data
					best_cooldown_weight = weight
				end
			elseif not best_weight or best_weight < weight then
				best_enemy = enemy_data
				best_weight = weight
			end
		end
	end

	local focus_enemy = best_enemy or best_cooldown_enemy or best_blocked_enemy

	if old_focus ~= focus_enemy then
		if self._ext_movement._pdthpp_on_focus_changed then
			self._ext_movement:_pdthpp_on_focus_changed(focus_enemy and focus_enemy.unit)
		end

		if focus_enemy then
			self._ext_movement:set_attention({unit = focus_enemy.unit})
		else
			self._ext_movement:set_attention()
		end

		self._AI_data.focus_enemy = focus_enemy
		self:_pdthpp_clear_obstruction_tracking(false)
	end

	return delay
end

-- 每次更新实时决定是否开火。盾牌或医疗/弹药包挡住时只停火不回正；
-- 射线恢复且炮口角度满足原版阈值后立即继续射击，并记录“确实对该目标开过火”。
function SentryGunBrain:_check_fire(t)
	if Network:is_client() then
		if self._firing then
			self._unit:weapon():trigger_held(true, false)
		end
		return
	end

	local focus_enemy = self._AI_data.focus_enemy
	if self._unit:weapon():out_of_ammo() then
		self:switch_off()
		return
	end

	if focus_enemy and self:_pdthpp_is_surrender_target(focus_enemy.unit, t) then
		self._AI_data.focus_enemy = nil
		if self._ext_movement._pdthpp_on_focus_changed then
			self._ext_movement:_pdthpp_on_focus_changed(nil)
		end
		self._ext_movement:set_attention()
		self:_pdthpp_stop_firing()
		self:_pdthpp_clear_obstruction_tracking(false)
		return
	end

	local raw_obstruction_blocked = focus_enemy
		and self:_pdthpp_obstruction_blocks_target(focus_enemy)
		or false
	local obstruction_blocked = self:_pdthpp_obstruction_blocks_fire(
		t,
		focus_enemy,
		raw_obstruction_blocked
	)
	if obstruction_blocked then
		-- Do not clear attention: the sentry keeps following its selected target while
		-- the obstruction remains, or until the hold/reselect state machine chooses another target.
		self:_pdthpp_stop_firing()
		return
	end

	if focus_enemy and not self._ext_movement:warming_up(t) then
		if self._firing then
			self._unit:weapon():trigger_held(false, true)
		else
			if not self:_pdthpp_target_position(focus_enemy, tmp_fire_target_pos) then
				mvector3.set(tmp_fire_target_pos, focus_enemy.m_com)
			end

			mvec3_dir(tmp_vec1, self._eye_object_pos, tmp_fire_target_pos)
			if mvec3_dot(tmp_vec1, self._ext_movement:m_head_fwd()) > tweak_data.weapon.sentry_gun.KEEP_FIRE_ANGLE then
				self._unit:weapon():start_autofire()
				self._unit:weapon():trigger_held(false, true)
				self._firing = true
				self._unit:network():send("cop_allow_fire")

				-- Remember every target that the sentry actually fired at. If any supported obstruction
				-- later moves into this firing line, that target receives the same
				-- 1.5-second hold and 5-second reselect handling.
				self._pdthpp_obstruction_engaged_key = focus_enemy.key
			end
		end
	else
		self:_pdthpp_stop_firing()
	end
end

-- 停用或销毁时同步清理时间戳/冷却，防止旧关卡状态残留到下一局。
local original_set_active = SentryGunBrain.set_active
function SentryGunBrain:set_active(state)
	if not state then
		self:_pdthpp_clear_obstruction_tracking(true)
	end
	return original_set_active(self, state)
end

local original_pre_destroy = SentryGunBrain.pre_destroy
function SentryGunBrain:pre_destroy(...)
	self:_pdthpp_clear_obstruction_tracking(true)
	return original_pre_destroy(self, ...)
end
