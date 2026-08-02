--[[
步哨回收经济、精确状态同步与 HUD 兼容的公共实现。

主要职责：
1. 按步哨已消耗弹药比例计算回收费，最低总计 12%，打空时最高总计 30%；
2. 在所有允许捡弹的玩家武器之间平均分摊，某把武器不足时由其余武器补足，
   pickup_disabled 武器（例如榴弹发射器）完全不参与；
3. 主机以权威值同步步哨弹药、上限与耐久，客机只写入 PDTH++ 专用缓存字段；
4. 为 PDTH++ 交互提示和独立 `_hud` 模组提供客机可见的精确信息；
5. 处理指定步哨的多人回收请求，不再按所有者扫描并批量销毁部署物。

注意：本文件会通过多个 RequiredScript 入口加载。公共函数区必须只初始化一次，
底部针对 SentryGunBase / Weapon / Damage 的挂钩则按当前 RequiredScript 分别安装。
]]

local module = ... or D:module("PDTH++")

-- Ammunition cost for recovering a sentry gun.
-- Cost = 30% multiplied by the sentry's consumed-ammo ratio, with a 12% minimum.
-- Examples: 0%-40% consumed costs 12%, 50% consumed costs 15%, empty costs 30%.
-- Eligible weapons share the cost equally; if one cannot pay its share, the
-- others cover the deficit. Weapons whose pickup_disabled() returns true never
-- participate. The cost is calculated and locked when pickup interaction starts.
local SENTRY_PICKUP_AMMO_RATIO_MAX_COST = 0.30
local SENTRY_PICKUP_AMMO_RATIO_MIN_COST = 0.12
-- Exact sentry status network pacing. Updates are never sent more often than
-- once every 0.25 seconds. Small changes may be batched, but any pending change
-- is flushed within 1 second while the sentry remains active.
local STATUS_SYNC_MIN_INTERVAL = 0.25
local STATUS_SYNC_MAX_INTERVAL = 1.00
local STATUS_SYNC_MIN_DELTA = 0.01
local EPSILON = 0.000001

