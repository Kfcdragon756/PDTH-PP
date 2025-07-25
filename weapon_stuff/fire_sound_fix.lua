local module = ... or D:module("PDTH++")
local RaycastWeaponBase = module:hook_class("RaycastWeaponBase")
module:hook(RaycastWeaponBase, "_fire_sound", function(self)
    self:play_tweak_data_sound("fire")
    self:play_tweak_data_sound("stop_fire")
end)

module:hook(RaycastWeaponBase, "stop_shooting", function(self)
	self._shooting = nil
end)

module:hook(RaycastWeaponBase, "start_shooting", function(self,...)
	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
end)

module:pre_hook(RaycastWeaponBase, "fire", function(self)
    self:_fire_sound()
end)