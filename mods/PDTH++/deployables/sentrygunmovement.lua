--[[
步哨瞄准点解析、多部位可达检测、可选爆头策略与射线遮挡识别。

该文件负责回答“炮台实际应该朝目标的哪个位置转动”。选敌 Brain、开火角度检查和
盾牌/医疗包/弹药袋遮挡判断都会调用同一解析结果，以免视觉炮口、逻辑射线和真实子弹使用不同目标点。
默认仍保持原版躯干瞄准；只有主动爆头策略成功，或原躯干不可达且多部位检测开启时，
才会尝试头部、肩/躯干边缘、脊柱和骨盆等稳定备用点。

解析结果的第四返回值专门表示“至少一个允许的目标点可被真实步哨弹道直接命中”。
它与第一返回值（是否仍有可用于跟踪的回退位置）分开，供 Brain 判断失去躯干中心
视线后是否应继续保持目标，避免清空 attention 后又在同一帧选回同一敌人。

注意：原版伤害逻辑并非明确禁止四肢受伤，原版自动瞄准甚至会引用前臂和大腿。
但不同敌人模型的肢体命名 body 与实际子弹碰撞体并不完全稳定，瞄准其中心可能落在
无效碰撞区域或模型外侧。为避免炮台对“看似可达、实际容易打空”的四肢点持续射击，
本文件不再把手臂和腿部作为多部位备用瞄准点。

性能控制：当前目标结果缓存0.05秒，其他候选缓存0.2秒；原躯干可达时立即结束，
备用射线仅在必要时按顺序执行。医疗包和弹药袋不再被忽略：它们与盾牌一样会阻断该候选点，
但多部位检测仍会继续尝试敌人露出的其它部位。
]]

local module = ... or D:module("PDTH++")
local SentryGunMovement = module:hook_class("SentryGunMovement")

-- 以下四项是平衡开发变量，不暴露为菜单选项。修改默认值时请保持注释中的覆盖关系。
-- Sentry headshot controls.
-- These are intentionally code variables rather than menu settings so balance-oriented
-- builds can change the policy without exposing several advanced toggles to players.

-- When true, the sentry first attempts to aim at the head of ordinary enemies.
-- Default false preserves the vanilla torso-focused behaviour.
local SENTRY_HEADSHOT_ENABLED = false

-- Chance (0 to 1) to enable the intentional headshot policy each time this sentry
-- selects a target. This also applies to Bulldozer/Tank headshot attempts.
local SENTRY_HEADSHOT_CHANCE = 1

-- Bulldozer/Tank-specific override for intentional headshots. This ignores
-- SENTRY_HEADSHOT_ENABLED, but still uses SENTRY_HEADSHOT_CHANCE.
local SENTRY_TANK_HEADSHOT_ENABLED = false

-- Only has an effect while SENTRY_TANK_HEADSHOT_ENABLED is true and the selection's
-- probability roll succeeded. When false, the sentry returns to the vanilla torso aim
-- after the Bulldozer visor is broken. Multi-part reachability may still use the head
-- as a last resort when it is the only reachable body part.
local SENTRY_TANK_CONTINUE_HEADSHOT_AFTER_VISOR_BREAK = false

local TANK_TWEAK_TABLE = "tank"
local HEAD_BODY_NAME = "b_head"
local VISOR_BODY_NAME = "glass"
local MIN_PITCH = -55
local MAX_PITCH = 35.5
local CURRENT_TARGET_CACHE_TIME = 0.05
local OTHER_TARGET_CACHE_TIME = 0.2
local RAY_EXTENSION = 40
local AMMO_BAG_UNIT = Idstring("units/equipment/ammo_bag/ammo_bag")
local DOCTOR_BAG_UNIT = Idstring("units/equipment/doctor_bag/doctor_bag")
local IDS_HEAD = Idstring(HEAD_BODY_NAME)
local IDS_VISOR = Idstring(VISOR_BODY_NAME)
local IDS_BULLET = "bullet"
local IDS_EXPLOSION = "explosion"

