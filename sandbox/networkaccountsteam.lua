local NetworkAccountSTEAM = module:hook_class("NetworkAccountSTEAM")

module:hook(NetworkAccountSTEAM, "publish_statistics", function(self, stats, success, ...) end)
