--[[
步哨异常高速射击/爆音诊断。

本文件刻意只安装 pre-hook：
- 不替换 SentryGunWeapon:fire()、trigger_held() 或 _fire_raycast()；
- 不改变任何原函数返回值；
- 不限制射速、不吞声音，也不修正状态；
- 以每座步哨、每次 Brain:update 和约 1 秒窗口分别统计真实射击、弹药、
  自动射击循环音、逐弹撞击音、网络开火状态与多部位探测。

日志统一带有 [SENTRY-DIAG] 标记，位于 DAHM 的 logs/main.log。
]]

local module = ... or D:module("PDTH++")
local required_script = RequiredScript or "<nil>"

local WINDOW_SECONDS = 1
local MAX_EVENT_LINES_PER_WINDOW = 12
local TIMER_EPSILON = 0.000001

-- 本文件会被四个 RequiredScript 分别执行，因此分支代码需要的轻量工具函数
-- 必须定义在一次性初始化保护之外；公共状态与 module 方法仍只初始化一次。
local function game_time()
	local timer = TimerManager and TimerManager:game()
	return timer and timer:time() or Application:time()
end

local function bool_text(value)
	return value and "true" or "false"
end

local function safe_body_desc(body)
	if not body then
		return "body=nil"
	end

	local enabled = body.enabled and body:enabled()
	return string.format("body=%s,enabled=%s", tostring(body:name()), bool_text(enabled))
end

local function hook_count(obj, fname)
	local hooker = D and D._object_hooker
	local hook_types = hooker and hooker.hook_types
	if not hooker or not hook_types or not obj then
		return "?"
	end

	local function count(hook_type)
		local hooks = hooker:get_hook_of_type(nil, hook_type, obj, fname)
		return type(hooks) == "table" and #hooks or 0
	end

	local object_hooks = hooker._object_hooks
	local function_table = object_hooks and object_hooks[obj] and object_hooks[obj][fname]
	local wrapper_current = function_table and obj[fname] == function_table[2] or false
	return string.format(
		"pre=%d,replace=%d,post=%d,wrapper_current=%s",
		count(hook_types.before),
		count(hook_types.replace),
		count(hook_types.after),
		bool_text(wrapper_current)
	)
end

