local module = ... or D:module("PDTH++")
if RequiredScript == "lib/units/enemies/cop/copinventory" then

	local CopInventory = module:hook_class("CopInventory")

	-- 盾兵生成并挂接盾牌后，立即创建五个区域的状态并校正所有模型显隐。
	module:post_hook(CopInventory, "_chk_spawn_shield", function(self, weapon_unit)
		if alive(self._shield_unit) then
			-- 盾牌是每个客户端自行 spawn 的附件，不能直接拿盾牌 unit:id() 做跨端定位；
			-- 把网络同步的盾兵单位作为所有者传入，统一生成稳定的盾牌网络标识。
			module:register_shield(self._shield_unit, self._unit)
		end
	end, false)


	-- 盾兵死亡/丢盾前先把盾牌转入强引用的“掉落盾牌”登记表。
	-- 这样 parent 失效后，仍能保留之前的五区伤害、破损模型与穿透状态。
	module:pre_hook(CopInventory, "drop_shield", function(self)
		if alive(self._shield_unit) then
			module:mark_shield_dropped(self._shield_unit)
		end
	end, false)

	-- 原版 sequence 已切换为 dropped_body 后，再重新应用一次模型显隐。
	module:post_hook(CopInventory, "drop_shield", function(self)
		if alive(self._shield_unit) then
			local state = module:get_existing_grille_state(self._shield_unit)
			if state then
				state.dropped = true
				module:apply_visual_state(self._shield_unit, state)
			end
		end
	end, false)

end

if RequiredScript == "lib/units/weapons/raycastweaponbase" then

	local InstantBulletBase = module:hook_class("InstantBulletBase")

	-- 子弹先按原版方式命中盾牌；本后置 Hook 再判断命中的是哪根筋条。
	module:post_hook(InstantBulletBase, "on_collision", function(self, col_ray, weapon_unit, user_unit, damage)
		-- 补发穿透射线时不能再次进入这套逻辑，否则会无限递归。
		if module._processing_passthrough or not col_ray or not module:is_local_player_attack(user_unit) then
			return
		end

		local shield_unit = col_ray.unit
		if not module:is_known_shield(shield_unit) or not col_ray.position then
			return
		end

		local region_name = module:find_hit_region(shield_unit, col_ray.position, col_ray.body)
		if not region_name then
			return
		end

		local state = module:get_grille_state(shield_unit)
		if not state then
			return
		end

		-- 保持旧版行为：打碎筋条的那一发只负责破坏，从下一发开始穿透。
		local was_broken = state.broken[region_name] == true
		if not was_broken then
			-- 仿照原版敌人受击流程：开枪者先在本机立即扣除该部位耐久并播放破坏效果，
			-- 随后异步发送同一伤害事件；房主负责去重、转发以及用绝对快照单调补正。
			module:submit_local_grille_hit(
				shield_unit,
				region_name,
				col_ray.position,
				col_ray.normal,
				damage
			)
		end

		-- PDTH++ 自带穿盾武器已有自己的二次射线，避免本 Mod 再补一次造成双倍伤害。
		local weapon_base = alive(weapon_unit) and weapon_unit:base()
		if weapon_base and weapon_base._can_shoot_through_shield then
			return
		end

		if was_broken then
			module:queue_passthrough(col_ray, weapon_unit, user_unit, damage)
		end
	end, false)

end

if RequiredScript == "lib/managers/gameplaycentralmanager" then

	local GamePlayCentralManager = module:hook_class("GamePlayCentralManager")

	-- 在当前射击调用栈结束后再补发穿透射线，避免与 PDTH++ 或原版碰撞处理互相干扰。
	local function flush_passthrough()
		local pending = module._pending_passthrough
		if not pending or #pending == 0 then
			return
		end

		module._pending_passthrough = {}
		for i = 1, #pending do
			local data = pending[i]
			local shield_unit = data.shield
			local weapon_unit = data.weapon
			local user_unit = data.user

			if alive(shield_unit) and alive(weapon_unit) and alive(user_unit) then
				local weapon_base = weapon_unit:base()
				local bullet_slotmask = weapon_base and weapon_base._bullet_slotmask
				if bullet_slotmask then
					local from = data.position + data.direction * 5
					local to = from + data.direction * 20000
					-- 显式把当前盾牌加入忽略列表。掉落盾牌仍有完整原版碰撞体，
					-- 若不忽略它，二次射线可能再次击中同一面倾斜/平躺的盾牌。
					local ignore_units = {}
					local setup_ignore = weapon_base._setup and weapon_base._setup.ignore_units
					if type(setup_ignore) == "table" then
						for j = 1, #setup_ignore do
							ignore_units[#ignore_units + 1] = setup_ignore[j]
						end
					elseif alive(setup_ignore) then
						ignore_units[#ignore_units + 1] = setup_ignore
					end
					ignore_units[#ignore_units + 1] = shield_unit

					local col_ray = World:raycast(
						"ray",
						from,
						to,
						"slot_mask",
						bullet_slotmask,
						"ignore_unit",
						ignore_units
					)

					if col_ray and alive(col_ray.unit) then
						module._processing_passthrough = true
						if InstantBulletBase and InstantBulletBase.on_collision then
							InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, data.damage)
						end
						module._processing_passthrough = false
					end
				end
			end
		end
	end

	-- 清理由 SoundDevice 创建的临时声音源，避免长期积累。
	local function flush_sounds()
		local sounds = module._temporary_sounds
		if not sounds or #sounds == 0 then
			return
		end

		local now = Application:time()
		local i = 1
		while i <= #sounds do
			local data = sounds[i]
			if now >= data.expire_t then
				if data.source then
					data.source:stop()
				end
				table.remove(sounds, i)
			else
				i = i + 1
			end
		end
	end

	module:post_hook(GamePlayCentralManager, "end_update", function(self, t, dt)
		flush_passthrough()
		flush_sounds()
		module:cleanup_dropped_shields()
		-- 客机在这里重发尚未被房主明确收录的本地伤害事件；
		-- 房主则在射击停止一小段时间后补发一次最终完整快照。
		module:update_grille_network()

		-- debug_vision 开启时，每帧重画五个判定区域，使线框跟随手持或掉落盾牌。
		module:draw_debug_vision()
	end, false)

end