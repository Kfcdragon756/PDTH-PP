local module = ... or D:module("PDTH++")

local next_allowed_tie_t = -100
local cannot_tie = function()
	-- You cannot tie yourself if you don't have the skill.
	if not managers.player:has_special_equipment("extra_cable_tie") then
		return true
	end

	-- Check for active cooldown to prevent spam
	if TimerManager:game():time() < next_allowed_tie_t then
		return true
	end

	return false
end

module:hook("OnKeyPressed", "tie_yourself", nil, "GAME", function()
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	if cannot_tie() then
		return
	end

	local state_name = player_unit:movement():current_state_name()
	if state_name == "arrested" then
		managers.player:set_player_state("standard")
		return
	end

	if state_name ~= "standard" then
		return
	end

	local cable_tie_data = managers.player:has_special_equipment("cable_tie")
	if (tablex.get(cable_tie_data, "amount") or 0) <= 0 then
		return
	end

	managers.player:remove_special("cable_tie")
	player_unit:movement():on_disarmed()

	next_allowed_tie_t = TimerManager:game():time() + 0.5
end)

-- global toggle for other code to read
m308_fov_zoom = false

module:hook("OnKeyPressed", "change_308_fov_zoom", nil, "GAME", function(self)
	local player_unit = managers.player:player_unit()
	if not alive(player_unit) then
		return
	end

	local inv = player_unit:inventory()
	local equipped = inv and inv:equipped_unit()
	if not equipped then
		return
	end

	local name = equipped:base()._name_id
	if name ~= "m14" then
		return
	end

	-- play dryfire sound
	local weapon_data = tweak_data.weapon[name]
	if equipped:base()._sound_fire and weapon_data and weapon_data.sounds and weapon_data.sounds.dryfire then
		equipped:base()._sound_fire:post_event(weapon_data.sounds.dryfire)
	end

	local plr_state = player_unit:movement():current_state()
	if not plr_state then
		return
	end

	local in_steelsight = plr_state._in_steelsight
	local ducking = plr_state._ducking
	local stance_key = in_steelsight and "steelsight" or ducking and "crouched" or "standard"

	local stances = tweak_data.player.stances[name] or tweak_data.player.stances.default
	local zoom_fov = stances.steelsight and stances.steelsight.zoom_fov

	-- determine target FOV and toggle state
	local target_fov
	if m308_fov_zoom then
		m308_fov_zoom = false
		target_fov = managers.user:get_setting("fov_zoom")
	else
		m308_fov_zoom = true
		target_fov = D:conf("m308_fov_zoom_set")
	end

	-- apply FOV change instantly and update mouse sensitivity based on steelsight zoom_fov if in steelsight
	if plr_state._camera_unit and plr_state._camera_unit:base() and target_fov then
		plr_state._camera_unit:base():set_stance_newfov_instant(stance_key, target_fov)
	end

	if in_steelsight then
		managers.menu:set_mouse_sensitivity(zoom_fov)
	end
end)

--[[
PDTH++ 全局按键与自定义网络消息入口。
本轮新增的步哨消息在此集中分发：主机处理回收/状态请求，客机处理回收结果、
步哨销毁和精确状态。消息处理只负责网络方向与来源验证，具体算法位于 sentryammo.lua。
]]


-- 步哨网络消息方向约定：
-- PickupRequest / StatusRequest：客机→主机；PickupResult / Status：主机→指定客机；
-- Destroyed：主机→所有客机。每个分支都验证发送方角色，避免客户端伪造权威事件。
module:hook("OnNetworkDataRecv", "PDTHPP_SentryEconomyNetwork", {
	"PDTHPPSentryPickupRequest",
	"PDTHPPSentryPickupResult",
	"PDTHPPSentryDestroyed",
	"PDTHPPSentryStatus",
	"PDTHPPSentryStatusRequest",
}, function(peer, data_type, data)
	if type(data) ~= "table" or data.module ~= module:id() then
		return
	end

	if data_type == "PDTHPPSentryPickupRequest" then
		if not Network:is_server() or not peer or peer:is_local_user() then
			return
		end
		local unit = module:pdthpp_find_sentry_by_id(data.unit_id)
		local success = unit and module:pdthpp_host_process_sentry_pickup(peer, unit) or false
		if not success then
			DNet:send_to_peer(peer, "PDTHPPSentryPickupResult", {
				module = module:id(),
				success = false,
				unit_id = data.unit_id,
			}, false, true)
		end

	elseif data_type == "PDTHPPSentryPickupResult" then
		if Network:is_server() or not peer or not peer:is_server() then
			return
		end
		local unit = module:pdthpp_find_sentry_by_id(data.unit_id)
		if alive(unit) then
			local interaction = unit:interaction()
			if interaction then
				interaction._pdthpp_pickup_requested = nil
			end
		end

		local plan = module._pdthpp_pending_sentry_pickup_costs[data.unit_id]
		module._pdthpp_pending_sentry_pickup_costs[data.unit_id] = nil
		if data.success and plan and module:pdthpp_has_local_sentry_equipment_space()
			and module:pdthpp_apply_sentry_pickup_cost_plan(plan) then
			module:pdthpp_add_local_sentry_equipment()
		end

	elseif data_type == "PDTHPPSentryDestroyed" then
		if Network:is_server() or not peer or not peer:is_server() then
			return
		end
		local unit = module:pdthpp_find_sentry_by_id(data.unit_id)
		if alive(unit) then
			local base = unit:base()
			if base then
				base._pdthpp_pickup_in_progress = true
			end
			module:pdthpp_destroy_sentry_exact(unit)
		end

	elseif data_type == "PDTHPPSentryStatus" then
		if Network:is_server() or not peer or not peer:is_server() then
			return
		end
		module:pdthpp_apply_remote_sentry_status(data)

	elseif data_type == "PDTHPPSentryStatusRequest" then
		if not Network:is_server() or not peer or peer:is_local_user() then
			return
		end
		local unit = module:pdthpp_find_sentry_by_id(data.unit_id)
		if alive(unit) then
			module:pdthpp_send_sentry_status_to_peer(unit, peer)
		end
	end
end)

-- ============================================================================
-- 用户可调参数区
-- 后续若要改耐久、命中范围或弹孔显示，优先只改这一段。
-- ============================================================================

-- 是否保留盾牌表面的弹孔贴花。
-- true  = 保留原版 dm_body 弹孔贴花。
-- false = 尝试在盾牌生成后隐藏 dm_body，可避免破洞中露出透明贴花细线。
module.ENABLE_SHIELD_BULLET_DECALS = false

-- 是否支持盾兵死亡后掉落在地上的盾牌。
-- true  = 使用盾牌实际 orientation object / dropped body 的变换继续判定可破坏区域与穿透。
-- false = 只处理仍由活着盾兵持有的盾牌。
module.ENABLE_DROPPED_SHIELD_SUPPORT = true

-- 是否把五个实际命中判定区域画在盾牌上。
-- true  = 每帧绘制五个彩色线框盒，手持/掉落盾牌都会跟随其实际旋转。
-- false = 完全关闭调试绘制（正式游玩建议保持 false）。
module.debug_vision = false

