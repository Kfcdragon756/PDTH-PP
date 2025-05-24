local module = ... or D:module("PDTH++")
local CopDamage = module:hook_class("CopDamage")

function CopDamage:die(variant)
	if Network:is_server() then
		local pos = self._unit:position()
		local key = self._unit:key()
		local radius = 640000
		local num_dodged = 0
		for _, enemy_data in pairs(managers.enemy:all_enemies()) do
			if enemy_data.unit:key() ~= key and radius > mvector3.distance_sq(pos, enemy_data.m_pos) and enemy_data.unit:character_damage():dodge(false) then
				num_dodged = num_dodged + 1
				if num_dodged >= 4 then
				end
			else
			end
		end
	end
	self._unit:base():set_slot(self._unit, 17)
	self._unit:inventory():drop_shield()
	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)
	end
	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true
	self:set_mover_collision_state(false)
end