-- 原版躯干点被挡住后使用的稳定命名 body 中心。
-- 这里只保留脊柱、骨盆和头部，不再探测手臂、大腿或小腿：
-- 四肢在部分敌人模型上的 body 中心与实际子弹碰撞体并不稳定，容易得到
-- “瞄准解析认为可用，但真实子弹从模型边缘掠过”的结果。未知 body 会自动跳过，
-- 因而仍兼容缺少某些骨骼/碰撞体的特殊敌人模型。未主动爆头时，头部保持最后尝试。
local ALTERNATIVE_BODY_NAMES = {
    "b_spine1",
    "b_pelvis",
    HEAD_BODY_NAME,
}

-- Screen-space probes around the vanilla torso point. Body-centre rays alone miss
-- narrow shoulder, hip and rear-body exposure around a Shield or deployable bag. A probe is accepted
-- only when the real bullet mask reports the target unit as the first hit.
local BODY_EDGE_PROBES = {
    { -24, 18 },
    {  24, 18 },
    { -26,  2 },
    {  26,  2 },
    { -24,-18 },
    {  24,-18 },
}

-- Small head-edge probes make intentional head aiming robust against helmet/visor
-- collision shapes and partially exposed heads without widening the normal body scan.
local HEAD_EDGE_PROBES = {
    { -8, 0 },
    {  8, 0 },
    {  0, 7 },
}

local bullet_slotmask
local shield_slotmask = World:make_slot_mask(8)
local tmp_target_pos = Vector3()
local tmp_body_pos = Vector3()
local tmp_head_pos = Vector3()
local tmp_ray_to = Vector3()
local tmp_ray_dir = Vector3()
local tmp_target_vec = Vector3()
local tmp_probe_forward = Vector3()
local tmp_probe_right = Vector3()
local tmp_probe_offset = Vector3()
local tmp_probe_pos = Vector3()
local mvec3_dir = mvector3.direction

local function is_alive_unit(unit)
    return unit and alive(unit)
end

local function is_tank(unit)
    if not is_alive_unit(unit) then
        return false
    end

    local base = unit:base()
    return base and base._tweak_table == TANK_TWEAK_TABLE
end

local function is_bag_deployable(unit)
    if not is_alive_unit(unit) then
        return false
    end

    local unit_name = unit:name()
    return unit_name == AMMO_BAG_UNIT or unit_name == DOCTOR_BAG_UNIT
end

-- 菜单项默认开启；旧配置没有该键时也按开启处理，保证升级后的预期行为。
local function multi_part_reachability_enabled()
    local setting = D:conf("sentry_multi_part_reachability")
    if setting == nil then
        return true
    end
    return setting and true or false
end

local function clamped_headshot_chance()
    return math.clamp(SENTRY_HEADSHOT_CHANCE or 0, 0, 1)
end

local function roll_headshot_chance()
    local chance = clamped_headshot_chance()
    if chance <= 0 then
        return false
    elseif chance >= 1 then
        return true
    end
    return math.random() < chance
end

local function set_vanilla_body_target_pos(unit, out_pos)
    local char_damage = unit:character_damage()
    if char_damage and char_damage.shoot_pos_mid then
        char_damage:shoot_pos_mid(out_pos)
        return true
    end

    local movement = unit:movement()
    if movement and movement.m_com then
        mvector3.set(out_pos, movement:m_com())
        return true
    end

    return false
end

local function set_named_body_target_pos(unit, body_name, out_pos)
    local body = unit:body(body_name)
    if not body then
        return nil
    end

    mvector3.set(out_pos, body:center_of_mass())
    return body
end

local function set_head_target_pos(unit, out_pos)
    local body = set_named_body_target_pos(unit, HEAD_BODY_NAME, out_pos)
    if body then
        return body
    end

    local movement = unit:movement()
    if movement and movement.m_head_pos then
        mvector3.set(out_pos, movement:m_head_pos())
        return true
    end

    return nil