-- 多入口加载保护：同一组 module 方法、缓存表与本地辅助函数只能定义一次。
if not module._pdthpp_sentry_ammo_helpers_ready then
	module._pdthpp_sentry_ammo_helpers_ready = true
	module._pdthpp_sentry_status_cache = module._pdthpp_sentry_status_cache or {}
	module._pdthpp_pending_sentry_pickup_costs = module._pdthpp_pending_sentry_pickup_costs or {}
	module._pdthpp_sentry_status_request_times = module._pdthpp_sentry_status_request_times or {}

	-- 返回可参与回收费的武器。无效单位、无弹药字段或 pickup_disabled 武器会被排除。
	local function valid_weapon_base(selection)
		local unit = selection and selection.unit
		if not alive(unit) then
			return nil
		end

		local base = unit:base()
		if not base or not base._ammo_max or base._ammo_max <= 0 or base._ammo_total == nil then
			return nil
		end

		if base.pickup_disabled and base:pickup_disabled() then
			return nil
		end

		return base, unit
	end

	-- 扣弹后同时刷新当前武器大号弹药栏与 DAHM HUD 中全部武器的小号弹药数字。
	function module:pdthpp_refresh_local_ammo_hud()
		local player = managers.player and managers.player:player_unit()
		local inventory = alive(player) and player:inventory()
		local hud = managers.hud
		if not inventory or not hud then
			return
		end

		local selections = inventory:available_selections()
		if selections and hud.set_weapon_ammo_by_unit then
			for _, selection in pairs(selections) do
				local unit = selection and selection.unit
				if alive(unit) then
					hud:set_weapon_ammo_by_unit(unit)
				end
			end
		end

		local equipped = inventory:equipped_unit()
		local base = alive(equipped) and equipped:base()
		if base and base.ammo_info then
			hud:set_ammo_amount(base:ammo_info())
		end
	end

	-- 根据剩余弹药换算本次总费用：max(12%, 30% × 已消耗比例)。
	-- 返回的是“武器容量比例总和”，不是具体子弹发数。
	function module:pdthpp_sentry_pickup_cost_ratio(sentry_unit)
		local remaining_ratio = self:pdthpp_get_sentry_ammo_ratio(sentry_unit)
		local consumed_ratio = 1 - math.max(0, math.min(1, remaining_ratio))
		return math.max(
			SENTRY_PICKUP_AMMO_RATIO_MIN_COST,
			SENTRY_PICKUP_AMMO_RATIO_MAX_COST * consumed_ratio
		)
	end

	-- Build an atomic cost plan without changing ammunition. cost_ratio is locked
	-- when the pickup interaction starts and remains unchanged while the sentry
	-- continues firing during the interaction.
	-- 只生成原子化扣费方案，不立即修改弹药。
	-- 使用水位分摊算法：先平均分配，弹药不足的武器退出后，其缺口由剩余武器继续均摊。
	function module:pdthpp_build_sentry_pickup_cost_plan(player_unit, cost_ratio)
		cost_ratio = tonumber(cost_ratio)
		if not cost_ratio or cost_ratio < 0 then
			return nil
		end
		cost_ratio = math.max(
			SENTRY_PICKUP_AMMO_RATIO_MIN_COST,
			math.min(SENTRY_PICKUP_AMMO_RATIO_MAX_COST, cost_ratio)
		)
		local inventory = alive(player_unit) and player_unit:inventory()
		local selections = inventory and inventory:available_selections()
		if not selections then
			return nil
		end

		local entries = {}
		local total_available_ratio = 0
		for selection_index, selection in pairs(selections) do
			local base, unit = valid_weapon_base(selection)
			if base then
				local available_ratio = math.max(0, base._ammo_total / base._ammo_max)
				entries[#entries + 1] = {
					selection_index = selection_index,
					weapon_unit = unit,
					weapon_base = base,
					available_ratio = available_ratio,
					allocated_ratio = 0,
				}
				total_available_ratio = total_available_ratio + available_ratio
			end
		end

		if #entries == 0 or total_available_ratio + EPSILON < cost_ratio then
			return nil
		end

		-- Equal-share water filling. At the 12% minimum, three eligible weapons
		-- normally pay 4% each; two eligible weapons pay 6% each. Shortfalls are
		-- transferred automatically. At maximum cost these become 10% / 15%.
		local remaining = cost_ratio
		local active = {}
		for i = 1, #entries do
			active[i] = entries[i]
		end

		while remaining > EPSILON and #active > 0 do
			local equal_share = remaining / #active
			local paid_this_pass = 0
			local next_active = {}

			for i = 1, #active do
				local entry = active[i]
				local room = math.max(0, entry.available_ratio - entry.allocated_ratio)
				local paid = math.min(equal_share, room)
				entry.allocated_ratio = entry.allocated_ratio + paid
				paid_this_pass = paid_this_pass + paid
				if room - paid > EPSILON then
					next_active[#next_active + 1] = entry
				end
			end

			remaining = remaining - paid_this_pass
			active = next_active
			if paid_this_pass <= EPSILON then
				break
			end
		end

		if remaining > EPSILON then
			return nil
		end

		return { entries = entries, cost_ratio = cost_ratio }
	end

	-- 提交已锁定的扣费方案。先再次验证所有武器和取整后的发数，
	-- 全部可支付后才统一扣除，避免只扣了一部分后中途失败。
	function module:pdthpp_apply_sentry_pickup_cost_plan(plan)
		if not plan or plan.applied then
			return false
		end

		-- Validate every weapon and every rounded amount before changing anything.
		local validated = {}
		for i = 1, #plan.entries do
			local entry = plan.entries[i]
			local base = alive(entry.weapon_unit) and entry.weapon_unit:base()
			if not base or base ~= entry.weapon_base or not base._ammo_max
				or base._ammo_max <= 0 or base._ammo_total == nil
				or (base.pickup_disabled and base:pickup_disabled()) then
				return false
			end

			local rounds = math.ceil(entry.allocated_ratio * base._ammo_max - EPSILON)
			if rounds > base._ammo_total then
				return false
			end
			validated[#validated + 1] = { base = base, rounds = rounds }
		end

		for i = 1, #validated do
			local item = validated[i]
			item.base._ammo_total = math.max(0, item.base._ammo_total - item.rounds)
			if item.base._ammo_remaining_in_clip then
				item.base._ammo_remaining_in_clip = math.min(
					item.base._ammo_remaining_in_clip,
					item.base._ammo_total
				)
			end
		end

		plan.applied = true
		self:pdthpp_refresh_local_ammo_hud()
		return true
	end

	-- 网络同步和缓存统一使用有效的网络单位 ID；-1 表示尚未联网注册，不能作为键。
	function module:pdthpp_sentry_unit_key(unit)
		if not alive(unit) then
			return nil
		end
		local id = unit:id()
		return id and id ~= -1 and id or nil
	end

	-- 按网络 ID 精确寻找步哨。回收消息必须指定单座步哨，避免旧逻辑误处理同一玩家的其他部署物。
	function module:pdthpp_find_sentry_by_id(unit_id)
		if unit_id == nil then
			return nil
		end
		local units = World:find_units_quick("all", 14, 25, 26)
		for i = 1, #units do
			local unit = units[i]
			if alive(unit) and unit:id() == unit_id then
				local base = unit:base()
				if base and base.get_name_id and base:get_name_id() == "sentry_gun" then
					return unit
				end
			end
		end
		return nil
	end

	-- 统一读取弹药比例：主机优先实时权威字段，客机优先 PDTH++ 精确同步缓存，
	-- 最后才回退到原版约 20% 一档的粗略 `_ammo_ratio`。
	function module:pdthpp_get_sentry_ammo_ratio(unit)
		local weapon = alive(unit) and unit:weapon()
		if not weapon then
			return 0
		end
		-- Prefer PDTH++'s exact synchronized value on clients. The host must use its
		-- authoritative live ammo count rather than the last synchronized snapshot.
		if Network:is_client() and weapon._pdthpp_exact_ammo_ratio ~= nil then
			return math.max(0, math.min(1, weapon._pdthpp_exact_ammo_ratio))
		end
		if weapon._ammo_total ~= nil and weapon._ammo_max and weapon._ammo_max > 0 then
			return math.max(0, math.min(1, weapon._ammo_total / weapon._ammo_max))
		end
		if weapon._pdthpp_exact_ammo_ratio ~= nil then
			return math.max(0, math.min(1, weapon._pdthpp_exact_ammo_ratio))
		end
		if weapon._ammo_ratio ~= nil then
			return math.max(0, math.min(1, weapon._ammo_ratio <= 1 and weapon._ammo_ratio or weapon._ammo_ratio / 100))
		end
		return 0
	end

	-- 与弹药读取规则对应：主机使用实时耐久，客机优先精确缓存，再回退原版粗略比例。
	function module:pdthpp_get_sentry_health_ratio(unit)
		local damage = alive(unit) and unit:character_damage()
		if not damage then
			return 0
		end
		if Network:is_client() and damage._pdthpp_exact_health_ratio ~= nil then
			return math.max(0, math.min(1, damage._pdthpp_exact_health_ratio))
		end
		if damage._health ~= nil and damage._health_max and damage._health_max > 0 then
			return math.max(0, math.min(1, damage._health / damage._health_max))
		end
		if damage._pdthpp_exact_health_ratio ~= nil then
			return math.max(0, math.min(1, damage._pdthpp_exact_health_ratio))
		end
		if damage._health_ratio ~= nil then
			return math.max(0, math.min(1, damage._health_ratio <= 1 and damage._health_ratio or damage._health_ratio / 100))
		end
		return 0
	end

	function module:pdthpp_hud_module_active()
		local hud_module = D:module("hud", false)
		return hud_module and hud_module:active() or false
	end

	-- Optional compatibility for the separate `_hud` mod's DeployableSpy.
	-- DAHM keeps mod globals in each mod's private environment. Accessing the
	-- undeclared name DeployableSpy directly from PDTH++ can therefore crash.
	-- `_hud` 的 DeployableSpy 位于该模组自己的私有环境，不能直接访问未声明全局。
	-- 这里安全取得引用，并兼容少数旧版本暴露到 _G 的实现。
	local function pdthpp_get_hud_deployable_spy()
		local hud_module = D:module("_hud", false)
		local hud_env = hud_module and rawget(hud_module, "_ENV")
		local spy = hud_env and rawget(hud_env, "DeployableSpy")

		-- Compatibility with older/non-sandboxed variants that expose it globally.
		if type(spy) ~= "table" then
			spy = rawget(_G, "DeployableSpy")
		end

		return type(spy) == "table" and spy or nil, hud_module
	end

	-- The original spy only registers sentries on the host and reads host-only
	-- fields such as _ammo_total and _health. On clients, PDTH++ instead feeds
	-- the spy its exact synchronized ratios without modifying gameplay fields.
	-- 安装一次 `_hud` 文本适配：仅在客机显示步哨时改用 PDTH++ 同步值，
	-- 不覆盖游戏内部 `_ammo_total` / `_health`，以免 HUD 兼容代码反向影响玩法逻辑。
	function module:pdthpp_install_hud_deployable_spy_compat()
		local spy, hud_module = pdthpp_get_hud_deployable_spy()
		if not hud_module or not spy then
			return false
		end
		if type(hud_module.active) == "function" and not hud_module:active() then
			return false
		end
		if type(spy.get_item_text) ~= "function" then
			return false
		end
		if self._pdthpp_hud_deployable_spy_compat_installed
			and self._pdthpp_hud_deployable_spy_ref == spy then
			return true
		end

		local original_get_item_text = spy.get_item_text
		spy._pdthpp_original_get_item_text = original_get_item_text

		spy.get_item_text = function(self, unit, unit_type)
			if unit_type == "sentry_gun" and Network:is_client() and alive(unit) then
				local weapon = unit:weapon()
				local damage = unit:character_damage()
				local ammo_ratio = weapon and weapon._pdthpp_exact_ammo_ratio
				local health_ratio = damage and damage._pdthpp_exact_health_ratio

				if ammo_ratio ~= nil and health_ratio ~= nil then
					ammo_ratio = math.max(0, math.min(1, ammo_ratio))
					health_ratio = math.max(0, math.min(1, health_ratio))
					if health_ratio <= 0 or ammo_ratio <= 0 then
						return nil
					end

					local text = D:conf("_hud_sentry_gun_spy")
					local toolbox = self._toolbox
					if text and toolbox and type(toolbox.string_format) == "function" then
						local ammo_max = tonumber(weapon._pdthpp_exact_ammo_max) or 0
						local ammo_total = tonumber(weapon._pdthpp_exact_ammo_total) or 0
						if ammo_max <= 0 then
							-- Backward-compatible fallback when connected to an older host.
							ammo_max = 100
							ammo_total = ammo_ratio * ammo_max
						end
						return toolbox:string_format(text, {
							AMMO = math.floor(math.max(0, math.min(ammo_max, ammo_total)) + 0.5),
							AMMO_MAX = math.floor(ammo_max + 0.5),
							HEALTH = math.floor(health_ratio * 100 + 0.5),
						})
					end
				end
			end

			return original_get_item_text(self, unit, unit_type)
		end

		self._pdthpp_hud_deployable_spy_compat_installed = true
		self._pdthpp_hud_deployable_spy_ref = spy
		return true
	end

	-- 原 `_hud` 只在主机注册步哨；客机收到完整状态后在此补注册显示对象。
	function module:pdthpp_register_sentry_with_hud_deployable_spy(unit)
		if not Network:is_client() or not alive(unit) then
			return false
		end
		if not self:pdthpp_install_hud_deployable_spy_compat() then
			return false
		end
		local spy = pdthpp_get_hud_deployable_spy()
		if not spy or type(spy.add) ~= "function" then
			return false
		end

		local weapon = unit:weapon()
		local damage = unit:character_damage()
		if not weapon or weapon._pdthpp_exact_ammo_ratio == nil
			or not damage or damage._pdthpp_exact_health_ratio == nil then
			return false
		end

		spy:add(unit, "sentry_gun")
		return true
	end

	-- 客机主动补请求精确状态。用于处理初始广播早于本地网络单位创建的时序问题，
	-- 并以 1 秒请求冷却避免原版粗略同步频繁触发网络请求。
	function module:pdthpp_request_exact_sentry_status(unit, force)
		if not Network:is_client() or not alive(unit) then
			return false
		end

		local unit_id = self:pdthpp_sentry_unit_key(unit)
		if not unit_id then
			return false
		end

		local weapon = unit:weapon()
		local damage = unit:character_damage()
		if not force and weapon and weapon._pdthpp_exact_ammo_ratio ~= nil
			and damage and damage._pdthpp_exact_health_ratio ~= nil then
			self:pdthpp_register_sentry_with_hud_deployable_spy(unit)
			return true
		end

		local t = TimerManager:game():time()
		local last_request = self._pdthpp_sentry_status_request_times[unit_id]
		if not force and last_request and t - last_request < 1 then
			return false
		end

		local session = managers.network and managers.network:session()
		local server_peer = session and session:server_peer()
		if not server_peer then
			return false
		end

		self._pdthpp_sentry_status_request_times[unit_id] = t
		return DNet:send_to_peer(server_peer, "PDTHPPSentryStatusRequest", {
			module = self:id(),
			unit_id = unit_id,
		}, false, false) and true or false
	end

	-- 在准星选中步哨时，把精确弹药/耐久百分比追加到原交互提示。
	-- 若客机尚无精确值，会先请求主机，但本帧仍可用现有回退值显示。
	function module:pdthpp_show_sentry_status_interact(interaction_ext, player)
		if not self:pdthpp_hud_module_active() or not interaction_ext or not alive(interaction_ext._unit) then
			return
		end

		local tweak = interaction_ext._tweak_data
		if not tweak or not managers.hud then
			return
		end

		if Network:is_client() then
			local weapon = interaction_ext._unit:weapon()
			local damage = interaction_ext._unit:character_damage()
			if (not weapon or weapon._pdthpp_exact_ammo_ratio == nil)
				or (not damage or damage._pdthpp_exact_health_ratio == nil) then
				local session = managers.network and managers.network:session()
				local server_peer = session and session:server_peer()
				if server_peer and not interaction_ext._pdthpp_status_requested then
					interaction_ext._pdthpp_status_requested = true
					DNet:send_to_peer(server_peer, "PDTHPPSentryStatusRequest", {
						module = self:id(),
						unit_id = interaction_ext._unit:id(),
					}, false, false)
				end
			end
		end

		local text = managers.localization:text(tweak.text_id, {
			BTN_INTERACT = interaction_ext:_btn_interact(),
		})
		local ammo = math.floor(self:pdthpp_get_sentry_ammo_ratio(interaction_ext._unit) * 100 + 0.5)
		local health = math.floor(self:pdthpp_get_sentry_health_ratio(interaction_ext._unit) * 100 + 0.5)
		local status = managers.localization:text("pdthpp_sentry_status_hud", {
			AMMO = tostring(ammo),
			HEALTH = tostring(health),
		})
		managers.hud:show_interact({ text = text .. "\n" .. status, icon = tweak.icon })
	end

	function module:pdthpp_refresh_active_sentry_hud(unit)
		if not self:pdthpp_hud_module_active() or not managers.interaction then
			return
		end
		if managers.interaction:active_object() == unit then
			local interaction = unit:interaction()
			local player = managers.player and managers.player:player_unit()
			if interaction and alive(player) then
				self:pdthpp_show_sentry_status_interact(interaction, player)
			end
		end
	end

	-- 构造主机权威状态包。绝对弹药数仅供 HUD 展示，客机不会写回游戏实际弹药字段。
	local function sentry_status_payload(module_self, unit)
		local server_info = unit:base() and unit:base().server_information and unit:base():server_information()
		local weapon = unit:weapon()
		return {
			module = module_self:id(),
			unit_id = unit:id(),
			owner_peer_id = server_info and server_info.owner_peer_id,
			ammo_ratio = module_self:pdthpp_get_sentry_ammo_ratio(unit),
			health_ratio = module_self:pdthpp_get_sentry_health_ratio(unit),
			-- Absolute sentry ammunition is synchronized for HUD display only.
			-- Clients keep it in PDTH++-specific fields and never overwrite gameplay state.
			ammo_total = weapon and weapon._ammo_total or nil,
			ammo_max = weapon and weapon._ammo_max or nil,
		}
	end

	-- 针对单个客机立即回复状态请求，不经过广播节流。
	function module:pdthpp_send_sentry_status_to_peer(unit, peer)
		if not Network:is_server() or not alive(unit) or not peer or peer:is_local_user() then
			return false
		end
		return DNet:send_to_peer(peer, "PDTHPPSentryStatus", sentry_status_payload(self, unit), false, false) and true or false
	end

	-- 广播状态的节流入口：最短 0.25 秒，细小变化最多合并 1 秒；
	-- 完全无变化时不发送。force 用于单位刚建立等必须立即同步的场景。
	function module:pdthpp_send_sentry_status(unit, force)
		if not Network:is_server() or not alive(unit) then
			return
		end

		local unit_id = self:pdthpp_sentry_unit_key(unit)
		if not unit_id then
			return
		end
		local payload = sentry_status_payload(self, unit)
		local ammo = payload.ammo_ratio
		local health = payload.health_ratio
		local t = TimerManager:game():time()
		local old = self._pdthpp_sentry_status_cache[unit_id]
		if not force and old then
			local elapsed = t - old.t
			local ammo_delta = math.abs(old.ammo - ammo)
			local health_delta = math.abs(old.health - health)
			local changed = ammo_delta > EPSILON or health_delta > EPSILON

			-- Never send faster than the minimum interval. Once that interval has
			-- elapsed, meaningful changes are sent immediately; smaller changes are
			-- held until the maximum interval so a single shot or small damage event
			-- is not left stale indefinitely. Unchanged sentries send nothing.
			if elapsed < STATUS_SYNC_MIN_INTERVAL
				or not changed
				or elapsed < STATUS_SYNC_MAX_INTERVAL
					and ammo_delta < STATUS_SYNC_MIN_DELTA
					and health_delta < STATUS_SYNC_MIN_DELTA then
				return
			end
		end

		self._pdthpp_sentry_status_cache[unit_id] = { t = t, ammo = ammo, health = health }
		local weapon = unit:weapon()
		local damage = unit:character_damage()
		if weapon then weapon._pdthpp_exact_ammo_ratio = ammo end
		if damage then damage._pdthpp_exact_health_ratio = health end
		self:pdthpp_refresh_active_sentry_hud(unit)

		if managers.network and managers.network:session() then
			DNet:send_to_peers_synched("PDTHPPSentryStatus", payload, false, false)
		end
	end

	-- 客机应用主机状态。所有精确值保存在 `_pdthpp_exact_*` 字段，
	-- 原版比例字段只用于帮助现有界面读取，绝对游戏状态不由客机篡改。
	function module:pdthpp_apply_remote_sentry_status(data)
		local unit = data and self:pdthpp_find_sentry_by_id(data.unit_id)
		if not alive(unit) then
			return false
		end
		local ammo = math.max(0, math.min(1, tonumber(data.ammo_ratio) or 0))
		local health = math.max(0, math.min(1, tonumber(data.health_ratio) or 0))
		local weapon = unit:weapon()
		local damage = unit:character_damage()
		if weapon then
			weapon._pdthpp_exact_ammo_ratio = ammo
			weapon._pdthpp_exact_ammo_total = math.max(0, tonumber(data.ammo_total) or 0)
			weapon._pdthpp_exact_ammo_max = math.max(0, tonumber(data.ammo_max) or 0)
			weapon._ammo_ratio = ammo * 100
		end
		if damage then
			damage._pdthpp_exact_health_ratio = health
			damage._health_ratio = health * 100
		end
		local interaction = unit:interaction()
		if interaction then
			interaction._pdthpp_status_requested = nil
		end
		self._pdthpp_sentry_status_request_times[data.unit_id] = nil
		self:pdthpp_register_sentry_with_hud_deployable_spy(unit)
		self:pdthpp_refresh_active_sentry_hud(unit)
		return true
	end

	function module:pdthpp_destroy_sentry_exact(unit)
		if alive(unit) and unit:base() and unit:base().destroy_sentry then
			unit:base():destroy_sentry()
			return true
		end
		return false
	end

	function module:pdthpp_has_local_sentry_equipment_space()
		local data = managers.player and managers.player:equipment_data_by_name("sentry_gun")
		return data and data.amount < 1 or false
	end

	function module:pdthpp_add_local_sentry_equipment()
		local data, index = managers.player:equipment_data_by_name("sentry_gun")
		if not data or data.amount >= 1 then
			return false
		end
		data.amount = math.min(1, data.amount + 1)
		if managers.hud then
			managers.hud:set_item_amount(index, data.amount)
		end
		return true
	end

	function module:pdthpp_sentry_owner_peer_id(unit)
		local base = alive(unit) and unit:base()
		local info = base and base.server_information and base:server_information()
		return info and info.owner_peer_id
	end

	-- The host still authoritatively validates ownership and destroys the exact unit.
	-- The fixed weapon-ammo charge itself is local and no ammo values cross the network.
	-- 主机权威回收流程：验证所有者、阻止重复请求、销毁指定单位并通知所有客机。
	-- 本地主机在此提交扣费；远程客机的武器扣费仍由其本地在成功结果到达后完成。
	function module:pdthpp_host_process_sentry_pickup(peer, unit, local_cost_plan)
		if not Network:is_server() or not peer or not alive(unit) then
			return false
		end

		local owner_peer_id = self:pdthpp_sentry_owner_peer_id(unit)
		if owner_peer_id ~= peer:id() then
			return false
		end

		local base = unit:base()
		if not base or base._pdthpp_pickup_in_progress then
			return false
		end

		local unit_id = unit:id()
		if peer:is_local_user() then
			local player = managers.player and managers.player:player_unit()
			local plan = local_cost_plan or self:pdthpp_build_sentry_pickup_cost_plan(
				player,
				self:pdthpp_sentry_pickup_cost_ratio(unit)
			)
			if not plan or not self:pdthpp_has_local_sentry_equipment_space() then
				return false
			end

			base._pdthpp_pickup_in_progress = true
			if not self:pdthpp_apply_sentry_pickup_cost_plan(plan)
				or not self:pdthpp_add_local_sentry_equipment() then
				base._pdthpp_pickup_in_progress = nil
				return false
			end
		else
			base._pdthpp_pickup_in_progress = true
			DNet:send_to_peer(peer, "PDTHPPSentryPickupResult", {
				module = self:id(),
				success = true,
				unit_id = unit_id,
			}, false, true)
		end

		DNet:send_to_peers("PDTHPPSentryDestroyed", {
			module = self:id(),
			unit_id = unit_id,
		}, false, false)
		local status_key = self:pdthpp_sentry_unit_key(unit)
		if status_key then
			self._pdthpp_sentry_status_cache[status_key] = nil
		end
		self:pdthpp_destroy_sentry_exact(unit)
		return true
	end
end

-- 以下挂钩按当前加载的原版脚本分别安装；公共逻辑已由上方一次性保护定义。
-- SentryGunBase：步哨完成网络所有者初始化后，主机立即广播，客机则补请求一次。
if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
	local SentryGunBase = module:hook_class("SentryGunBase")

	module:post_hook(SentryGunBase, "set_server_information", function(self, peer_id)
		if Network:is_server() then
			module:pdthpp_send_sentry_status(self._unit, true)
		else
			-- The host's initial status broadcast can arrive before this network
			-- unit exists locally. Request it again once the client sentry is ready.
			module:pdthpp_request_exact_sentry_status(self._unit, false)
		end
	end, false)
end

-- SentryGunWeapon：每次实际开火后尝试节流同步；收到原版粗略弹药同步时补请求精确值。
if RequiredScript == "lib/units/weapons/sentrygunweapon" then
	local SentryGunWeapon = module:hook_class("SentryGunWeapon")

	function SentryGunWeapon:ammo_ratio()
		return module:pdthpp_get_sentry_ammo_ratio(self._unit)
	end

	-- 防御性清理自动射击循环音。正常情况下 start/stop_autofire 会严格成对，
	-- 但若外部状态或网络顺序曾令 `_shooting` 与声音句柄短暂不同步，直接再次
	-- 启动会覆盖旧句柄，使旧的 turret_fire 循环无法再被停止。开始新循环前先
	-- 停掉仍被记录的旧事件，可避免多个持续枪声同时叠加。
	module:pre_hook(SentryGunWeapon, "_sound_autofire_start", function(self)
		if self._autofire_sound_event then
			self._autofire_sound_event:stop()
			self._autofire_sound_event = nil
		end
	end, false)

	-- 若逻辑要求停火时武器 `_shooting` 已经是空值，原版 stop_autofire 会直接
	-- 返回而不会清理残留声音；这里仅处理这种异常分支，不改变正常结束音效。
	module:pre_hook(SentryGunWeapon, "stop_autofire", function(self)
		if not self._shooting and self._autofire_sound_event then
			self._autofire_sound_event:stop()
			self._autofire_sound_event = nil
		end
	end, false)

	-- Preserve fire()'s return value so the original fire-rate timer advances.
	module:post_hook(SentryGunWeapon, "fire", function(self)
		if Network:is_server() then
			module:pdthpp_send_sentry_status(self._unit, false)
		end
	end, true)

	module:post_hook(SentryGunWeapon, "sync_ammo", function(self)
		if Network:is_client() then
			module:pdthpp_request_exact_sentry_status(self._unit, false)
		end
	end, false)
end

-- SentryGunDamage：提供统一耐久比例，并在受伤/粗略同步后更新或请求精确状态。
if RequiredScript == "lib/units/equipment/sentry_gun/sentrygundamage" then
	local SentryGunDamage = module:hook_class("SentryGunDamage")

	module:hook(SentryGunDamage, "health_ratio", function(self)
		return module:pdthpp_get_sentry_health_ratio(self._unit)
	end, true)

	module:post_hook(SentryGunDamage, "damage_bullet", function(self)
		if Network:is_server() then
			module:pdthpp_send_sentry_status(self._unit, false)
		end
	end, false)

	module:post_hook(SentryGunDamage, "sync_health", function(self)
		if Network:is_client() then
			module:pdthpp_request_exact_sentry_status(self._unit, false)
		end
	end, false)
end
