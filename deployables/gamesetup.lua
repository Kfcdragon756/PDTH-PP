--unused
local GameSetup = module:hook_class("GameSetup")
module:post_hook(50, GameSetup, "init_finalize", function(self)
	if not PackageManager:has(Idstring("unit"), Idstring("units/world/props/apartment/apartment_key_dummy/apartment_key_dummy")) then
		PackageManager:load("levels/apartment/world/world")
		PackageManager:load("levels/apartment/world/world_init")
	end
end, true)

module:post_hook(50, GameSetup, "unload_packages", function(self)
	if PackageManager:loaded("levels/apartment/world/world") then
		PackageManager:unload("levels/apartment/world/world")
	end
	if PackageManager:loaded("levels/apartment/world/world_init") then
		PackageManager:unload("levels/apartment/world/world_init")
	end
end, true)

--this prevents summoning sentries in other maps crashing the game.

