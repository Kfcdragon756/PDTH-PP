--[[
步哨回收交互与部署物交互扩展。
步哨回收费在玩家开始长按互动时根据当时的剩余弹药比例报价并锁定，
中途取消不扣费，完成回收后才真正扣除玩家武器弹药。
主机负责验证所有权并销毁指定步哨；客机只保存本地扣费方案并等待主机结果。
本文件同时承载步哨交互提示的 HUD 追加，原因是自定义交互类在此处才完成创建。
]]

local module = ... or D:module("PDTH++")
local UseInteractionExt = module:hook_class("UseInteractionExt")
local SentryGunInteractionExt = module:hook_class("SentryGunInteractionExt", class, UseInteractionExt)
local AmmoBagInteractionExt = module:hook_class("AmmoBagInteractionExt")

-- 追加步哨弹药/耐久提示。必须直接写在类定义之后，
-- 避免 sentryammo.lua 提前挂钩尚不存在的类而造成加载阶段崩溃。
function SentryGunInteractionExt:selected(player)
	-- SentryGunInteractionExt is created in this file, so keep the HUD extension here
	-- instead of trying to hook the class before it exists during script loading.
	SentryGunInteractionExt.super.selected(self, player)
	module:pdthpp_show_sentry_status_interact(self, player)
end

-- 玩家按下互动键时执行的即时资格检查。
-- 此处只计算并锁定费用分配方案，不修改任何武器弹药；返回 true 会阻止长按进度开始。
function SentryGunInteractionExt:_interact_blocked(player)
	-- BaseInteractionExt calls this exactly when the player tries to start the
	-- interaction. Calculate and lock both the price and its weapon allocation here.
	self._pdthpp_locked_pickup_cost_plan = nil
	self._pdthpp_locked_pickup_cost_ratio = nil

	local data = managers.player:equipment_data_by_name("sentry_gun")
	local session = managers.network and managers.network:session()
	local local_peer = session and session:local_peer()
	local owner_peer_id = module:pdthpp_sentry_owner_peer_id(self._unit)
	if not data
		or data.amount >= 1
		or not local_peer
		or owner_peer_id ~= local_peer:id()
		or self._pdthpp_pickup_requested then
		return true
	end

	local cost_ratio = module:pdthpp_sentry_pickup_cost_ratio(self._unit)
	local plan = module:pdthpp_build_sentry_pickup_cost_plan(player, cost_ratio)
	if not plan then
		return true
	end

	self._pdthpp_locked_pickup_cost_ratio = cost_ratio
	self._pdthpp_locked_pickup_cost_plan = plan
	return false
end

-- 互动被移动、受击或主动松键打断时清除锁定报价，确保没有实际回收就不扣弹药。
function SentryGunInteractionExt:_at_interact_interupt(player)
	-- Cancelling the hold interaction never consumes ammo and discards the quote.
	self._pdthpp_locked_pickup_cost_plan = nil
	self._pdthpp_locked_pickup_cost_ratio = nil
end

-- 长按完成后的正式回收入口。
-- 客机把具体步哨网络 ID 发给主机；主机验证成功后，客机才按先前锁定的方案扣弹并返还设备。
function SentryGunInteractionExt:interact(player)
	SentryGunInteractionExt.super.super.interact(self, player)
	local session = managers.network and managers.network:session()
	local local_peer = session and session:local_peer()
	if not session or not local_peer or not alive(self._unit) then
		self._pdthpp_locked_pickup_cost_plan = nil
		self._pdthpp_locked_pickup_cost_ratio = nil
		return false
	end

	-- Use the plan locked when the interaction began. The sentry may continue to
	-- fire during the hold, but that does not increase this pickup's price.
	local plan = self._pdthpp_locked_pickup_cost_plan
	self._pdthpp_locked_pickup_cost_plan = nil
	self._pdthpp_locked_pickup_cost_ratio = nil
	if not plan then
		if managers.hud then
			managers.hud:show_hint({ text = managers.localization:text("pdthpp_sentry_not_enough_ammo") })
		end
		return false
	end

	if Network:is_client() then
		local server_peer = session:server_peer()
		if not server_peer then
			return false
		end
		local unit_id = self._unit:id()
		self._pdthpp_pickup_requested = true
		module._pdthpp_pending_sentry_pickup_costs[unit_id] = plan
		DNet:send_to_peer(server_peer, "PDTHPPSentryPickupRequest", {
			module = module:id(),
			unit_id = unit_id,
		}, false, true)
		return true
	end

	return module:pdthpp_host_process_sentry_pickup(local_peer, self._unit, plan)
end

module:hook(AmmoBagInteractionExt, "interact", function(self, player) -- Extra start ammo now provides a instant reload while interacted with an ammo bag.
	if managers.player:has_special_equipment("extra_start_out_ammo") then
		player:inventory():equipped_unit():base():on_reload()
	end
	module:call_orig(AmmoBagInteractionExt, "interact", self, player)
	if managers.player:has_special_equipment("extra_start_out_ammo") then
		player:inventory():equipped_unit():base():_reload_instant()
	end
end, false)
-- Why set up this function like this bullshit?
-- This is for making sure that your clip ammo amount is always full and you will always gain reload penalty in "littering everywhere" mutator.