if not module._pdthpp_sentry_diag_helpers_ready then
	module._pdthpp_sentry_diag_helpers_ready = true
	module._pdthpp_sentry_diag_branch_loads = module._pdthpp_sentry_diag_branch_loads or {}

	local function new_window(t)
		return {
			t = t,
			frames = 0,
			event_lines = 0,
			events_suppressed = 0,
			warning_lines = 0,
			warnings_suppressed = 0,
		}
	end

	local function safe_unit_weapon(unit)
		if not unit or not alive(unit) then
			return nil
		end

		local ok, weapon = pcall(function()
			return unit:weapon()
		end)
		if not ok or not weapon or weapon._name_id ~= "sentry_gun" then
			return nil
		end
		return weapon
	end

	local function safe_unit_desc(unit)
		if not unit or not alive(unit) then
			return "unit=nil/dead"
		end

		local key = unit:key()
		local name = unit:name()
		local base = unit:base()
		local tweak_table = base and base._tweak_table or "-"
		local logic_name = "-"
		local brain = unit:brain()
		if brain and brain._current_logic_name then
			logic_name = brain._current_logic_name
		end

		return string.format(
			"key=%s,name=%s,tweak=%s,logic=%s",
			tostring(key),
			tostring(name),
			tostring(tweak_table),
			tostring(logic_name)
		)
	end

	function module:pdthpp_sentry_diag_log(tag, ...)
		self:log(0, "SentryDiag", "[SENTRY-DIAG][" .. tostring(tag) .. "]", ...)
	end

	function module:pdthpp_sentry_diag_weapon_from_unit(unit)
		return safe_unit_weapon(unit)
	end

	function module:pdthpp_sentry_diag_unit_desc(unit)
		return safe_unit_desc(unit)
	end

	function module:pdthpp_sentry_diag_state(weapon)
		if not weapon then
			return nil
		end

		local state = weapon._pdthpp_sentry_diag
		if not state then
			local t = game_time()
			state = {
				window = new_window(t),
				frame_index = 0,
				last_hit = "-",
				last_hit_signature = nil,
				last_focus = "-",
				last_focus_signature = nil,
				last_update_t = nil,
				last_sync_state = nil,
				last_sync_t = nil,
			}
			weapon._pdthpp_sentry_diag = state
		end
		return state
	end

	function module:pdthpp_sentry_diag_bump(weapon, field, amount)
		local state = self:pdthpp_sentry_diag_state(weapon)
		if not state then
			return nil
		end

		amount = amount or 1
		local window = state.window
		window[field] = (window[field] or 0) + amount
		local frame = state.frame
		if frame then
			frame[field] = (frame[field] or 0) + amount
		end
		return state
	end

	function module:pdthpp_sentry_diag_event(weapon, tag, message)
		local state = self:pdthpp_sentry_diag_state(weapon)
		if not state then
			return
		end

		local window = state.window
		if window.event_lines < MAX_EVENT_LINES_PER_WINDOW then
			window.event_lines = window.event_lines + 1
			self:pdthpp_sentry_diag_log(tag, message)
		else
			window.events_suppressed = window.events_suppressed + 1
		end
	end

	function module:pdthpp_sentry_diag_warn(weapon, tag, message)
		local state = self:pdthpp_sentry_diag_state(weapon)
		if not state then
			return
		end

		local window = state.window
		if window.warning_lines < MAX_EVENT_LINES_PER_WINDOW then
			window.warning_lines = window.warning_lines + 1
			self:pdthpp_sentry_diag_log("WARN-" .. tostring(tag), message)
		else
			window.warnings_suppressed = window.warnings_suppressed + 1
		end
	end

	function module:pdthpp_sentry_diag_focus_desc(weapon)
		local sentry_unit = weapon and weapon._unit
		local brain = sentry_unit and sentry_unit:brain()
		local focus = brain and brain._AI_data and brain._AI_data.focus_enemy
		local focus_unit = focus and focus.unit
		if not focus_unit or not alive(focus_unit) then
			return "focus=nil"
		end

		local suffix = ""
		local movement = sentry_unit:movement()
		local cache = movement
			and movement._pdthpp_target_solution_cache
			and movement._pdthpp_target_solution_cache[focus_unit:key()]
		if cache then
			suffix = string.format(
				",solution_valid=%s,shootable=%s,head=%s,obstructed=%s",
				bool_text(cache.valid),
				bool_text(cache.shootable),
				bool_text(cache.is_head),
				bool_text(cache.obstruction_blocked)
			)
		end

		local verified_age = focus.verified_t and game_time() - focus.verified_t or -1
		suffix = suffix
			.. string.format(
				",verified=%s,verified_age=%.3f",
				bool_text(focus.verified),
				verified_age
			)

		return "focus={" .. safe_unit_desc(focus_unit) .. suffix .. "}"
	end

	function module:pdthpp_sentry_diag_finish_frame(weapon)
		local state = self:pdthpp_sentry_diag_state(weapon)
		local frame = state and state.frame
		if not frame or frame.finished then
			return
		end
		frame.finished = true

		local ammo_now = tonumber(weapon._ammo_total)
		local ammo_before = tonumber(frame.ammo_before)
		local ammo_drop = 0
		if ammo_before and ammo_now and ammo_before > ammo_now then
			ammo_drop = ammo_before - ammo_now
			frame.ammo_drop = ammo_drop
			state.window.ammo_drop = (state.window.ammo_drop or 0) + ammo_drop
		end

		local fire_calls = frame.fire or 0
		local ray_calls = frame.raycast or 0
		local trigger_calls = frame.trigger or 0
		local sound_starts = frame.sound_start or 0
		local expend_fire = frame.expend_fire or 0

		state.window.max_fire_per_frame = math.max(state.window.max_fire_per_frame or 0, fire_calls)
		state.window.max_trigger_per_frame = math.max(state.window.max_trigger_per_frame or 0, trigger_calls)
		state.window.max_sound_start_per_frame = math.max(
			state.window.max_sound_start_per_frame or 0,
			sound_starts
		)

		local sentry_key = weapon._unit and weapon._unit:key() or "-"
		local frame_prefix = string.format(
			"sentry=%s frame=%s t=%.6f ",
			tostring(sentry_key),
			tostring(frame.id),
			tonumber(frame.t) or -1
		)

		if fire_calls > 1 or ray_calls > 1 or ammo_drop > 1 or sound_starts > 1 then
			self:pdthpp_sentry_diag_warn(
				weapon,
				"MULTI-IN-FRAME",
				frame_prefix
					.. string.format(
						"trigger=%d fire=%d raycast=%d ammo_drop=%d sound_start=%d %s last_hit={%s}",
						trigger_calls,
						fire_calls,
						ray_calls,
						ammo_drop,
						sound_starts,
						self:pdthpp_sentry_diag_focus_desc(weapon),
						tostring(state.last_hit)
					)
			)
		end

		if fire_calls > 0
			and frame.first_trigger_next ~= nil
			and weapon._next_fire_allowed <= frame.first_trigger_next + TIMER_EPSILON then
			self:pdthpp_sentry_diag_warn(
				weapon,
				"TIMER-NOT-ADVANCED",
				frame_prefix
					.. string.format(
						"fire=%d next_before=%.6f next_after=%.6f",
						fire_calls,
						frame.first_trigger_next,
						weapon._next_fire_allowed
					)
			)
		end

		if Network:is_server() and expend_fire > 0 and ammo_drop ~= expend_fire then
			self:pdthpp_sentry_diag_warn(
				weapon,
				"AMMO-MISMATCH",
				frame_prefix
					.. string.format(
						"expend_fire=%d ammo_drop=%d ammo_before=%s ammo_after=%s",
						expend_fire,
						ammo_drop,
						tostring(ammo_before),
						tostring(ammo_now)
					)
			)
		end
	end

	function module:pdthpp_sentry_diag_flush(weapon, force, reason)
		local state = self:pdthpp_sentry_diag_state(weapon)
		if not state then
			return
		end

		self:pdthpp_sentry_diag_finish_frame(weapon)
		local now = game_time()
		local window = state.window
		local elapsed = math.max(now - window.t, TIMER_EPSILON)
		if not force and elapsed < WINDOW_SECONDS then
			return
		end

		local active_calls = (window.trigger or 0)
			+ (window.fire or 0)
			+ (window.sound_start or 0)
			+ (window.sound_end or 0)
			+ (window.sync_allow or 0)
			+ (window.sync_forbid or 0)
			+ (window.target_probe_rays or 0)
		if active_calls == 0 and not force then
			state.window = new_window(now)
			return
		end

		local tweak = tweak_data.weapon[weapon._name_id]
		local fire_rate = tweak and tweak.auto and tweak.auto.fire_rate or 0
		local expected_limit = fire_rate > 0 and math.ceil(elapsed / fire_rate) + 2 or -1
		local fire_calls = window.fire or 0
		local burst = expected_limit >= 0 and fire_calls > expected_limit
		local sentry_unit = weapon._unit
		local brain = sentry_unit and sentry_unit:brain()
		local side = Network:is_server() and "server" or "client"
		local hooks = hook_count(
			self._pdthpp_sentry_diag_weapon_class or rawget(_G, "SentryGunWeapon"),
			"fire"
		)
		local message = string.format(
			"reason=%s side=%s sentry=%s dt=%.3f frames=%d same_t_updates=%d "
				.. "trigger=%d fire=%d raycast=%d expend_fire=%d blank_fire=%d ammo_drop=%d "
				.. "start_call=%d start_effective=%d sound_start=%d stop_call=%d stop_effective=%d sound_end=%d "
				.. "sync_allow=%d sync_forbid=%d collisions=%d impact_sounds=%d body_damage=%d "
				.. "focus_changes=%d target_solutions=%d target_probe_rays=%d "
				.. "max_frame(trigger/fire/sound)=%d/%d/%d expected_fire_limit=%d burst=%s "
				.. "brain_firing=%s weapon_shooting=%s sound_handle=%s next=%.6f ammo=%s hooks_fire={%s} "
				.. "events_suppressed=%d warnings_suppressed=%d %s last_hit={%s}",
			tostring(reason or "window"),
			side,
			tostring(sentry_unit and sentry_unit:key() or "-"),
			elapsed,
			window.frames or 0,
			window.same_t_updates or 0,
			window.trigger or 0,
			fire_calls,
			window.raycast or 0,
			window.expend_fire or 0,
			window.blank_fire or 0,
			window.ammo_drop or 0,
			window.start_call or 0,
			window.start_effective or 0,
			window.sound_start or 0,
			window.stop_call or 0,
			window.stop_effective or 0,
			window.sound_end or 0,
			window.sync_allow or 0,
			window.sync_forbid or 0,
			window.collision or 0,
			window.impact_sound or 0,
			window.body_damage or 0,
			window.focus_change or 0,
			window.target_solution or 0,
			window.target_probe_rays or 0,
			window.max_trigger_per_frame or 0,
			window.max_fire_per_frame or 0,
			window.max_sound_start_per_frame or 0,
			expected_limit,
			bool_text(burst),
			bool_text(brain and brain._firing),
			bool_text(weapon._shooting),
			tostring(weapon._autofire_sound_event),
			tonumber(weapon._next_fire_allowed) or -1,
			tostring(weapon._ammo_total),
			hooks,
			window.events_suppressed or 0,
			window.warnings_suppressed or 0,
			self:pdthpp_sentry_diag_focus_desc(weapon),
			tostring(state.last_hit)
		)
		self:pdthpp_sentry_diag_log(burst and "WINDOW-BURST" or "WINDOW", message)
		state.window = new_window(now)
	end

	function module:pdthpp_sentry_diag_begin_update(brain, t)
		local weapon = brain and brain._unit and brain._unit:weapon()
		if not weapon then
			return
		end

		local state = self:pdthpp_sentry_diag_state(weapon)
		self:pdthpp_sentry_diag_finish_frame(weapon)
		self:pdthpp_sentry_diag_flush(weapon, false, "window")

		if state.last_update_t and math.abs(t - state.last_update_t) <= TIMER_EPSILON then
			state.window.same_t_updates = (state.window.same_t_updates or 0) + 1
			self:pdthpp_sentry_diag_warn(
				weapon,
				"DUPLICATE-UPDATE",
				string.format(
					"sentry=%s two Brain:update calls share game t=%.6f",
					tostring(brain._unit:key()),
					t
				)
			)
		end
		state.last_update_t = t

		state.frame_index = state.frame_index + 1
		state.frame = {
			id = state.frame_index,
			t = t,
			ammo_before = weapon._ammo_total,
		}
		state.window.frames = (state.window.frames or 0) + 1
		state.last_focus = self:pdthpp_sentry_diag_focus_desc(weapon)
	end

	function module:pdthpp_sentry_diag_begin_branch(script_name)
		D._pdthpp_sentry_diag_global_loads = D._pdthpp_sentry_diag_global_loads or {}
		local global_count = (D._pdthpp_sentry_diag_global_loads[script_name] or 0) + 1
		D._pdthpp_sentry_diag_global_loads[script_name] = global_count

		local local_count = (self._pdthpp_sentry_diag_branch_loads[script_name] or 0) + 1
		self._pdthpp_sentry_diag_branch_loads[script_name] = local_count
		self:pdthpp_sentry_diag_log(
			(local_count > 1 or global_count > 1) and "WARN-INSTALL" or "INSTALL",
			string.format(
				"RequiredScript=%s module_load=%d global_load=%d",
				tostring(script_name),
				local_count,
				global_count
			)
		)
		return local_count == 1 and global_count == 1
	end