end

-- 判断 Bulldozer 面罩是否已经被破坏，用于决定是否继续主动瞄头。
-- 兼顾子弹和爆炸两种破坏序列，避免只检查模型显隐造成误判。
local function visor_is_broken(unit)
    if not is_tank(unit) then
        return false
    end

    local visor_body = unit:body(VISOR_BODY_NAME)
    if not visor_body or not visor_body:enabled() then
        return true
    end

    local extension = visor_body:extension()
    local damage_ext = extension and extension.damage
    if not damage_ext then
        return false
    end

    -- Sequence endurance advances to the next stage when the visor breaks. The final
    -- stage is nil, while accumulated damage remains above zero. Check both bullet and
    -- explosion paths because either can destroy the visor in PDTH++.
    local damage_map = damage_ext._damage
    local endurance_map = damage_ext._endurance
    if damage_map and endurance_map then
        local bullet_damage = damage_map[IDS_BULLET]
        if bullet_damage and bullet_damage > 0 and endurance_map[IDS_BULLET] == nil then
            return true
        end

        local explosion_damage = damage_map[IDS_EXPLOSION]
        if explosion_damage and explosion_damage > 0 and endurance_map[IDS_EXPLOSION] == nil then
            return true
        end
    end

    return false
end

-- 使用与真实步哨子弹相同的碰撞掩码执行一次直接射线，并把终点略微延伸到目标后方，
-- 避免目标点位于碰撞体内部或表面误差导致漏判。
-- 这里刻意不再忽略医疗包/弹药袋：若它们是第一命中单位，就应像盾牌一样
-- 被报告给 Brain 的遮挡状态机，而不是让逻辑瞄准一条真实子弹无法通过的路径。
local function raycast_target_path(from_pos, target_pos, slotmask)
    mvec3_dir(tmp_ray_dir, from_pos, target_pos)
    mvector3.set(tmp_ray_to, target_pos)
    mvector3.multiply(tmp_ray_dir, RAY_EXTENSION)
    mvector3.add(tmp_ray_to, tmp_ray_dir)

    return World:raycast("ray", from_pos, tmp_ray_to, "slot_mask", slotmask)
end

-- 只有盾牌、医疗包和弹药袋会触发“保持关注但停火/优先转火”的特殊状态机。
-- 墙体等普通环境遮挡仍然只是不可达：多部位扫描可以寻找其它暴露点，但不会
-- 把墙后的敌人长期当作特殊待机目标。
local function is_sentry_obstruction(unit)
    if not is_alive_unit(unit) then
        return false
    end

    return unit:in_slot(shield_slotmask) or is_bag_deployable(unit)
end

-- 先检查炮台机械俯仰范围，避免选择一个射线畅通但炮口永远转不到的位置。
function SentryGunMovement:_pdthpp_can_reach_target_pos(target_pos)
    mvec3_dir(tmp_target_vec, self._m_head_pos, target_pos)
    local polar = tmp_target_vec:to_polar_with_reference(self._unit_fwd, self._unit_up)
    return polar.pitch >= MIN_PITCH and polar.pitch <= MAX_PITCH
end

-- 以敌人自己的 is_head() 为主要判定，并兼容实际头部 body 与 Bulldozer 面罩碰撞体。
local function hit_is_head(target_unit, col_ray)
    local hit_body = col_ray and col_ray.body
    if not hit_body then
        return false
    end

    local char_damage = target_unit:character_damage()
    if char_damage and char_damage.is_head and char_damage:is_head(hit_body) then
        return true
    end

    local head_body = target_unit:body(HEAD_BODY_NAME)
    if head_body and hit_body:key() == head_body:key() then
        return true
    end

    -- Bulldozer bullets must hit the visor before they can damage the protected head.
    return is_tank(target_unit) and hit_body:name() == IDS_VISOR or false
