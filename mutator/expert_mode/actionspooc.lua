-- From PDTH:FGO

local module = ... or D:module("PDTH++")
local ActionSpooc = module:hook_class("ActionSpooc")

module:hook(ActionSpooc, "_upd_strike_first_frame", function(self, t)
	if self._is_local and self:_chk_target_invalid() then
		if Network:is_server() then
			self:_expire()
			return
		end

		self:_wait()
		return
	end

	if self._ext_movement:play_redirect("spooc_strike") then
		self._ext_movement:spawn_wanted_items()
	end

	self._stroke = true

	if self._is_local then
		mvector3.set(self._last_sent_pos, self._common_data.pos)
		self._ext_network:send("action_spooc_strike", mvector3.copy(self._common_data.pos))
		self._nav_path[self._nav_index + 1] = mvector3.copy(self._common_data.pos)
		self._strike_unit = self._target_unit
		self._target_unit:movement():on_SPOOCed()
		self._unit:sound():say("_punch_3rd_person_3p", true)
	end

	local detonate_pos, attacker_pos = self._ext_movement._m_pos + math.UP * 10, self._ext_movement:m_head_pos()
	local duration = math.lerp(15, 30, math.random())
	
	managers.network:session():send_to_peers("sync_smoke_grenade", detonate_pos, attacker_pos, duration)
	
	if Network:is_server() then
		managers.groupai:state():sync_smoke_grenade(detonate_pos, attacker_pos, duration)
	end

	self:_set_updator("_upd_striking")
	self._common_data.unit:base():chk_freeze_anims()
end)