end

local install_branch = module:pdthpp_sentry_diag_begin_branch(required_script)

if install_branch and required_script == "lib/units/weapons/raycastweaponbase" then
	local InstantBulletBase = module:hook_class("InstantBulletBase")

	-- 原版每颗步哨子弹都经由这里产生逐弹撞击效果。按原版条件单独统计
	-- “预计会播放撞击音”的次数，并记录实际首个命中的单位与 body。
	module:pre_hook(InstantBulletBase, "on_collision", function(self, col_ray, weapon_unit)
		local weapon = module:pdthpp_sentry_diag_weapon_from_unit(weapon_unit)
		if not weapon or not col_ray then
			return
		end

		local state = module:pdthpp_sentry_diag_bump(weapon, "collision")
		local hit_unit = col_ray.unit
		local char_damage = hit_unit and hit_unit:character_damage()
		if not char_damage or not char_damage._no_blood then
			module:pdthpp_sentry_diag_bump(weapon, "impact_sound")
		end

		local body = col_ray.body
		local body_extension = body and body:extension()
		if body_extension and body_extension.damage then
			module:pdthpp_sentry_diag_bump(weapon, "body_damage")
		end

		local sentry_brain = weapon._unit and weapon._unit:brain()
		local focus = sentry_brain and sentry_brain._AI_data and sentry_brain._AI_data.focus_enemy
		local focus_match = focus and focus.unit == hit_unit
		local hit_desc = module:pdthpp_sentry_diag_unit_desc(hit_unit)
			.. ","
			.. safe_body_desc(body)
			.. ",focus_match="
			.. bool_text(focus_match)
		state.last_hit = hit_desc

		local signature = tostring(hit_unit and hit_unit:key() or "-")
			.. "/"
			.. tostring(body and body:name() or "-")
		if state.last_hit_signature ~= signature then
			state.last_hit_signature = signature
			module:pdthpp_sentry_diag_event(
				weapon,
				"HIT-TARGET",
				string.format(
					"sentry=%s %s",
					tostring(weapon._unit:key()),
					hit_desc
				)
			)
		end
	end, false)