-- 判定逻辑本身只检查局部 X/Z；Y 方向由“子弹已经命中盾牌碰撞体”这一条件限制。
-- 为了在画面中看清区域，这里用一个覆盖盾牌正面弯曲深度的 Y 范围画成线框盒。
-- 修改这两个值只改变调试图形厚度，不改变实际命中判定。
module.DEBUG_VISION_Y_MIN = 5
module.DEBUG_VISION_Y_MAX = 30

-- 调试线框颜色：{红, 绿, 蓝}，范围 0~1。
module.DEBUG_VISION_COLORS = {
	left_top = { 0.10, 1.00, 0.10 },      -- 亮绿
	left_bottom = { 1.00, 0.75, 0.05 },   -- 橙黄
	right_top = { 0.05, 0.80, 1.00 },     -- 青蓝
	right_bottom = { 1.00, 0.10, 1.00 },  -- 品红
	middle = { 1.00, 0.10, 0.10 },        -- 红
}

-- 五个可破坏区域的独立耐久。
-- 当前基础值为 20；左下为 25（1.25 倍），中央为 40（2 倍）。
-- 这里已经使用具体数值，后续可以单独修改任意一项。
module.REGION_HEALTH = {
	left_top = 14,
	left_bottom = 14,
	right_top = 14,
	right_bottom = 14,
	middle = 25,
}

-- 命中区域：盾牌局部坐标中的 X/Z 轴矩形。
-- 数值来自 shield_diagnostic 的射击记录，并略微向外扩展，方便实际瞄准。
-- 若两个区域少量重叠，代码会选择“距离区域中心更近”的那个。
-- Y 不参与判定，因为盾牌左右表面有弯折，同一筋条两端的局部 Y 差异很大。
module.HIT_AREAS = {
	left_top = {
		x_min = -3.40, x_max = 26.30,
		z_min = 34.15, z_max = 42.90,
	},
	left_bottom = {
		x_min = -3.40, x_max = 26.30,
		z_min = 25.40, z_max = 34.15,
	},
	right_top = {
		x_min = -42.70, x_max = -13.00,
		z_min = 34.15, z_max = 42.90,
	},
	right_bottom = {
		x_min = -42.70, x_max = -13.00,
		z_min = 25.40, z_max = 34.15,
	},
	middle = {
		x_min = -13.00, x_max = -3.40,
		z_min = 25.40, z_max = 42.90,
	},
}

-- 区域检测顺序只用于稳定遍历；重叠区域仍会按中心距离决定。
module.REGION_ORDER = {
	"left_top",
	"left_bottom",
	"right_top",
	"right_bottom",
	"middle",
}

-- 每个区域对应的模型对象名。
-- right_top 的完整模型按当前 Blender 名称使用 _intact_full；无需强制重命名。
module.MODEL_OBJECTS = {
	left_top = {
		intact = Idstring("g_grille_left_top_intact"),
		broken_outer = Idstring("g_grille_left_top_broken_outer"),
		broken_inner = Idstring("g_grille_left_top_broken_inner"),
	},
	left_bottom = {
		intact = Idstring("g_grille_left_bottom_intact"),
		broken_outer = Idstring("g_grille_left_bottom_broken_outer"),
		broken_inner = Idstring("g_grille_left_bottom_broken_inner"),
	},
	right_top = {
		intact = Idstring("g_grille_right_top_intact_full"),
		broken_outer = Idstring("g_grille_right_top_broken_outer"),
		broken_inner = Idstring("g_grille_right_top_broken_inner"),
	},
	right_bottom = {
		intact = Idstring("g_grille_right_bottom_intact"),
		broken_outer = Idstring("g_grille_right_bottom_broken_outer"),
		broken_inner = Idstring("g_grille_right_bottom_broken_inner"),
	},
	middle = {
		intact = Idstring("g_grille_middle_intact"),
		broken_top = Idstring("g_grille_middle_broken_top"),
		broken_bottom = Idstring("g_grille_middle_broken_bottom"),
	},
}

-- 独立主体架构：
-- 原版 g_body 和 dm_body 完整保留在 Base Model 中；原版主体只隐藏，不进行 Blender 往返。
-- 实际显示的是新加入的 g_body_breakable，以及各个可切换筋条对象。
module.OBJ_ORIGINAL_BODY = Idstring("g_body")
module.OBJ_BREAKABLE_BODY = Idstring("g_body_breakable")

-- 左下备用模型：当前版本完全不用，始终强制隐藏。
module.OBJ_LEFT_BOTTOM_BACKUP = Idstring("g_grille_left_bottom_broken_backup")
module.OBJ_DECAL_BODY = Idstring("dm_body")
module.BODY_DROPPED = Idstring("dropped_body")

-- ============================================================================
-- 运行时状态
-- ============================================================================

-- 持盾期间用弱键表即可；盾牌掉落后原 inventory 不再可靠持有 Lua 引用，
-- 因此另用强引用表保存掉落盾牌，避免状态被 Lua GC 回收后无法识别。
module._grille_states = module._grille_states or setmetatable({}, { __mode = "k" })
module._dropped_shields = module._dropped_shields or {}
module._pending_passthrough = module._pending_passthrough or {}
module._temporary_sounds = module._temporary_sounds or {}
module._processing_passthrough = module._processing_passthrough or false

local idstr_fragment_effect = Idstring("effects/particles/bullet_hit/fallback/fallback")

local function local_chat(message)
	if Util and Util.chat_message then
		Util:chat_message(message, "local", "ShieldGrille", {
			parse_colors = false,
			sanitize = false,
		})
	end
end

local function set_object_visible(unit, object_name, visible)
	if not alive(unit) then
		return false
	end

	local object = unit:get_object(object_name)
	if not object then
		return false
	end

	object:set_visibility(visible)
	return true
end

local function new_region_table(default_value)
	return {
		left_top = default_value,
		left_bottom = default_value,
		right_top = default_value,
		right_bottom = default_value,
		middle = default_value,
	}
end

-- 只处理本机玩家发射的子弹，保持本 Mod 为客户端侧功能。
function module:is_local_player_attack(user_unit)
	if not alive(user_unit) then
		return false
	end

	local base = user_unit:base()
	return base and base.is_local_player == true
end

-- 从弱键状态表或掉落盾牌强引用表中读取已有状态。
function module:get_existing_grille_state(shield_unit)
	if not alive(shield_unit) then
		return nil
	end

	local state = self._grille_states[shield_unit]
	if state then
		return state
	end

	local key = shield_unit:key()
	local dropped_data = key and self._dropped_shields[key]
	if dropped_data and alive(dropped_data.unit) then
		state = dropped_data.state
		-- 重新写回弱键表，方便后续快速读取。
		self._grille_states[shield_unit] = state
		return state
	end

	return nil
end

-- 盾牌掉落后 parent 会失效，但只要已登记状态仍存在，就继续视为本 Mod 目标。
function module:is_known_shield(shield_unit)
	if not alive(shield_unit) then
		return false
	end

	if self:get_existing_grille_state(shield_unit) then
		return true
	end

	-- 尚未登记的新盾牌仍按原版 slot 8 + 活盾兵 parent 识别。
	if not shield_unit:in_slot(8) then
		return false
	end

	local parent = shield_unit:parent()
	if alive(parent) then
		local base = parent:base()
		return base and base._tweak_table == "shield"
	end

	return false
end

