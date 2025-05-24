local module = ... or D:module("PDTH++")
local GameSetup = module:hook_class("GameSetup")

module:post_hook(50, GameSetup, "unload_packages", function(self)
	if PackageManager:loaded("packages/level_slaughterhouse") then
		PackageManager:unload("packages/level_slaughterhouse")
	end
end, true)