end

-- 对单个候选点做“真实弹道”验证：第一项有效命中必须是目标单位；
-- require_head 为真时还必须命中头/面罩。第二返回值专门报告是否被盾牌、医疗包或弹药袋挡住。
function SentryGunMovement:_pdthpp_target_ray_result(target_unit, target_pos, require_head)
    if not self:_pdthpp_can_reach_target_pos(target_pos) then
        return false, false, nil, false
    end

    bullet_slotmask = bullet_slotmask or managers.slot:get_mask("bullet_impact_targets_sentry_gun")
    local col_ray = raycast_target_path(self._m_head_pos, target_pos, bullet_slotmask)
    if not col_ray then
        return false, false, nil, false
    end

    if col_ray.unit == target_unit then
        local is_head = hit_is_head(target_unit, col_ray)
        if require_head and not is_head then
            return false, false, nil, false
        end

        return true, false, col_ray.position, is_head
    end

    local blocked_by_obstruction = is_sentry_obstruction(col_ray.unit) and true or false

    return false, blocked_by_obstruction, nil, false
end

-- 根据炮台视角建立横向探测基向量，使左右偏移始终对应目标屏幕轮廓而非世界固定方向。
function SentryGunMovement:_pdthpp_set_probe_basis(base_pos)
    mvec3_dir(tmp_probe_forward, self._m_head_pos, base_pos)
    mvector3.cross(tmp_probe_right, tmp_probe_forward, math.UP)
    if mvector3.length_sq(tmp_probe_right) < 0.0001 then
        return false
    end

    mvector3.normalize(tmp_probe_right)
    return true
end

function SentryGunMovement:_pdthpp_make_probe_pos(base_pos, side_offset, vertical_offset, out_pos)
    mvector3.set(out_pos, base_pos)

    if side_offset ~= 0 then
        mvector3.set(tmp_probe_offset, tmp_probe_right)
        mvector3.multiply(tmp_probe_offset, side_offset)
        mvector3.add(out_pos, tmp_probe_offset)
    end

    if vertical_offset ~= 0 then
        mvector3.set(tmp_probe_offset, math.UP)
        mvector3.multiply(tmp_probe_offset, vertical_offset)
        mvector3.add(out_pos, tmp_probe_offset)
    end
end

-- 依次测试一组轮廓偏移点，找到第一条真实可命中的路径即停止，减少额外射线数量。
function SentryGunMovement:_pdthpp_try_probe_pattern(target_unit, base_pos, probes, require_head, out_pos)
    if not self:_pdthpp_set_probe_basis(base_pos) then
        return false, false
    end

    local any_obstruction_block = false
    for _, offsets in ipairs(probes) do
        self:_pdthpp_make_probe_pos(base_pos, offsets[1], offsets[2], tmp_probe_pos)
        local reachable, obstruction_blocked, hit_pos = self:_pdthpp_target_ray_result(
            target_unit,
            tmp_probe_pos,
            require_head
        )
        any_obstruction_block = any_obstruction_block or obstruction_blocked

        if reachable then
            mvector3.set(out_pos, hit_pos or tmp_probe_pos)
            return true, any_obstruction_block
        end
    end

    return false, any_obstruction_block
end

-- 爆头概率按“本次选中该目标”只掷一次；候选评估阶段先暂存，正式成为 focus 后固定结果。
function SentryGunMovement:_pdthpp_roll_for_target(target_unit)
    local target_key = target_unit:key()
    if self._pdthpp_focus_unit_key == target_key and self._pdthpp_focus_headshot_roll ~= nil then
        return self._pdthpp_focus_headshot_roll
    end

    self._pdthpp_pending_headshot_rolls = self._pdthpp_pending_headshot_rolls or {}
    local pending_roll = self._pdthpp_pending_headshot_rolls[target_key]
    if pending_roll == nil then
        pending_roll = roll_headshot_chance()
        self._pdthpp_pending_headshot_rolls[target_key] = pending_roll
    end

    return pending_roll