-- 把盾牌登记为“已掉落”。
-- 使用强引用保存 unit + state，避免盾兵死亡后 inventory/parent 不再持有 Lua userdata，
-- 导致弱键状态被回收、掉落盾牌重新变成不可识别对象。
function module:mark_shield_dropped(shield_unit)
	if not self.ENABLE_DROPPED_SHIELD_SUPPORT or not alive(shield_unit) then
		return nil
	end

	local state = self:register_shield(shield_unit)
	if not state then
		return nil
	end

	state.dropped = true
	local key = shield_unit:key()
	if key then
		self._dropped_shields[key] = {
			unit = shield_unit,
			state = state,
		}
	end

	-- drop_shield 的 sequence 只切换 held/dropped body，理论上不改 graphics；
	-- 这里仍重新应用一次显隐，防止其它 Mod 或序列重置模型状态。
	self:apply_visual_state(shield_unit, state)
	return state
end

-- 清理已经被引擎删除的掉落盾牌强引用。
function module:cleanup_dropped_shields()
	for key, data in pairs(self._dropped_shields) do
		if not data or not alive(data.unit) then
			self._dropped_shields[key] = nil
		end
	end

	-- 联网索引采用强引用，确保掉落盾牌在各端仍可按“原持有者网络 ID”找到。
	-- 引擎真正删除盾牌后必须同步清理，防止跨关卡残留无效 userdata。
	if self._grille_states_by_net_id then
		for net_id, data in pairs(self._grille_states_by_net_id) do
			if not data or not alive(data.unit) then
				self._grille_states_by_net_id[net_id] = nil
			end
		end
	end
end

-- 获取用于局部坐标换算的实际盾牌变换。
-- 优先采用 orientation_object（rp_weapon）：它在手持时跟随盾兵，掉落后跟随动态 body，
-- 因而盾牌无论直立、倾斜还是平躺，局部 X/Z 区域都会一起旋转。
-- 若 orientation object 不可用，再退回本次命中的 body，最后才使用 unit 根变换。
function module:get_shield_transform(shield_unit, hit_body)
	local orientation_object = shield_unit:orientation_object()
	if orientation_object then
		return orientation_object:position(), orientation_object:rotation()
	end

	if alive(hit_body) then
		return hit_body:position(), hit_body:rotation()
	end

	if self.ENABLE_DROPPED_SHIELD_SUPPORT then
		local dropped_body = shield_unit:body(self.BODY_DROPPED)
		if alive(dropped_body) and dropped_body:enabled() then
			return dropped_body:position(), dropped_body:rotation()
		end
	end

	return shield_unit:position(), shield_unit:rotation()
end

-- 把世界坐标命中点转换为盾牌自身的局部坐标。
function module:get_local_hit(shield_unit, world_position, hit_body)
	local origin, rotation = self:get_shield_transform(shield_unit, hit_body)
	local relative = world_position - origin
	return mvector3.dot(relative, rotation:x()),
		mvector3.dot(relative, rotation:y()),
		mvector3.dot(relative, rotation:z())
end

-- 把盾牌局部坐标转换回世界坐标，供 debug_vision 绘图使用。
local function shield_local_to_world(origin, rotation, local_x, local_y, local_z)
	return origin
		+ rotation:x() * local_x
		+ rotation:y() * local_y
		+ rotation:z() * local_z
end

-- 当联网破坏快照没有携带可靠命中点时，用区域中心构造本机视觉效果位置与法线。
-- 这只影响粒子/声音，不改变实际判定框或盾牌物理位置。
function module:get_region_effect_transform(shield_unit, region_name)
	local area = self.HIT_AREAS[region_name]
	if not alive(shield_unit) or not area then
		return nil, nil
	end

	local origin, rotation = self:get_shield_transform(shield_unit, nil)
	if not origin or not rotation then
		return nil, nil
	end

	local local_x = (area.x_min + area.x_max) * 0.5
	local local_y = (self.DEBUG_VISION_Y_MIN + self.DEBUG_VISION_Y_MAX) * 0.5
	local local_z = (area.z_min + area.z_max) * 0.5
	return shield_local_to_world(origin, rotation, local_x, local_y, local_z), rotation:y()
end

-- 绘制一条调试线。Application:draw_line 每帧只保留一帧，因此必须在 end_update 重画。
local function draw_debug_line(from, to, color)
	if not Application or not Application.draw_line then
		return
	end

	Application:draw_line(from, to, color[1], color[2], color[3])
end

-- 在盾牌实际变换下绘制一个区域的线框盒。
-- 盒子的 X/Z 与真实判定完全一致；Y 厚度只用于可视化，不参与实际判定。
function module:draw_debug_region(shield_unit, area, color)
	if not alive(shield_unit) or not area or not color then
		return
	end

	local origin, rotation = self:get_shield_transform(shield_unit, nil)
	if not origin or not rotation then
		return
	end

	local y_min = self.DEBUG_VISION_Y_MIN
	local y_max = self.DEBUG_VISION_Y_MAX
	local p = {
		shield_local_to_world(origin, rotation, area.x_min, y_min, area.z_min),
		shield_local_to_world(origin, rotation, area.x_max, y_min, area.z_min),
		shield_local_to_world(origin, rotation, area.x_max, y_min, area.z_max),
		shield_local_to_world(origin, rotation, area.x_min, y_min, area.z_max),
		shield_local_to_world(origin, rotation, area.x_min, y_max, area.z_min),
		shield_local_to_world(origin, rotation, area.x_max, y_max, area.z_min),
		shield_local_to_world(origin, rotation, area.x_max, y_max, area.z_max),
		shield_local_to_world(origin, rotation, area.x_min, y_max, area.z_max),
	}

	-- 靠近/远离盾牌的两个矩形。
	draw_debug_line(p[1], p[2], color)
	draw_debug_line(p[2], p[3], color)
	draw_debug_line(p[3], p[4], color)
	draw_debug_line(p[4], p[1], color)
	draw_debug_line(p[5], p[6], color)
	draw_debug_line(p[6], p[7], color)
	draw_debug_line(p[7], p[8], color)
	draw_debug_line(p[8], p[5], color)

	-- 连接前后矩形，显示调试盒的深度。
	draw_debug_line(p[1], p[5], color)
	draw_debug_line(p[2], p[6], color)
	draw_debug_line(p[3], p[7], color)
	draw_debug_line(p[4], p[8], color)
end

-- 绘制所有已登记盾牌的五个判定区；用 unit key 去重，避免掉落盾牌被画两次。
function module:draw_debug_vision()
	if self.debug_vision ~= true then
		return
	end

	Global.render_debug = Global.render_debug or {}
	Global.render_debug.draw_enabled = true

	local drawn = {}
	local function draw_shield(shield_unit)
		if not alive(shield_unit) then
			return
		end

		local key = shield_unit:key()
		if key and drawn[key] then
			return
		end
		if key then
			drawn[key] = true
		end

		for i = 1, #module.REGION_ORDER do
			local region_name = module.REGION_ORDER[i]
			module:draw_debug_region(
				shield_unit,
				module.HIT_AREAS[region_name],
				module.DEBUG_VISION_COLORS[region_name]
			)
		end
	end

	for shield_unit, _ in pairs(self._grille_states) do
		draw_shield(shield_unit)
	end

	for _, data in pairs(self._dropped_shields) do
		if data then
			draw_shield(data.unit)
		end
	end
end