elseif install_branch and required_script == "lib/units/weapons/sentrygunweapon" then
	local SentryGunWeapon = module:hook_class("SentryGunWeapon")
	module._pdthpp_sentry_diag_weapon_class = SentryGunWeapon

	module:pre_hook(SentryGunWeapon, "trigger_held", function(self, blanks, expend_ammo)
		local state = module:pdthpp_sentry_diag_bump(self, "trigger")
		if state and state.frame and state.frame.first_trigger_next == nil then
			state.frame.first_trigger_next = self._next_fire_allowed
		end
		if expend_ammo then
			module:pdthpp_sentry_diag_bump(self, "expend_trigger")
		elseif blanks then
			module:pdthpp_sentry_diag_bump(self, "blank_trigger")
		end
	end, false)

	module:pre_hook(SentryGunWeapon, "fire", function(self, blanks, expend_ammo)
		module:pdthpp_sentry_diag_bump(self, "fire")
		if expend_ammo then
			module:pdthpp_sentry_diag_bump(self, "expend_fire")
		else
			module:pdthpp_sentry_diag_bump(self, "blank_fire")
		end
	end, false)

	module:pre_hook(SentryGunWeapon, "_fire_raycast", function(self)
		module:pdthpp_sentry_diag_bump(self, "raycast")
	end, false)

	module:pre_hook(SentryGunWeapon, "start_autofire", function(self)
		module:pdthpp_sentry_diag_bump(self, "start_call")
		if not self._shooting then
			module:pdthpp_sentry_diag_bump(self, "start_effective")
			module:pdthpp_sentry_diag_event(
				self,
				"START",
				string.format(
					"sentry=%s old_handle=%s %s",
					tostring(self._unit:key()),
					tostring(self._autofire_sound_event),
					module:pdthpp_sentry_diag_focus_desc(self)
				)
			)
		end
	end, false)

	module:pre_hook(SentryGunWeapon, "_sound_autofire_start", function(self)
		module:pdthpp_sentry_diag_bump(self, "sound_start")
	end, false)

	module:pre_hook(SentryGunWeapon, "stop_autofire", function(self)
		module:pdthpp_sentry_diag_bump(self, "stop_call")
		if self._shooting then
			module:pdthpp_sentry_diag_bump(self, "stop_effective")
			module:pdthpp_sentry_diag_event(
				self,
				"STOP",
				string.format(
					"sentry=%s handle=%s %s",
					tostring(self._unit:key()),
					tostring(self._autofire_sound_event),
					module:pdthpp_sentry_diag_focus_desc(self)
				)
			)
		end
	end, false)

	local function record_sound_end(self, ending)
		module:pdthpp_sentry_diag_bump(self, "sound_end")
		module:pdthpp_sentry_diag_event(
			self,
			"SOUND-END",
			string.format(
				"sentry=%s ending=%s handle=%s",
				tostring(self._unit:key()),
				tostring(ending),
				tostring(self._autofire_sound_event)
			)
		)
	end

	module:pre_hook(SentryGunWeapon, "_sound_autofire_end", function(self)
		record_sound_end(self, "normal")
	end, false)
	module:pre_hook(SentryGunWeapon, "_sound_autofire_end_empty", function(self)
		record_sound_end(self, "empty")
	end, false)
	module:pre_hook(SentryGunWeapon, "_sound_autofire_end_cooldown", function(self)
		record_sound_end(self, "cooldown")
	end, false)

	module:pdthpp_sentry_diag_log(
		"HOOKS",
		"SentryGunWeapon.fire {" .. hook_count(SentryGunWeapon, "fire") .. "}; "
			.. "trigger_held {"
			.. hook_count(SentryGunWeapon, "trigger_held")
			.. "}; start_autofire {"
			.. hook_count(SentryGunWeapon, "start_autofire")
			.. "}"
	)