end

-- Brain 切换目标时提交该目标的爆头随机结果并清空旧可达缓存，
-- 防止每次刷新都重新掷概率或沿用上一目标的瞄准点。
function SentryGunMovement:_pdthpp_on_focus_changed(target_unit)
    self._pdthpp_target_solution_cache = nil

    if not is_alive_unit(target_unit) then
        self._pdthpp_focus_unit_key = nil
        self._pdthpp_focus_headshot_roll = nil
        return
    end

    local target_key = target_unit:key()
    self._pdthpp_pending_headshot_rolls = self._pdthpp_pending_headshot_rolls or {}
    local roll = self._pdthpp_pending_headshot_rolls[target_key]
    if roll == nil then
        roll = roll_headshot_chance()
    end

    self._pdthpp_pending_headshot_rolls[target_key] = nil
    self._pdthpp_focus_unit_key = target_key
    self._pdthpp_focus_headshot_roll = roll
end

-- 计算本次是否“主动”爆头。Bulldozer 开关覆盖普通爆头开关，但仍受统一概率控制；
-- 面罩破碎后的继续爆头只在对应补充变量开启时生效。
function SentryGunMovement:_pdthpp_intentional_headshot(target_unit)
    local tank = is_tank(target_unit)
    local enabled = tank and SENTRY_TANK_HEADSHOT_ENABLED or SENTRY_HEADSHOT_ENABLED
    if not enabled or not self:_pdthpp_roll_for_target(target_unit) then
        return false
    end

    if tank and not SENTRY_TANK_CONTINUE_HEADSHOT_AFTER_VISOR_BREAK and visor_is_broken(target_unit) then
        return false
    end

    return true
end

-- 先瞄准头部中心，再尝试少量头部边缘点；实际采用射线命中位置，
-- 以适应头盔/面罩碰撞体与只露出部分头部的情况。
function SentryGunMovement:_pdthpp_try_head(target_unit, out_pos)
    if not set_head_target_pos(target_unit, tmp_head_pos) then
        return false, false
    end

    local reachable, obstruction_blocked, hit_pos = self:_pdthpp_target_ray_result(
        target_unit,
        tmp_head_pos,
        true
    )
    if reachable then
        mvector3.set(out_pos, hit_pos or tmp_head_pos)
        return true, false
    end

    local edge_reachable, edge_obstruction_blocked = self:_pdthpp_try_probe_pattern(
        target_unit,
        tmp_head_pos,
        HEAD_EDGE_PROBES,
        true,
        out_pos
    )
    return edge_reachable, obstruction_blocked or edge_obstruction_blocked
end

-- 原版躯干瞄准点是首选和默认回退点；它可达时不会运行任何多部位扫描。
function SentryGunMovement:_pdthpp_try_vanilla_body(target_unit, out_pos)
    if not set_vanilla_body_target_pos(target_unit, tmp_body_pos) then
        return false, false
    end

    local reachable, obstruction_blocked, hit_pos = self:_pdthpp_target_ray_result(
        target_unit,
        tmp_body_pos,
        false
    )
    if reachable then
        mvector3.set(out_pos, hit_pos or tmp_body_pos)
        return true, false
    end

    return false, obstruction_blocked
end

-- 在躯干中心被挡时探测肩膀、躯干侧缘和髋部轮廓，
-- 用于识别盾牌或部署包旁仍然露出的身体边缘，以及半蹲盾兵露出的后半身。
function SentryGunMovement:_pdthpp_try_body_edge_probes(target_unit, out_pos)
    if not set_vanilla_body_target_pos(target_unit, tmp_body_pos) then
        return false, false
    end

    return self:_pdthpp_try_probe_pattern(
        target_unit,
        tmp_body_pos,
        BODY_EDGE_PROBES,
        false,
        out_pos
    )
end