-- 在五个矩形区域中寻找本次命中的筋条。
-- 若左上/左下等矩形边缘少量重叠，选择归一化中心距离更小的区域。
function module:find_hit_region(shield_unit, world_position, hit_body)
	local local_x, local_y, local_z = self:get_local_hit(shield_unit, world_position, hit_body)
	local best_region = nil
	local best_score = nil

	for i = 1, #self.REGION_ORDER do
		local region_name = self.REGION_ORDER[i]
		local area = self.HIT_AREAS[region_name]
		if local_x >= area.x_min and local_x <= area.x_max
			and local_z >= area.z_min and local_z <= area.z_max then
			local center_x = (area.x_min + area.x_max) * 0.5
			local center_z = (area.z_min + area.z_max) * 0.5
			local half_x = math.max((area.x_max - area.x_min) * 0.5, 0.001)
			local half_z = math.max((area.z_max - area.z_min) * 0.5, 0.001)
			local normalized_x = (local_x - center_x) / half_x
			local normalized_z = (local_z - center_z) / half_z
			local score = normalized_x * normalized_x + normalized_z * normalized_z

			if not best_score or score < best_score then
				best_region = region_name
				best_score = score
			end
		end
	end

	return best_region, local_x, local_y, local_z
end

-- 应用四根横筋的完整/破损模型显隐。
local function apply_side_grille_visual(module_ref, shield_unit, state, region_name, missing)
	local objects = module_ref.MODEL_OBJECTS[region_name]
	local broken = state.broken[region_name] == true
	local middle_broken = state.broken.middle == true

	if not set_object_visible(shield_unit, objects.intact, not broken) then
		missing[#missing + 1] = region_name .. ".intact"
	end
	if not set_object_visible(shield_unit, objects.broken_outer, broken) then
		missing[#missing + 1] = region_name .. ".broken_outer"
	end
	if not set_object_visible(shield_unit, objects.broken_inner, broken and not middle_broken) then
		missing[#missing + 1] = region_name .. ".broken_inner"
	end
end

-- 把当前逻辑状态同步到实际模型对象。
function module:apply_visual_state(shield_unit, state)
	if not alive(shield_unit) or not state then
		return
	end

	local missing = {}

	-- 始终保留原版 g_body 的数据，但不显示它；
	-- 显示新加入的 g_body_breakable，避免修改原版主体时连带破坏 dm_body 贴花数据。
	if not set_object_visible(shield_unit, self.OBJ_ORIGINAL_BODY, false) then
		missing[#missing + 1] = "g_body(original)"
	end
	if not set_object_visible(shield_unit, self.OBJ_BREAKABLE_BODY, true) then
		missing[#missing + 1] = "g_body_breakable"
	end

	apply_side_grille_visual(self, shield_unit, state, "left_top", missing)
	apply_side_grille_visual(self, shield_unit, state, "left_bottom", missing)
	apply_side_grille_visual(self, shield_unit, state, "right_top", missing)
	apply_side_grille_visual(self, shield_unit, state, "right_bottom", missing)

	local middle_objects = self.MODEL_OBJECTS.middle
	local middle_broken = state.broken.middle == true
	if not set_object_visible(shield_unit, middle_objects.intact, not middle_broken) then
		missing[#missing + 1] = "middle.intact"
	end
	if not set_object_visible(shield_unit, middle_objects.broken_top, middle_broken) then
		missing[#missing + 1] = "middle.broken_top"
	end
	if not set_object_visible(shield_unit, middle_objects.broken_bottom, middle_broken) then
		missing[#missing + 1] = "middle.broken_bottom"
	end

	-- 备用模型当前版本永远不显示。
	set_object_visible(shield_unit, self.OBJ_LEFT_BOTTOM_BACKUP, false)

	-- 弹孔总开关。若 dm_body 无法作为普通 object 获取，则保持 .object 中的默认值。
	set_object_visible(shield_unit, self.OBJ_DECAL_BODY, self.ENABLE_SHIELD_BULLET_DECALS)

	if not state.visual_objects_checked then
		state.visual_objects_checked = true
		if #missing > 0 then
			self:log(1, "apply_visual_state", "missing model objects: " .. table.concat(missing, ", "))
		end
	end
end

-- 首次见到一面盾牌时，为五个区域建立独立伤害和破坏状态。
function module:register_shield(shield_unit, owner_unit, forced_net_id)
	if not alive(shield_unit) then
		return nil
	end

	local state = self:get_existing_grille_state(shield_unit)
	if state then
		-- 盾牌本身由各客户端本地 spawn，unit:id() 并不适合作为跨客户端标识。
		-- 网络层改用原持盾盾兵的同步单位 ID；掉落后该 ID 继续保存在 state 中。
		if self.bind_grille_network_identity then
			self:bind_grille_network_identity(shield_unit, state, owner_unit, forced_net_id)
		end
		self:apply_visual_state(shield_unit, state)
		return state
	end

	if not shield_unit:in_slot(8) then
		return nil
	end

	state = {
		damage = new_region_table(0),
		broken = new_region_table(false),
		visual_objects_checked = false,
		dropped = false,
		-- revision 只由主机递增；客机用它丢弃重发或乱序到达的旧快照。
		revision = 0,
		network_initialized = false,
	}
	self._grille_states[shield_unit] = state

	if self.bind_grille_network_identity then
		self:bind_grille_network_identity(shield_unit, state, owner_unit, forced_net_id)
	end
	self:apply_visual_state(shield_unit, state)
	return state
end

function module:get_grille_state(shield_unit)
	return self:register_shield(shield_unit)
end

-- 播放破坏粒子与声音。当前继续复用已验证可用的原版效果路径。
function module:play_break_effects(shield_unit, position, normal, region_name)
	if not position then
		return
	end

	local break_normal = normal or math.UP
	local rotation = Rotation()
	if alive(shield_unit) then
		local _, actual_rotation = self:get_shield_transform(shield_unit, nil)
		rotation = actual_rotation or rotation
	end
	local right = rotation:x()
	local up = rotation:z()
	local effect_manager = World:effect_manager()

	for i = 1, 8 do
		local angle = (i - 1) * math.pi * 0.25
		local offset = right * (math.cos(angle) * 8) + up * (math.sin(angle) * 5)
		local effect_position = position + offset
		local effect_normal = break_normal
			+ right * (math.cos(angle) * 0.55)
			+ up * (math.sin(angle) * 0.55)
		mvector3.normalize(effect_normal)
		effect_manager:spawn({
			effect = idstr_fragment_effect,
			position = effect_position,
			normal = effect_normal,
		})
	end

	local sound_source = SoundDevice:create_source("BreakableShieldGrille")
	sound_source:set_position(position)
	sound_source:set_switch("materials", "glass_breakable")
	sound_source:post_event("bullet_hit")
	self._temporary_sounds[#self._temporary_sounds + 1] = {
		source = sound_source,
		expire_t = Application:time() + 2,
	}
	if module.debug_vision and module.debug_vision == true then
		local_chat("Shield grille broken: " .. tostring(region_name))
	end
end

-- 对指定区域累计伤害。
-- 中央竖筋破坏时：
-- 1. 中央切换为上下两段破损模型；
-- 2. 四根横筋全部直接标记为破损；
-- 3. 因 middle 已破坏，四根横筋的 inner 模型都会被隐藏。
function module:damage_region(shield_unit, region_name, position, normal, damage)
	-- 与原版敌人伤害流程相同，射手所在客户端可以先在本地累计耐久并立即破坏；
	-- 网络层随后把同一伤害事件交给房主归并，客机无需等待一次网络往返。
	local state = self:get_grille_state(shield_unit)
	if not state or not self.REGION_HEALTH[region_name] then
		return false, false
	end

	if state.broken[region_name] then
		return true, false
	end

	local bullet_damage = math.max(tonumber(damage) or 0, 0)
	state.damage[region_name] = state.damage[region_name] + bullet_damage
	local health = self.REGION_HEALTH[region_name]
	if state.damage[region_name] < health then
		return false, false
	end

	state.damage[region_name] = health
	state.broken[region_name] = true

	if region_name == "middle" then
		local side_regions = { "left_top", "left_bottom", "right_top", "right_bottom" }
		for i = 1, #side_regions do
			local side_name = side_regions[i]
			state.broken[side_name] = true
			state.damage[side_name] = self.REGION_HEALTH[side_name]
		end
	end

	self:apply_visual_state(shield_unit, state)
	self:play_break_effects(shield_unit, position, normal, region_name)
	self:log(3, "damage_region", "region broken", region_name, shield_unit, state.damage[region_name])
	return true, true
end

-- 破损区域仍然命中原版整面盾牌碰撞体，因此排队补发一条不耗弹药的射线。
function module:queue_passthrough(col_ray, weapon_unit, user_unit, damage)
	if not col_ray or not alive(col_ray.unit) or not col_ray.position or not col_ray.ray then
		return
	end

	self._pending_passthrough[#self._pending_passthrough + 1] = {
		shield = col_ray.unit,
		weapon = weapon_unit,
		user = user_unit,
		position = mvector3.copy(col_ray.position),
		direction = mvector3.copy(col_ray.ray),
		damage = tonumber(damage) or 0,
	}
end

-- ============================================================================
-- 联网协议与运行时索引
-- ============================================================================

-- 射手本机先立即应用伤害；客机再把同一伤害事件交给房主归并。
-- 房主回传包含五区绝对耐久和破损位图的完整快照，但快照只做“只增不减”的补正，
-- 不会把客机已经预测出的更高伤害或破损模型回滚。
-- 使用 DAHM 自定义数据通道而不是增加原版游戏 RPC，因此未安装本 Mod 的玩家
-- 最多只是忽略未知消息，不会因为缺少 UnitNetworkHandler 函数而崩溃。
module.NET_DAMAGE_REQUEST = "BSGRDamageRequest"
module.NET_DAMAGE_ACK = "BSGRDamageAck"
module.NET_STATE_SNAPSHOT = "BSGRStateSnapshot"

-- 防止畸形网络包写入 NaN、无穷大或极端伤害。正常武器伤害远低于此上限。
module.MAX_NETWORK_DAMAGE = 100000
module.MAX_NETWORK_COORDINATE = 1000000
module.NET_REQUEST_CACHE_SIZE = 2048
module.LOCAL_EVENT_RETRY_INTERVAL = 0.75
module.LOCAL_EVENT_RETRY_TIMEOUT = 20
module.FINAL_STATE_RESEND_DELAY = 1

-- net_id 使用“原持盾盾兵”的网络单位 ID，而不是本地 spawn 的盾牌 unit:id()。
module._grille_states_by_net_id = module._grille_states_by_net_id or {}
module._pending_grille_state_sync = module._pending_grille_state_sync or {}
module._processed_grille_damage_requests = module._processed_grille_damage_requests or {}
module._pending_local_grille_events = module._pending_local_grille_events or {}
module._next_grille_damage_request_id = module._next_grille_damage_request_id or 0

-- alive() 只应接收引擎 userdata；先检查 type_name，避免畸形 JSON 把普通 table
-- 塞进 data.unit 后触发 “attempt to call method alive” 一类崩溃。
local function is_alive_unit(unit)
	return type_name(unit) == "Unit" and alive(unit)
end

local function normalize_net_id(value)
	local number = tonumber(value)
	if not number or number ~= number or number < 0 or number > 2147483647 then
		return nil
	end
	return math.floor(number)
end

local function normalize_revision(value)
	local number = tonumber(value)
	if not number or number ~= number or number < 0 then
		return nil
	end
	return math.floor(number)
end

local function safe_number(value, limit)
	local number = tonumber(value)
	if not number or number ~= number or math.abs(number) > limit then
		return nil
	end
	return number
end

local function sanitize_damage(value)
	local damage = safe_number(value, module.MAX_NETWORK_DAMAGE)
	if not damage then
		return 0
	end
	return math.max(0, math.min(module.MAX_NETWORK_DAMAGE, damage))
end

-- 重发计时统一使用游戏时钟；在极早期初始化阶段不可用时才退回 Application 时钟。
local function network_time()
	local timer = TimerManager and TimerManager:game()
	if timer then
		return timer:time()
	end
	return Application and Application:time() or 0
end

local function encode_vector(vector)
	if not vector then
		return nil
	end

	local x = safe_number(mvector3.x(vector), module.MAX_NETWORK_COORDINATE)
	local y = safe_number(mvector3.y(vector), module.MAX_NETWORK_COORDINATE)
	local z = safe_number(mvector3.z(vector), module.MAX_NETWORK_COORDINATE)
	if not x or not y or not z then
		return nil
	end
	return { x, y, z }
end

local function decode_vector(data)
	if type(data) ~= "table" then
		return nil
	end

	local x = safe_number(data[1], module.MAX_NETWORK_COORDINATE)
	local y = safe_number(data[2], module.MAX_NETWORK_COORDINATE)
	local z = safe_number(data[3], module.MAX_NETWORK_COORDINATE)
	if not x or not y or not z then
		return nil
	end
	return Vector3(x, y, z)
end

local function owner_net_id(owner_unit)
	if not is_alive_unit(owner_unit) then
		return nil
	end
	return normalize_net_id(owner_unit:id())
end

-- 将一面本地盾牌绑定到跨客户端稳定的网络标识。
-- forced_net_id 只用于应用主机快照；通常直接取原持盾盾兵的 unit:id()。
function module:bind_grille_network_identity(shield_unit, state, owner_unit, forced_net_id)
	if not alive(shield_unit) or not state then
		return nil
	end

	if not is_alive_unit(owner_unit) then
		local parent = shield_unit:parent()
		if alive(parent) then
			local base = parent:base()
			if base and base._tweak_table == "shield" then
				owner_unit = parent
			end
		end
	end

	if is_alive_unit(owner_unit) then
		state.owner_unit = owner_unit
	end

	local net_id = normalize_net_id(forced_net_id)
		or owner_net_id(owner_unit)
		or normalize_net_id(state.net_id)
	if not net_id then
		return nil
	end

	-- 极端情况下若同一 state 被重新绑定，先移除旧索引，避免一面盾牌占两个 ID。
	if state.net_id and state.net_id ~= net_id then
		local old_entry = self._grille_states_by_net_id[state.net_id]
		if old_entry and old_entry.state == state then
			self._grille_states_by_net_id[state.net_id] = nil
		end
	end

	state.net_id = net_id
	self._grille_states_by_net_id[net_id] = {
		unit = shield_unit,
		state = state,
	}

	-- 主机快照可能早于客机本地的盾牌附件生成；注册完成后立即补应用排队快照。
	local pending = self._pending_grille_state_sync[net_id]
	if pending and self.apply_remote_grille_state then
		self._pending_grille_state_sync[net_id] = nil
		self:apply_remote_grille_state(pending)
	end

	return net_id
end

-- 按网络 ID 定位本机对应盾牌。优先使用索引；若消息携带了已解析的盾兵单位，
-- 还可以直接从其 inventory 找到本地生成的 _shield_unit 并补做注册。
function module:resolve_grille_by_net_id(net_id, owner_unit)
	net_id = normalize_net_id(net_id)
	if not net_id then
		return nil, nil
	end

	if not is_alive_unit(owner_unit) then
		owner_unit = nil
	end

	local entry = self._grille_states_by_net_id[net_id]
	if entry and alive(entry.unit) and entry.state then
		if owner_unit and not is_alive_unit(entry.state.owner_unit) then
			entry.state.owner_unit = owner_unit
		end
		return entry.unit, entry.state
	end
	self._grille_states_by_net_id[net_id] = nil

	if owner_unit then
		local inventory = owner_unit:inventory()
		local shield_unit = inventory and inventory._shield_unit
		if alive(shield_unit) then
			local state = self:register_shield(shield_unit, owner_unit, net_id)
			if state then
				return shield_unit, state
			end
		end
	end

	-- 兼容脚本热加载和掉落阶段：索引若暂时缺失，仍从现有状态表恢复一次。
	for shield_unit, state in pairs(self._grille_states) do
		if alive(shield_unit) and state and normalize_net_id(state.net_id) == net_id then
			self._grille_states_by_net_id[net_id] = {
				unit = shield_unit,
				state = state,
			}
			return shield_unit, state
		end
	end

	for _, data in pairs(self._dropped_shields) do
		if data and alive(data.unit) and data.state
			and normalize_net_id(data.state.net_id) == net_id then
			self._grille_states_by_net_id[net_id] = {
				unit = data.unit,
				state = data.state,
			}
			return data.unit, data.state
		end
	end

	return nil, nil
end

-- ============================================================================
-- 房主状态快照与单调补正
-- ============================================================================

local function broken_mask_for_state(state)
	local mask = 0
	for i = 1, #module.REGION_ORDER do
		if state.broken[module.REGION_ORDER[i]] then
			mask = mask + 2 ^ (i - 1)
		end
	end
	return mask
end

local function build_state_payload(shield_unit, state, event_region, position, normal)
	if not alive(shield_unit) or not state or not normalize_net_id(state.net_id) then
		return nil
	end

	local damage = {}
	for i = 1, #module.REGION_ORDER do
		local region_name = module.REGION_ORDER[i]
		damage[i] = tonumber(state.damage[region_name]) or 0
	end

	local payload = {
		module = module:id(),
		net_id = state.net_id,
		revision = normalize_revision(state.revision) or 0,
		damage = damage,
		broken_mask = broken_mask_for_state(state),
		event_region = module.REGION_HEALTH[event_region] and event_region or nil,
		position = encode_vector(position),
		normal = encode_vector(normal),
	}

	-- DNet 会把同步盾兵 Unit 转换为 {id, slot}，接收端 Hook 的最后一个 true
	-- 会再解析回本机单位；盾兵仍存活时可借此处理“状态先到、附件后生成”的竞态。
	if is_alive_unit(state.owner_unit) and state.owner_unit:id() ~= -1 then
		payload.unit = state.owner_unit
	end

	return payload
end

-- 每个 peer 单独构造并发送快照，使 DAHM 的 confirmation_id 不会在广播缓存中共用。
-- 快照是幂等的：即使确认包丢失导致 DAHM 重发，客机也会按 revision 忽略重复内容。
function module:send_grille_state_to_peer(shield_unit, state, peer, event_region, position, normal)
	if not Network:is_server() or not peer or peer:is_local_user()
		or not DNet or type(DNet.send_to_peer) ~= "function" then
		return false
	end

	local payload = build_state_payload(shield_unit, state, event_region, position, normal)
	if not payload then
		return false
	end

	return DNet:send_to_peer(
		peer,
		self.NET_STATE_SNAPSHOT,
		payload,
		false,
		true
	) and true or false
end

function module:broadcast_grille_state(shield_unit, state, event_region, position, normal)
	if not Network:is_server() then
		return
	end

	local session = managers.network and managers.network:session()
	local peers = session and session:peers()
	if not peers then
		return
	end

	for _, peer in pairs(peers) do
		-- 尚在同步地图的玩家由 SYNC_DONE_CALLBACK 接收一次当前完整状态。
		if peer and not peer:is_local_user() and peer._synced then
			self:send_grille_state_to_peer(
				shield_unit,
				state,
				peer,
				event_region,
				position,
				normal
			)
		end
	end
end

-- 新玩家完成 drop-in 时，主机把所有仍存在盾牌的当前绝对状态逐一补发。
function module:send_all_grille_states_to_peer(peer)
	if not Network:is_server() or not peer or peer:is_local_user() then
		return
	end

	for _, entry in pairs(self._grille_states_by_net_id) do
		if entry and alive(entry.unit) and entry.state then
			self:send_grille_state_to_peer(entry.unit, entry.state, peer)
		end
	end
end

-- 房主处理完客机伤害后发送显式收录确认。这里不用依赖 DAHM 的底层确认：
-- 底层确认只说明框架收到了数据，不能证明安装了本 Mod 的逻辑已经应用该事件。
function module:send_grille_damage_ack(peer, request_id, state)
	if not Network:is_server() or not peer or peer:is_local_user()
		or not normalize_net_id(request_id)
		or not DNet or type(DNet.send_to_peer) ~= "function" then
		return false
	end

	return DNet:send_to_peer(peer, self.NET_DAMAGE_ACK, {
		module = self:id(),
		request_id = request_id,
		net_id = state and normalize_net_id(state.net_id) or nil,
		revision = state and (normalize_revision(state.revision) or 0) or nil,
	}, false, false) and true or false
end

-- 发送或重发一条客机本地已结算的伤害事件。房主回 ACK 前事件一直保留；
-- 若对方没有安装本 Mod，则最多尝试到超时，不会无限发送或引发崩溃。
function module:send_pending_local_grille_event(event, now)
	if Network:is_server() or not event or type(event.payload) ~= "table"
		or not DNet or type(DNet.send_to_peer) ~= "function" then
		return false
	end

	local session = managers.network and managers.network:session()
	local server_peer = session and session:server_peer()
	if not server_peer then
		return false
	end

	now = now or network_time()
	event.last_send_t = now
	event.attempts = (event.attempts or 0) + 1
	return DNet:send_to_peer(
		server_peer,
		self.NET_DAMAGE_REQUEST,
		event.payload,
		false,
		false
	) and true or false
end

-- 每帧只进行很轻量的时间检查：
-- 1. 客机约每 0.75 秒重发尚未获得房主 ACK 的事件，最长保留 20 秒；
-- 2. 房主在最后一次伤害后 1 秒再补一份无特效标记的最终快照。
function module:update_grille_network()
	local now = network_time()

	if Network:is_server() then
		for _, entry in pairs(self._grille_states_by_net_id) do
			local state = entry and entry.state
			if state and state.final_sync_t and now >= state.final_sync_t then
				state.final_sync_t = nil
				if alive(entry.unit) then
					self:broadcast_grille_state(entry.unit, state)
				end
			end
		end
		return
	end

	for request_id, event in pairs(self._pending_local_grille_events) do
		local first_send_t = event and event.first_send_t or now
		if not event or now - first_send_t >= self.LOCAL_EVENT_RETRY_TIMEOUT then
			self._pending_local_grille_events[request_id] = nil
			self:log(
				2,
				"update_grille_network",
				"local damage event acknowledgement timed out",
				request_id
			)
		elseif not event.last_send_t
			or now - event.last_send_t >= self.LOCAL_EVENT_RETRY_INTERVAL then
			self:send_pending_local_grille_event(event, now)
		end
	end
end

-- 房主的伤害归并入口。射手客机在调用这里之前早已完成本地结算；
-- 房主只负责把每个唯一事件累计一次，再用完整快照令其它客户端最终收敛。
function module:process_authoritative_grille_damage(
	shield_unit,
	region_name,
	position,
	normal,
	damage,
	reply_peer
)
	if not Network:is_server() or not alive(shield_unit)
		or not self.REGION_HEALTH[region_name] then
		return false, false
	end

	local state = self:get_grille_state(shield_unit)
	if not state then
		return false, false
	end

	local bullet_damage = sanitize_damage(damage)
	if bullet_damage <= 0 then
		return false, false
	end

	-- 客机可能尚未收到刚刚的破坏快照，又向同一区域补了一枪。
	-- 这时不重复扣血/播放效果，只把当前状态直接回给该客机纠正本地显示。
	if state.broken[region_name] then
		if reply_peer then
			self:send_grille_state_to_peer(shield_unit, state, reply_peer)
		end
		return true, false
	end

	-- 客机上报的世界坐标可能因为网络插值与房主盾牌姿态略有差异；
	-- 房主处理远程射击时改用本机区域中心播放效果，不影响伤害区域和同步结果。
	local effect_position = position
	local effect_normal = normal
	if reply_peer then
		effect_position, effect_normal =
			self:get_region_effect_transform(shield_unit, region_name)
	end

	local broken, broke_now = self:damage_region(
		shield_unit,
		region_name,
		effect_position,
		effect_normal,
		bullet_damage
	)
	state.revision = (normalize_revision(state.revision) or 0) + 1
	self:broadcast_grille_state(
		shield_unit,
		state,
		broke_now and region_name or nil,
		broke_now and effect_position or nil,
		broke_now and effect_normal or nil
	)
	-- 即时快照后再安排一次安静期最终快照，补偿“最后一发消息恰好丢失”的情况。
	state.final_sync_t = network_time() + self.FINAL_STATE_RESEND_DELAY
	return broken, broke_now
end

-- 本机玩家命中后的统一分流：
-- 房主直接结算并广播；客机先立即结算本地耐久/模型，再异步报告给房主。
function module:submit_local_grille_hit(shield_unit, region_name, position, normal, damage)
	if not alive(shield_unit) or not self.REGION_HEALTH[region_name] then
		return false
	end

	local state = self:get_grille_state(shield_unit)
	if not state then
		return false
	end

	local bullet_damage = sanitize_damage(damage)
	if bullet_damage <= 0 then
		return false
	end

	if Network:is_server() then
		self:process_authoritative_grille_damage(
			shield_unit,
			region_name,
			position,
			normal,
			bullet_damage
		)
		return true
	end

	-- 关键行为：客机不等待房主。这里与原版 CopDamage:damage_bullet 相同，
	-- 先在射手本地累计伤害；若达到阈值，破损模型、声音和粒子会立即出现。
	self:damage_region(
		shield_unit,
		region_name,
		position,
		normal,
		bullet_damage
	)

	local net_id = normalize_net_id(state.net_id)
	local session = managers.network and managers.network:session()
	local server_peer = session and session:server_peer()
	if not net_id or bullet_damage <= 0 or not server_peer
		or not DNet or type(DNet.send_to_peer) ~= "function" then
		-- 未连接或双方 Mod 不统一时仍保留已经完成的本地结果；只放弃网络传播。
		return true
	end

	-- 请求编号同时用于房主去重和显式 ACK。即使 ACK 丢失导致客机重发，
	-- 房主也只会应用一次，并再次发送确认。
	self._next_grille_damage_request_id =
		(self._next_grille_damage_request_id % 2147483000) + 1
	local request_id = self._next_grille_damage_request_id
	local payload = {
		module = self:id(),
		net_id = net_id,
		request_id = request_id,
		region = region_name,
		damage = bullet_damage,
		position = encode_vector(position),
		normal = encode_vector(normal),
	}
	if is_alive_unit(state.owner_unit) and state.owner_unit:id() ~= -1 then
		payload.unit = state.owner_unit
	end

	local now = network_time()
	local event = {
		payload = payload,
		first_send_t = now,
		last_send_t = nil,
		attempts = 0,
	}
	self._pending_local_grille_events[request_id] = event
	self:send_pending_local_grille_event(event, now)
	return true
end

-- ============================================================================
-- 客机应用房主状态补正
-- ============================================================================

function module:apply_remote_grille_state(data)
	if type(data) ~= "table" or data.module ~= self:id() then
		return false
	end

	local net_id = normalize_net_id(data.net_id)
	local revision = normalize_revision(data.revision)
	if not net_id or not revision then
		return false
	end

	local shield_unit, state = self:resolve_grille_by_net_id(net_id, data.unit)
	if not alive(shield_unit) or not state then
		-- 只保留同一盾牌 revision 最大的排队快照，避免附件生成后先应用旧状态。
		local old = self._pending_grille_state_sync[net_id]
		local old_revision = old and normalize_revision(old.revision) or -1
		if revision >= old_revision then
			self._pending_grille_state_sync[net_id] = data
		end
		return false
	end

	local current_revision = normalize_revision(state.revision) or 0
	if state.network_initialized and revision <= current_revision then
		return true
	end

	local old_broken = {}
	for i = 1, #self.REGION_ORDER do
		local region_name = self.REGION_ORDER[i]
		old_broken[region_name] = state.broken[region_name] == true
	end

	local damage = type(data.damage) == "table" and data.damage or {}
	local broken_mask = normalize_revision(data.broken_mask) or 0
	broken_mask = math.min(31, broken_mask)
	for i = 1, #self.REGION_ORDER do
		local region_name = self.REGION_ORDER[i]
		local health = self.REGION_HEALTH[region_name]
		local region_damage = safe_number(damage[i], self.MAX_NETWORK_DAMAGE) or 0
		local remote_broken = math.floor(broken_mask / 2 ^ (i - 1)) % 2 == 1

		-- 房主快照只允许推进状态，绝不能用尚未包含本地预测事件的较低数值
		-- 把射手客户端“回血”或重新显示已经打碎的筋条。
		local local_damage = safe_number(
			state.damage[region_name],
			self.MAX_NETWORK_DAMAGE
		) or 0
		local merged_damage = math.max(
			math.max(0, math.min(health, local_damage)),
			math.max(0, math.min(health, region_damage))
		)
		local broken = state.broken[region_name] == true
			or remote_broken
			or merged_damage >= health
		state.broken[region_name] = broken
		state.damage[region_name] = broken
			and health
			or merged_damage
	end

	-- 中央竖筋破坏始终意味着四根横筋一并进入破损状态。
	if state.broken.middle then
		local side_regions = { "left_top", "left_bottom", "right_top", "right_bottom" }
		for i = 1, #side_regions do
			local region_name = side_regions[i]
			state.broken[region_name] = true
			state.damage[region_name] = self.REGION_HEALTH[region_name]
		end
	end

	state.revision = revision
	state.network_initialized = true
	if is_alive_unit(data.unit) then
		state.owner_unit = data.unit
	end
	self:apply_visual_state(shield_unit, state)

	-- 只为新出现的破损播放一次效果。中央竖筋会连带四根横筋一起破坏，
	-- 但 event_region 仍是 middle，因此各端只播放一组中央破坏粒子/声音。
	local effect_region = self.REGION_HEALTH[data.event_region] and data.event_region or nil
	if effect_region and old_broken[effect_region] then
		effect_region = nil
	end
	if not effect_region and not old_broken.middle and state.broken.middle then
		effect_region = "middle"
	end
	if not effect_region then
		for i = 1, #self.REGION_ORDER do
			local region_name = self.REGION_ORDER[i]
			if not old_broken[region_name] and state.broken[region_name] then
				effect_region = region_name
				break
			end
		end
	end

	if effect_region then
		-- 各端盾牌姿态允许存在原版网络插值差异，因此优先按本机盾牌变换
		-- 在区域中心播放效果；只有本机对象变换不可用时才退回射手上报的世界坐标。
		local effect_position, effect_normal =
			self:get_region_effect_transform(shield_unit, effect_region)
		if not effect_position then
			effect_position = decode_vector(data.position)
			effect_normal = decode_vector(data.normal)
		end
		self:play_break_effects(
			shield_unit,
			effect_position,
			effect_normal,
			effect_region
		)
	end

	return true
end

-- 记录某个 peer 最近处理过的请求编号。显式 ACK 丢失时客机会重发同一 payload；
-- 这个滑动集合既阻止重复伤害，也不会因为长时间游戏无限增长。
function module:is_duplicate_grille_damage_request(peer, request_id)
	request_id = normalize_net_id(request_id)
	if not peer or not request_id then
		return true
	end

	local peer_key = tostring(peer:user_id() or peer:id())
	local cache = self._processed_grille_damage_requests[peer_key]
	if not cache then
		cache = { seen = {}, order = {} }
		self._processed_grille_damage_requests[peer_key] = cache
	end

	if cache.seen[request_id] then
		return true
	end

	cache.seen[request_id] = true
	cache.order[#cache.order + 1] = request_id
	if #cache.order > self.NET_REQUEST_CACHE_SIZE then
		local oldest = table.remove(cache.order, 1)
		cache.seen[oldest] = nil
	end
	return false
end

-- ============================================================================
-- DAHM 事件入口与跨关卡清理
-- ============================================================================

module:hook("OnNetworkDataRecv", "BSGR_OnNetworkDataRecv", {
	module.NET_DAMAGE_REQUEST,
	module.NET_DAMAGE_ACK,
	module.NET_STATE_SNAPSHOT,
}, function(peer, data_type, data)
	if type(data) ~= "table" or data.module ~= module:id() or not peer then
		return
	end

	if data_type == module.NET_DAMAGE_REQUEST then
		-- 只有主机接受客机命中请求；本地 peer 和畸形区域名一律忽略。
		if not Network:is_server() or peer:is_local_user()
			or not module.REGION_HEALTH[data.region]
			or not normalize_net_id(data.net_id)
			or not normalize_net_id(data.request_id)
			or sanitize_damage(data.damage) <= 0 then
			return
		end

		local shield_unit, state =
			module:resolve_grille_by_net_id(data.net_id, data.unit)
		-- 状态尚未在房主本地建立时暂不确认，让客机稍后自动重发；
		-- 这覆盖“客机附件已经生成、房主对应 Hook 尚未完成”的短暂竞态。
		if not alive(shield_unit) or not state then
			return
		end

		if module:is_duplicate_grille_damage_request(peer, data.request_id) then
			-- 重发包不再扣血，但再次回复快照和 ACK，补偿之前任一回包丢失。
			module:send_grille_state_to_peer(shield_unit, state, peer)
			module:send_grille_damage_ack(peer, data.request_id, state)
			return
		end

		module:process_authoritative_grille_damage(
			shield_unit,
			data.region,
			decode_vector(data.position),
			decode_vector(data.normal),
			data.damage,
			peer
		)
		module:send_grille_damage_ack(peer, data.request_id, state)

	elseif data_type == module.NET_DAMAGE_ACK then
		-- 客机只接受房主发来的显式收录确认；收到后停止这条本地事件的重发。
		if Network:is_server() or not peer:is_server() then
			return
		end

		local request_id = normalize_net_id(data.request_id)
		local event = request_id and module._pending_local_grille_events[request_id]
		if event then
			local expected_net_id = normalize_net_id(event.payload and event.payload.net_id)
			local ack_net_id = normalize_net_id(data.net_id)
			if not ack_net_id or ack_net_id == expected_net_id then
				module._pending_local_grille_events[request_id] = nil
			end
		end

	elseif data_type == module.NET_STATE_SNAPSHOT then
		-- 客机只信任 server_peer 的绝对快照；其它客机不能互相伪造破坏状态。
		if Network:is_server() or not peer:is_server() then
			return
		end
		module:apply_remote_grille_state(data)
	end
end, true)

module:hook("OnPeerAdded", "BSGR_OnPeerAdded", function(peer)
	if not Network:is_server() or not peer or peer:is_local_user() then
		return
	end

	local function sync_after_drop_in(synced_peer)
		if Network:is_server() and synced_peer then
			module:send_all_grille_states_to_peer(synced_peer)
		end
	end

	if peer._synced then
		sync_after_drop_in(peer)
	elseif peer.add_callback then
		local callback_id = peer.SYNC_DONE_CALLBACK
			or rawget(_G, "NetworkPeer") and NetworkPeer.SYNC_DONE_CALLBACK
			or "sync"
		peer:add_callback(callback_id, sync_after_drop_in)
	end
end)

module:hook("OnPeerRemoved", "BSGR_OnPeerRemoved", function(peer)
	if not peer then
		return
	end
	local peer_key = tostring(peer:user_id() or peer:id())
	module._processed_grille_damage_requests[peer_key] = nil
	if not Network:is_server() and peer:is_server() then
		module._pending_local_grille_events = {}
	end
end)

function module:reset_grille_network_runtime()
	self._grille_states = setmetatable({}, { __mode = "k" })
	self._dropped_shields = {}
	self._grille_states_by_net_id = {}
	self._pending_grille_state_sync = {}
	self._processed_grille_damage_requests = {}
	self._pending_local_grille_events = {}
	self._pending_passthrough = {}
	self._processing_passthrough = false

	-- 跨关卡前停止并丢弃仍在两秒保活窗口内的临时声音源。
	for i = 1, #self._temporary_sounds do
		local data = self._temporary_sounds[i]
		if data and data.source then
			data.source:stop()
		end
	end
	self._temporary_sounds = {}
end

module:hook("OnHeistStart", "BSGR_OnHeistStart", function()
	module:reset_grille_network_runtime()
end)