elseif install_branch and required_script == "lib/units/equipment/sentry_gun/sentrygunbrain" then
	local SentryGunBrain = module:hook_class("SentryGunBrain")

	module:pre_hook(SentryGunBrain, "update", function(self, unit, t)
		module:pdthpp_sentry_diag_begin_update(self, t)
	end, false)

	module:pre_hook(SentryGunBrain, "_check_fire", function(self)
		local weapon = self._unit and self._unit:weapon()
		if weapon then
			module:pdthpp_sentry_diag_bump(weapon, "check_fire")
		end
	end, false)

	-- 客机收到 cop_allow_fire / cop_forbid_fire 后最终都会进入此函数。
	-- 连续收到相同状态会被单独标记，便于判断网络消息是否重复处理。
	module:pre_hook(SentryGunBrain, "synch_allow_fire", function(self, state_value)
		local weapon = self._unit and self._unit:weapon()
		if not weapon then
			return
		end

		local state = module:pdthpp_sentry_diag_bump(
			weapon,
			state_value and "sync_allow" or "sync_forbid"
		)
		local now = game_time()
		if state.last_sync_state == state_value
			and state.last_sync_t
			and now - state.last_sync_t < 0.1 then
			module:pdthpp_sentry_diag_warn(
				weapon,
				"DUPLICATE-NET-STATE",
				string.format(
					"sentry=%s state=%s dt=%.6f",
					tostring(self._unit:key()),
					bool_text(state_value),
					now - state.last_sync_t
				)
			)
		end
		state.last_sync_state = state_value
		state.last_sync_t = now
	end, false)

	module:pre_hook(SentryGunBrain, "set_active", function(self, active)
		if active then
			return
		end
		local weapon = self._unit and self._unit:weapon()
		if weapon then
			module:pdthpp_sentry_diag_flush(weapon, true, "set_active_false")
		end
	end, false)

	module:pre_hook(SentryGunBrain, "pre_destroy", function(self)
		local weapon = self._unit and self._unit:weapon()
		if weapon then
			module:pdthpp_sentry_diag_flush(weapon, true, "pre_destroy")
		end
	end, false)

