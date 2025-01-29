local module = ... or DorHUD:module("PDTH++")
local FPCameraPlayerBase = module:hook_class("FPCameraPlayerBase")

module:hook(FPCameraPlayerBase, "stop_shooting", function(self)
	self._recoil_kick.to_reduce = 0
	self._recoil_kick.h.to_reduce = 0
end)

module:hook(FPCameraPlayerBase, "recoil_kick", function(self, v, v_h)
	v = v or 0.1
	self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + v
	v_h = (v_h or 0.25) * (math.random(0, 1) == 0 and -1 or 1)
	self._recoil_kick.h.accumulated = (self._recoil_kick.h.accumulated or 0) + v_h * math.rand(0.5, 1)
end)

--code courtesy from static recoil.