-- 多部位模式的完整备用扫描：先检查躯干轮廓，再检查模型实际存在的
-- 脊柱、骨盆与头部中心。手臂和腿部已刻意排除，避免不同模型的肢体碰撞差异
-- 让炮台选中不稳定的瞄准点。找到第一处可命中部位即返回，并累计
-- “是否被特殊遮挡物挡住”供 Brain 处理。
function SentryGunMovement:_pdthpp_try_alternative_bodies(target_unit, out_pos, skip_head)
    local any_obstruction_block = false

    -- Test the silhouette around the upper torso first. This catches exposed shoulders,
    -- hips and the rear half of a crouched Shield, or body exposed beside a deployable bag, without requiring every model to have
    -- identical named limb bodies.
    local edge_reachable, edge_obstruction_blocked = self:_pdthpp_try_body_edge_probes(
        target_unit,
        out_pos
    )
    any_obstruction_block = any_obstruction_block or edge_obstruction_blocked
    if edge_reachable then
        return true, false, false
    end

    for _, body_name in ipairs(ALTERNATIVE_BODY_NAMES) do
        if not (skip_head and body_name == HEAD_BODY_NAME) then
            local body = set_named_body_target_pos(target_unit, body_name, tmp_target_pos)
            if body then
                local require_head = body_name == HEAD_BODY_NAME
                local reachable, obstruction_blocked, hit_pos, actual_head = self:_pdthpp_target_ray_result(
                    target_unit,
                    tmp_target_pos,
                    require_head
                )
                any_obstruction_block = any_obstruction_block or obstruction_blocked

                if reachable then
                    mvector3.set(out_pos, hit_pos or tmp_target_pos)
                    return true, require_head and actual_head or false, false
                end
            end
        end
    end

    return false, false, any_obstruction_block
end

-- 单次目标点决策顺序：主动头部→原版躯干→（可选）多部位备用点→躯干回退。
-- 即使最后没有可射击点，也保留躯干位置供炮台继续关注，并返回特殊遮挡状态。
-- 第四返回值 shootable 只在真实弹道首先命中目标单位时为 true；不能把“有回退坐标”
-- 错当成“当前确实可射击”，否则失去视线的目标会被 Brain 逐帧清空并重新选回。
function SentryGunMovement:_pdthpp_build_target_solution(target_unit, out_pos)
    local intentional_headshot = self:_pdthpp_intentional_headshot(target_unit)
    local multi_part = multi_part_reachability_enabled()
    local body_obstruction_blocked = false
    local head_obstruction_blocked = false

    if intentional_headshot then
        local head_reachable
        head_reachable, head_obstruction_blocked = self:_pdthpp_try_head(target_unit, out_pos)
        if head_reachable then
            return true, true, false, true
        end
    end

    local body_reachable
    body_reachable, body_obstruction_blocked = self:_pdthpp_try_vanilla_body(target_unit, out_pos)
    if body_reachable then
        return true, false, false, true
    end

    if multi_part then
        local alt_reachable, alt_is_head, alt_obstruction_blocked = self:_pdthpp_try_alternative_bodies(
            target_unit,
            out_pos,
            intentional_headshot
        )
        if alt_reachable then
            return true, alt_is_head, false, true
        end

        body_obstruction_blocked = body_obstruction_blocked or head_obstruction_blocked or alt_obstruction_blocked
    end

    -- Preserve the vanilla torso point when no permitted point is reachable. The brain
    -- uses the third return value to apply the shared shield/bag hold and reselect behaviour.
    if not set_vanilla_body_target_pos(target_unit, out_pos) then
        return false, false, false, false
    end

    return true, false, body_obstruction_blocked, false
end