elseif install_branch and required_script == "lib/units/equipment/sentry_gun/sentrygunmovement" then
	local SentryGunMovement = module:hook_class("SentryGunMovement")

	module:pre_hook(SentryGunMovement, "_pdthpp_target_position", function(self, target_unit)
		local weapon = self._unit and self._unit:weapon()
		if weapon then
			module:pdthpp_sentry_diag_bump(weapon, "target_solution")
		end
	end, false)

	module:pre_hook(SentryGunMovement, "_pdthpp_target_ray_result", function(self)
		local weapon = self._unit and self._unit:weapon()
		if weapon then
			module:pdthpp_sentry_diag_bump(weapon, "target_probe_rays")
		end
	end, false)

	module:pre_hook(SentryGunMovement, "_pdthpp_on_focus_changed", function(self, target_unit)
		local weapon = self._unit and self._unit:weapon()
		if not weapon then
			return
		end

		local state = module:pdthpp_sentry_diag_bump(weapon, "focus_change")
		local signature = target_unit and alive(target_unit) and target_unit:key() or "-"
		if state.last_focus_signature ~= signature then
			state.last_focus_signature = signature
			module:pdthpp_sentry_diag_event(
				weapon,
				"FOCUS",
				string.format(
					"sentry=%s target={%s}",
					tostring(self._unit:key()),
					module:pdthpp_sentry_diag_unit_desc(target_unit)
				)
			)
		end
	end, false)
end
