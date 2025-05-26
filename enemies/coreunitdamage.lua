local module = ... or D:module("PDTH++")

local CoreBodyDamage = module:hook_class("CoreBodyDamage")

CoreBodyDamage.dozer_visor_bs = false

local ids_glass = Idstring("glass")
module:post_hook(CoreBodyDamage, "init", function(self, unit, unit_extension, body, body_element)
	if not alive(unit) or not alive(body) or CoreBodyDamage.dozer_visor_bs then
		return
	end

	if tablex.get(unit:base(), "_tweak_table") == "tank" and body:name() == ids_glass then
		self._endurance["explosion"]["_endurance"]["damage"] = tweak_data.character.tank.damage.visor_health
		self._endurance["explosion"]["_endurance"]["explosion"] = tweak_data.character.tank.damage.visor_explosion_health

		CoreBodyDamage.dozer_visor_bs = true
	end
end)
