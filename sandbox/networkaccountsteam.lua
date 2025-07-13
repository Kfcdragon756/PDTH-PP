local module = ... or D:module("PDTH++")
local NetworkAccountSTEAM = module:hook_class("NetworkAccountSTEAM")

module:hook(NetworkAccountSTEAM, "publish_statistics", function(self, stats, success, ...) end)
module:hook(NetworkAccountSTEAM, "_check_for_unawarded_achievements", function(self) end)