-- 带分级缓存的统一入口。缓存键同时包含设置、爆头决策和面罩状态，
-- 这些条件改变时会强制重新计算，避免使用已失效的瞄准结果。
function SentryGunMovement:_pdthpp_target_position(target_unit, out_pos)
    if not is_alive_unit(target_unit) then
        return false, false, false, false
    end

    local target_key = target_unit:key()
    local is_current_target = self._pdthpp_focus_unit_key == target_key
    local now = TimerManager:game():time()
    local cache_time = is_current_target and CURRENT_TARGET_CACHE_TIME or OTHER_TARGET_CACHE_TIME
    local multi_part = multi_part_reachability_enabled()
    local intentional_headshot = self:_pdthpp_intentional_headshot(target_unit)
    local tank_visor_broken = is_tank(target_unit) and visor_is_broken(target_unit) or false

    self._pdthpp_target_solution_cache = self._pdthpp_target_solution_cache or {}
    local cache = self._pdthpp_target_solution_cache[target_key]
    if cache
        and now - cache.t < cache_time
        and cache.multi_part == multi_part
        and cache.intentional_headshot == intentional_headshot
        and cache.tank_visor_broken == tank_visor_broken then
        mvector3.set(out_pos, cache.pos)
        return cache.valid, cache.is_head, cache.obstruction_blocked, cache.shootable
    end

    local valid, is_head, obstruction_blocked, shootable =
        self:_pdthpp_build_target_solution(target_unit, out_pos)
    self._pdthpp_target_solution_cache[target_key] = {
        t = now,
        pos = mvector3.copy(out_pos),
        valid = valid,
        is_head = is_head,
        obstruction_blocked = obstruction_blocked,
        shootable = shootable,
        multi_part = multi_part,
        intentional_headshot = intentional_headshot,
        tank_visor_broken = tank_visor_broken,
    }

    return valid, is_head, obstruction_blocked, shootable
end

-- 目标离开侦测表时清除其概率暂存和瞄准缓存，防止单位键长期积累。
function SentryGunMovement:_pdthpp_forget_target(target_key)
    if not target_key then
        return
    end

    if self._pdthpp_pending_headshot_rolls then
        self._pdthpp_pending_headshot_rolls[target_key] = nil
    end
    if self._pdthpp_target_solution_cache then
        self._pdthpp_target_solution_cache[target_key] = nil
    end

    if self._pdthpp_focus_unit_key == target_key then
        self._pdthpp_focus_unit_key = nil
        self._pdthpp_focus_headshot_roll = nil
    end
end

function SentryGunMovement:_pdthpp_clear_targeting_state()
    self._pdthpp_focus_unit_key = nil
    self._pdthpp_focus_headshot_roll = nil
    self._pdthpp_pending_headshot_rolls = nil
    self._pdthpp_target_solution_cache = nil
end

-- 覆盖原版炮口方向计算，使物理转向使用 PDTH++ 解析出的同一目标点。
function SentryGunMovement:_get_target_dir(attention)
    if not attention then
        if self._switched_off then
            mvector3.set(tmp_target_vec, self._unit_fwd)
            mvector3.rotate_with(tmp_target_vec, self._switch_off_rot)
            return tmp_target_vec
        end

        return self._unit_fwd
    end

    local target_pos
    if attention.unit then
        target_pos = tmp_target_pos
        if not self:_pdthpp_target_position(attention.unit, target_pos) then
            mvector3.set(target_pos, attention.unit:movement():m_com())
        end
    else
        target_pos = attention.pos
    end

    mvec3_dir(tmp_target_vec, self._m_head_pos, target_pos)
    return tmp_target_vec
end

-- 停用/销毁时清理目标缓存与概率状态，避免复用旧单位键或旧关卡结果。
local original_set_active = SentryGunMovement.set_active
function SentryGunMovement:set_active(state)
    if not state then
        self:_pdthpp_clear_targeting_state()
    end
    return original_set_active(self, state)
end

local original_pre_destroy = SentryGunMovement.pre_destroy
if original_pre_destroy then
    function SentryGunMovement:pre_destroy(...)
        self:_pdthpp_clear_targeting_state()
        return original_pre_destroy(self, ...)
    end
end
