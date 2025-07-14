local GameSetup = module:hook_class("GameSetup")
module:post_hook(50, GameSetup, "init_finalize", function(self)
	if not PackageManager:has(Idstring("unit"), Idstring("units/characters/enemies/murky_water1/murky_water1")) then
		PackageManager:load("packages/level_slaughterhouse")
	end
end, true)

module:post_hook(50, GameSetup, "unload_packages", function(self)
	if PackageManager:loaded("packages/level_slaughterhouse") then
		PackageManager:unload("packages/level_slaughterhouse")
	end
end, true)